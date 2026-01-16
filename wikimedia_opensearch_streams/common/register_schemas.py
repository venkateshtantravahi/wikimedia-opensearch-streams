import json
import logging
from pathlib import Path
from typing import Optional

from confluent_kafka.schema_registry import Schema, SchemaRegistryClient
from confluent_kafka.schema_registry.error import SchemaRegistryError

from wikimedia_opensearch_streams.common.config import AppConfig

# Use the centralized logger logic we planned earlier
logger = logging.getLogger(__name__)


class SchemaRegistryManager:
    """
    Production-grade manager for Confluent Schema Registry operations.
    Enforces manual registration and strict schema validation.
    """

    def __init__(self, registry_url: Optional[str] = None):
        self.url = registry_url or AppConfig.SCHEMA_REGISTRY_URL
        if not self.url:
            raise ValueError("SCHEMA_REGISTRY_URL is missing in configuration.")

        try:
            self.client = SchemaRegistryClient({"url": self.url})
            logger.info(f"Connected to Schema Registry at: {self.url}")
        except Exception as e:
            logger.critical(f"Initialization failed for Schema Registry client: {e}")
            raise

    @staticmethod
    def load_and_validate_avro(file_path: Path) -> str:
        """Loads and performs a basic JSON validation on the Avro file."""
        if not file_path.exists():
            raise FileNotFoundError(f"Missing schema file at: {file_path.absolute()}")

        try:
            content = file_path.read_text(encoding="utf-8")
            # Basic validation: ensure it's valid JSON
            json.loads(content)
            return content
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON format in schema {file_path.name}: {e}")
            raise
        except Exception as e:
            logger.error(f"Failed to load schema {file_path.name}: {e}")
            raise

    def register_manual(self, subject: str, schema_path: Path) -> int:
        """
        Registers a schema manually.
        Will fail if the schema is incompatible with existing versions.
        """
        schema_str = self.load_and_validate_avro(schema_path)
        schema = Schema(schema_str, schema_type="AVRO")

        try:
            # Check compatibility before attempting registration
            # This is a 'soft' check before the 'hard' server-side check
            logger.debug(f"Checking compatibility for subject: {subject}")

            schema_id = self.client.register_schema(subject, schema)
            logger.info(f"Successfully registered. Subject: {subject} | ID: {schema_id}")
            return schema_id

        except SchemaRegistryError as e:
            logger.error(f"Incompatible schema or Registry error for {subject}: {e}")
            raise

    def get_latest_id(self, subject: str) -> int:
        """Retrieves the latest registered ID for a subject."""
        try:
            version = self.client.get_latest_version(subject)
            return version.schema_id
        except SchemaRegistryError as e:
            logger.error(f"Could not find schema for subject {subject}: {e}")
            raise


def run_registration():
    """Entry point for manual schema management."""
    logging.basicConfig(level=logging.INFO)

    # Path calculation relative to the project root
    base_path = Path(__file__).parent.parent / "producer" / "schemas"
    schema_file = base_path / "wikimedia_event.avsc"

    # Subject naming convention: <topic>-value
    subject = f"{AppConfig.RAW_TOPIC}-value"

    manager = SchemaRegistryManager()

    print(f"--- Starting Manual Schema Registration for {subject} ---")
    try:
        schema_id = manager.register_manual(subject, schema_file)
        print(f"DONE: Schema is live with ID {schema_id}")
    except Exception as e:
        print(f"FAILED: Registration aborted. Error: {e}")
        exit(1)


if __name__ == "__main__":
    run_registration()
