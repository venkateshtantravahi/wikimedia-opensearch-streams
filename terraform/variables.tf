# --- Connection Settings ---
variable "kafka_bootstrap_servers" {
  description = "List of Kafka brokers"
  type        = list(string)
  default     = ["127.0.0.1:9092"]
}

# --- Topic Naming ---
variable "raw_topic_name" {
  type    = string
  default = "wikimedia.raw"
}

variable "processed_topic_name" {
  type    = string
  default = "wikimedia.processed"
}

# --- Scaling & Reliability ---
variable "topic_partitions" {
  description = "Number of partitions (Scale out capacity)"
  type        = number
  default     = 3
}

variable "replication_factor" {
  description = "Replication factor for fault tolerance"
  type        = number
  default     = 1
}

# ---- compression type ---
variable "compression_type" {
  description = "How messages are compressed before commiting to topic."
  type = string
  default = "lz4"
}

variable "consumer_compression_type" {
  type = string
  default = "snappy"
}

variable "max_message_bytes" {
  type = string
  default = "2097152"
}

variable "cleanup_policy" {
  type = string
  default = "delete"
}

# --- Retention ---
variable "message_retention_ms" {
  description = "How long to keep messages (default 1 day)"
  type        = string
  default     = "86400000"
}
