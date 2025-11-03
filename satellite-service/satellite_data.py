import requests
import json
import numpy as np
from datetime import datetime, timedelta
import hashlib
import time
import sys
import argparse
import math

# Configuration
config = {
    "sh_client_id": "c13fa337-70d5-4ad9-8581-4704e9639e14",
    "sh_client_secret": "tSfrCXqAHEV4IbOojUsw1NN5sZbV42Md",
}

def get_access_token():
    """Get access token from Sentinel Hub"""
    try:
        auth_url = "https://services.sentinel-hub.com/oauth/token"
        auth_data = {
            "grant_type": "client_credentials",
            "client_id": config["sh_client_id"],
            "client_secret": config["sh_client_secret"]
        }

        response = requests.post(auth_url, data=auth_data, timeout=10)
        if response.status_code == 200:
            return response.json()["access_token"]
        else:
            print(f"❌ Authentication failed: {response.status_code}", file=sys.stderr)
            return None
    except Exception as e:
        print(f"❌ Error getting access token: {e}", file=sys.stderr)
        return None

def get_sentinel2_crop_data(polygon_json_string):
    """Get crop health data from Sentinel-2 L2A using a precise polygon."""
    access_token = get_access_token()
    if not access_token:
        return None

    try:
        polygon_data = json.loads(polygon_json_string)
        if len(polygon_data) < 4:
            print("❌ Invalid polygon: needs at least 3 points.", file=sys.stderr)
            return None

        coordinates = [[p["longitude"], p["latitude"]] for p in polygon_data]
        if coordinates[0] != coordinates[-1]:
            coordinates.append(coordinates[0])

        geometry = {"type": "Polygon", "coordinates": [coordinates]}

    except Exception as e:
        print(f"❌ Error parsing polygon JSON: {e}", file=sys.stderr)
        return None

    evalscript = """
    //VERSION=3
    function setup() {
        return {
            input: [{ bands: ["B02", "B03", "B04", "B08", "SCL", "dataMask"] }],
            output: [
                { id: "ndvi", bands: 1, sampleType: "FLOAT32" },
                { id: "dataMask", bands: 1 }
            ]
        };
    }

    function evaluatePixel(sample) {
        let ndvi = (sample.B08 - sample.B04) / (sample.B08 + sample.B04);
        return {
            ndvi: [sample.dataMask ? ndvi : -999],
            dataMask: [sample.dataMask]
        };
    }
    """

    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)

    request_payload = {
        "input": {
            "bounds": {
                "geometry": geometry,
                "properties": {"crs": "http://www.opengis.net/def/crs/OGC/1.3/CRS84"}
            },
            "data": [{
                "type": "sentinel-2-l2a",
                "dataFilter": {
                    "timeRange": {
                        "from": start_date.isoformat() + "Z",
                        "to": end_date.isoformat() + "Z"
                    },
                    "maxCloudCoverage": 20,
                    "mosaickingOrder": "mostRecent"
                }
            }]
        },
        "aggregation": {
            "evalscript": evalscript,
            "timeRange": {
                "from": start_date.isoformat() + "Z",
                "to": end_date.isoformat() + "Z"
            },
            "aggregationInterval": "P30D",
            "resolution": {"x": 10, "y": 10}
        }
    }

    try:
        print("🌱 Connecting to Sentinel Hub for statistical analysis...", file=sys.stderr)
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
        url = "https://services.sentinel-hub.com/api/v1/statistics"
        response = requests.post(url, json=request_payload, headers=headers, timeout=60)

        if response.status_code == 200:
            print("✅ Successfully received Sentinel-2 statistics!", file=sys.stderr)
            return response.json()
        else:
            print(f"❌ Sentinel-2 API error: {response.status_code}", file=sys.stderr)
            print(response.text[:300], file=sys.stderr)
            return None
    except Exception as e:
        print(f"❌ Error fetching Sentinel-2 data: {e}", file=sys.stderr)
        return None

