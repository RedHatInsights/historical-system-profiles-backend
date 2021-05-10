import time

from historical_system_profiles import config, listener_logging
from historical_system_profiles.app import create_app
from historical_system_profiles import db_interface
from historical_system_profiles import listener_metrics as metrics
from prometheus_client import start_http_server as start_metrics_server


def main():
    logger = listener_logging.initialize_logging()
    start_metrics_server(config.listener_metrics_port)
    app = create_app()
    logger.warn(
        "starting expired record cleaning loop, will remove records older than "
        "%s days every %s minutes"
        % (config.valid_profile_age_days, config.expired_cleaner_sleep_minutes)
    )
    expired_record_cleaning_loop(app.app, logger)


def expired_record_cleaning_loop(flask_app, logger):
    with flask_app.app_context():
        while True:
            try:
                with metrics.records_cleaning_time.time():
                    # TODO: DRFT-310 - use returned system_ids and delete them from baseline svc
                    deleted_count = db_interface.clean_expired_records(
                        config.valid_profile_age_days
                    )
                logger.info("deleted %s expired records" % deleted_count)
                metrics.records_cleaned.inc(deleted_count)
            except Exception:
                logger.exception(
                    "An error occurred during expired record cleaning loop"
                )
            logger.info(
                "sleeping for %s minutes" % config.expired_cleaner_sleep_minutes
            )
            time.sleep(config.expired_cleaner_sleep_minutes * 60)


if __name__ == "__main__":
    main()
