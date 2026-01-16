terraform {
  required_providers {
    kafka = {
      source = "Mongey/kafka"
      version = "0.12.1"
    }
  }
}

provider "kafka" {
  bootstrap_servers = var.kafka_bootstrap_servers

  tls_enabled = false
}

resource "kafka_topic" "raw_topic" {
  name               = var.raw_topic_name
  replication_factor = var.replication_factor # Use 3 for real production clusters
  partitions         = var.topic_partitions # Match this to your number of consumer instances

  config = {
    # Throughput Optimization
    "compression.type" = var.compression_type            # High performance, low CPU overhead
    "max.message.bytes" = var.max_message_bytes       # Increased to 2MB for larger batches

    # Reliability & Retention
    "cleanup.policy"   = var.cleanup_policy
    "retention.ms"     = var.message_retention_ms       # 1 day retention
    "min.insync.replicas" = "1"           # Use 2 if replication_factor=3
    "unclean.leader.election.enable" = "false" # Prevent data loss
  }
}

resource "kafka_topic" "processed_topic" {
  name               = var.processed_topic_name
  replication_factor = 1
  partitions         = 3

  config = {
    "compression.type" = var.consumer_compression_type         # Good balance for processed data
    "cleanup.policy"   = var.cleanup_policy
  }
}
