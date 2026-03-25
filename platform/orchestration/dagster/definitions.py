"""
Minimal Dagster definitions for platform validation.

This module contains a simple asset to validate Dagster startup.
Real ML pipelines and data workflows will be added in the application layer.
"""

from dagster import asset, define_asset_job
from datetime import datetime


@asset
def platform_status() -> dict:
    """
    Simple asset that returns platform status.

    This asset validates that Dagster can:
    - Define assets
    - Execute jobs
    - Track asset lineage

    Returns:
        dict: Platform status information
    """
    return {
        "status": "operational",
        "timestamp": datetime.now().isoformat(),
        "orchestration": "dagster",
        "message": "AI Platform orchestration layer is ready"
    }


# Define a simple job that uses the asset
platform_job = define_asset_job(
    name="platform_status_job",
    selection=[platform_status],
)
