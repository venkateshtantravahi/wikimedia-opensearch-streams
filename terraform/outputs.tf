output "raw_topic_config" {
  value = {
    name       = kafka_topic.raw_topic.name
    partitions = kafka_topic.raw_topic.partitions
    compression = kafka_topic.raw_topic.config["compression.type"]
  }
}

output "consumer_group_hint" {
  value = "Run exactly ${kafka_topic.raw_topic.partitions} consumer instances for max throughput."
}
