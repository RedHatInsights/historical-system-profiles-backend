from prometheus_client import Counter

profile_messages_consumed = Counter(
    "hsp_profile_messages_consumed", "count of profile messages we consumed"
)

profile_messages_processed = Counter(
    "hsp_profile_messages_processed",
    "count of profile messages we successfully processed",
)

profile_messages_errored = Counter(
    "hsp_profile_messages_errored",
    "count of profile messages we unsuccessfully processed",
)

delete_messages_consumed = Counter(
    "hsp_delete_messages_consumed", "count of delete messages we consumed"
)

delete_messages_processed = Counter(
    "hsp_delete_messages_processed",
    "count of delete messages we successfully processed",
)

delete_messages_errored = Counter(
    "hsp_delete_messages_errored",
    "count of delete messages we unsuccessfully processed",
)