def process_sentinel2_data(data):
    """Process the statistical data from Sentinel-2"""
    try:
        print("🔍 Processing Sentinel-2 statistics...", file=sys.stderr)

        interval_data = data["data"][0]["outputs"]["ndvi"]["bands"]["B0"]
        ndvi_stats = interval_data["stats"]
        histogram = interval_data["histogram"]["bins"]

        total_pixels = ndvi_sum = healthy_pixels = stressed_pixels = barren_pixels = 0

        for bin in histogram:
            ndvi_value = bin["low"]
            pixel_count = bin["count"]

            if ndvi_value == -999:
                continue

            total_pixels += pixel_count
            ndvi_sum += ndvi_value * pixel_count

            if ndvi_value > 0.5:
                healthy_pixels += pixel_count
            elif 0.2 < ndvi_value <= 0.5:
                stressed_pixels += pixel_count
            else:
                barren_pixels += pixel_count

        if total_pixels == 0:
            print("❌ No valid data pixels found.", file=sys.stderr)
            return None

        ndvi_mean = ndvi_sum / total_pixels
        healthy_percent = healthy_pixels / total_pixels * 100
        stressed_percent = stressed_pixels / total_pixels * 100
        barren_percent = barren_pixels / total_pixels * 100

        results = {
            "metadata": {
                "satellite": "Sentinel-2 L2A",
                "processing_time": datetime.now().isoformat(),
                "valid_pixel_count": total_pixels
            },
            "vegetation_indices": {
                "ndvi_mean": float(ndvi_mean),
                "ndvi_min": float(ndvi_stats["min"]),
                "ndvi_max": float(ndvi_stats["max"]),
                "ndvi_std": float(ndvi_stats["stDev"])
            },
            "vegetation_health": {
                "healthy": float(healthy_percent),
                "stressed": float(stressed_percent),
                "barren": float(barren_percent)
            }
        }

        print("✅ Sentinel-2 statistics processing complete", file=sys.stderr)
        return results
    except Exception as e:
        print(f"❌ Error processing Sentinel-2 data: {e}", file=sys.stderr)
        return None

def calculate_crop_damage(sentinel2_data, claim_id):
    """Calculate crop damage assessment from Sentinel-2 data"""
    if sentinel2_data is None:
        return None

    try:
        ndvi_mean = sentinel2_data["vegetation_indices"]["ndvi_mean"]
        health = sentinel2_data["vegetation_health"]

        damage_from_stress = health["stressed"] * 0.5
        damage_from_barren = health["barren"] * 0.9
        total_damage = min(100, damage_from_stress + damage_from_barren)

        timestamp = str(time.time())
        data_hash = hashlib.sha256(f"{claim_id}_{ndvi_mean}_{total_damage}_{timestamp}".encode()).hexdigest()

        return {
            "damagePercentage": int(total_damage),
            "ndviValue": float(ndvi_mean),
            "satelliteDataHash": data_hash,
            "analysisReport": sentinel2_data
        }
    except Exception as e:
        print(f"❌ Error in crop damage assessment: {e}", file=sys.stderr)
        return None

def main(claim_id, polygon_json):
    print(f"🚀 INITIATING ANALYSIS for ClaimID: {claim_id}", file=sys.stderr)

    sentinel2_raw_data = get_sentinel2_crop_data(polygon_json)
    if sentinel2_raw_data is None:
        print("❌ FAILED: Could not retrieve Sentinel-2 data.", file=sys.stderr)
        return None

    sentinel2_data = process_sentinel2_data(sentinel2_raw_data)
    if sentinel2_data is None:
        print("❌ FAILED: Could not process Sentinel-2 data.", file=sys.stderr)
        return None

    final_assessment = calculate_crop_damage(sentinel2_data, claim_id)
    if final_assessment is None:
        print("❌ FAILED: Could not calculate final damage.", file=sys.stderr)
        return None

    print(json.dumps(final_assessment, indent=2))
    print(f"✅ ANALYSIS COMPLETE for ClaimID: {claim_id}", file=sys.stderr)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process satellite data for a farm.")
    parser.add_argument("claim_id", type=str, help="The claim ID")
    parser.add_argument("polygon_json", type=str, help="The JSON string of the farm boundary polygon")
    args = parser.parse_args()
    main(args.claim_id, args.polygon_json)
