import os

from dotenv import load_dotenv

load_dotenv()


class AppConfig:
    BOOTSTRAP_SERVERS = os.getenv("BOOTSTRAP_SERVERS")
    SCHEMA_REGISTRY_URL = os.getenv("SCHEMA_REGISTRY_URL")
    WIKIMEDIA_URL = os.getenv("WIKIMEDIA_STREAM_URL")
    OPENSEARCH_URL = os.getenv("OPENSEARCH_URL")
    SCHEMA_PATH = os.getenv("DEFAULT_SCHEMA_PATH")
    WIKIMEDIA_SCHEMA_FILE = os.getenv("WIKIMEDIA_SCHEMA_FILE")
    RAW_TOPIC = os.getenv("RAW_TOPIC")
