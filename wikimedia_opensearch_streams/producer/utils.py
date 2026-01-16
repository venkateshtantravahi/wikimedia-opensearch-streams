def format_wikimedia_event(raw_json: dict) -> dict:
    """
    Map raw Wikimedia JSON to our Avro Schema structure.
    Ensures data types match the .avsc and handles missing nested objects.
    """
    # Safely get the nested 'meta' dictionary
    meta = raw_json.get("meta", {})

    return {
        "id": raw_json.get("id"),
        "type": raw_json.get("type", "unknown"),
        "title": raw_json.get("title", ""),
        "user": raw_json.get("user", ""),
        "bot": bool(raw_json.get("bot", False)),
        "timestamp": int(raw_json.get("timestamp", 0)),
        "comment": raw_json.get("comment"),
        "wiki": raw_json.get("wiki"),
        "server_name": raw_json.get("server_name"),
        "server_url": raw_json.get("server_url"),
        "server_script_path": raw_json.get("server_script_path"),
        "namespace": raw_json.get("namespace"),
        "meta": {
            "id": meta.get("id", ""),
            "dt": meta.get("dt", ""),
            "domain": meta.get("domain", ""),
            "stream": meta.get("stream", ""),
            "request_id": meta.get("request_id"),
        },
        "length": raw_json.get("length"),
        "revision": raw_json.get("revision"),
    }
