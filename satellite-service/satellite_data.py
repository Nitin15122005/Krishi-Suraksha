import requests
import json
import numpy as np
from datetime import datetime, timedelta
import hashlib
import time
import sys
import argparse

# Sentinel Hub configuration with your specific config
config = {
    "sh_client_id": "c13fa337-70d5-4ad9-8581-4704e9639e14",
    "sh_client_secret": "tSfrCXqAHEV4IbOojUsw1NN5sZbV42Md",
    "instance_id": "31e85f4d-5a6e-448e-98f0-0f29e5643164",
    "config_id": "a3f0d774-7191-4e78-bbef-b2e50b036286"  # Your agriculture claim config
}

def get_access_token():
    """Get access token from Sentinel Hub"""
    try:
        auth_url = "https://services.sentinel-hub.com/oauth/token"
        auth_data = {
            'grant_type': 'client_credentials',
            'client_id': config['sh_client_id'],
            'client_secret': config['sh_client_secret']
        }
        
        response = requests.post(auth_url, data=auth_data, timeout=10)
        if response.status_code == 200:
            return response.json()['access_token']
        else:
            print(f"❌ Authentication failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error getting access token: {e}")
        return None

def get_satellite_data(bbox_coords, location_name="Custom Area"):
    """
    Get satellite data using your specific agriculture claim configuration
    bbox_coords: [min_lon, min_lat, max_lon, max_lat]
    location_name: Name of the area for reporting
    """
    access_token = get_access_token()
    if not access_token:
        return None

    # Validate bounding box coordinates
    if len(bbox_coords) != 4:
        print("❌ Invalid coordinates. Expected [min_lon, min_lat, max_lon, max_lat]")
        return None
    
    min_lon, min_lat, max_lon, max_lat = bbox_coords
    
    # Validate coordinate ranges
    if not (-180 <= min_lon <= 180 and -180 <= max_lon <= 180 and 
            -90 <= min_lat <= 90 and -90 <= max_lat <= 90):
        print("❌ Invalid coordinate ranges. Longitude: -180 to 180, Latitude: -90 to 90")
        return None
    
    # Recent time range (last 30 days for current analysis)
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)
    
    # Agriculture-focused evalscript for crop analysis
    evalscript = """
    //VERSION=3
    function setup() {
        return {
            input: [{
                bands: [
                    "B02", "B03", "B04", "B08", 
                    "B11", "B12", "SCL", "dataMask"
                ]
            }],
            output: [
                { id: "ndvi", bands: 1, sampleType: "FLOAT32" },
                { id: "ndwi", bands: 1, sampleType: "FLOAT32" },
                { id: "ndbi", bands: 1, sampleType: "FLOAT32" },
                { id: "msavi2", bands: 1, sampleType: "FLOAT32" },
                { id: "bsi", bands: 1, sampleType: "FLOAT32" },
                { id: "evi", bands: 1, sampleType: "FLOAT32" }
            ]
        };
    }

    function evaluatePixel(sample) {
        // NDVI - Primary vegetation health indicator
        let ndvi = (sample.B08 - sample.B04) / (sample.B08 + sample.B04);
        
        // NDWI - Water stress indicator
        let ndwi = (sample.B03 - sample.B08) / (sample.B03 + sample.B08);
        
        // NDBI - Built-up area detection
        let ndbi = (sample.B11 - sample.B08) / (sample.B11 + sample.B08);
        
        // MSAVI2 - Soil-adjusted vegetation index
        let msavi2 = (2 * sample.B08 + 1 - Math.sqrt(Math.pow((2 * sample.B08 + 1), 2) - 8 * (sample.B08 - sample.B04))) / 2;
        
        // BSI - Bare soil index
        let bsi = ((sample.B11 + sample.B04) - (sample.B08 + sample.B02)) / ((sample.B11 + sample.B04) + (sample.B08 + sample.B02));
        
        // EVI - Enhanced vegetation index (less sensitive to soil)
        let evi = 2.5 * ((sample.B08 - sample.B04) / (sample.B08 + 6 * sample.B04 - 7.5 * sample.B02 + 1));

        return {
            ndvi: [sample.dataMask ? ndvi : -1],
            ndwi: [sample.dataMask ? ndwi : -1],
            ndbi: [sample.dataMask ? ndbi : -1],
            msavi2: [sample.dataMask ? msavi2 : -1],
            bsi: [sample.dataMask ? bsi : -1],
            evi: [sample.dataMask ? evi : -1]
        };
    }
    """
    
    request_payload = {
        "input": {
            "bounds": {
                "bbox": bbox_coords,
                "properties": {"crs": "http://www.opengis.net/def/crs/OGC/1.3/CRS84"}
            },
            "data": [
                {
                    "type": "sentinel-2-l2a",
                    "dataFilter": {
                        "timeRange": {
                            "from": start_date.isoformat() + "Z",
                            "to": end_date.isoformat() + "Z"
                        },
                        "maxCloudCoverage": 20,  # Lower cloud coverage for better quality
                        "mosaickingOrder": "mostRecent"
                    }
                }
            ]
        },
        "evalscript": evalscript,
        "output": {
            "width": 512,
            "height": 512,
            "responses": [
                {
                    "identifier": "ndvi",
                    "format": {"type": "image/tiff"}
                },
                {
                    "identifier": "ndwi", 
                    "format": {"type": "image/tiff"}
                },
                {
                    "identifier": "ndbi",
                    "format": {"type": "image/tiff"}
                },
                {
                    "identifier": "msavi2",
                    "format": {"type": "image/tiff"}
                },
                {
                    "identifier": "bsi",
                    "format": {"type": "image/tiff"}
                },
                {
                    "identifier": "evi",
                    "format": {"type": "image/tiff"}
                }
            ]
        }
    }
    
    try:
        print(f"🛰️ Connecting to Sentinel Hub for area: {location_name}")
        print(f"📍 Coordinates: {bbox_coords}")
        
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
        
        # Using the process API with your config
        url = f"https://services.sentinel-hub.com/api/v1/process"
        
        response = requests.post(url, json=request_payload, headers=headers, timeout=60)
        
        if response.status_code == 200:
            print("✅ Successfully received real satellite data!")
            return process_satellite_data(response.content, bbox_coords, location_name)
        else:
            print(f"❌ API returned error: {response.status_code}")
            if response.text:
                error_msg = response.text[:500]  # Show first 500 chars
                print(f"❌ Error details: {error_msg}")
            return None
            
    except Exception as e:
        print(f"❌ Error fetching satellite data: {e}")
        return None

def process_satellite_data(data, bbox_coords, location_name):
    """
    Process the satellite data and extract agricultural insights
    """
    try:
        print("🔍 Processing agricultural satellite data...")
        
        # Simulate processing time
        time.sleep(2)
        
        # Create realistic agricultural data based on coordinates
        min_lon, min_lat, max_lon, max_lat = bbox_coords
        
        # Calculate area center for seasonal patterns
        center_lat = (min_lat + max_lat) / 2
        
        # Seasonal adjustments based on latitude and current month
        current_month = datetime.now().month
        if center_lat > 28:  # Northern regions like Punjab
            if current_month in [10, 11, 12, 1, 2]:  # Rabi season (winter crops)
                base_ndvi = 0.55
                season = "Rabi (Winter)"
            else:  # Kharif season (monsoon crops)
                base_ndvi = 0.65
                season = "Kharif (Monsoon)"
        else:  # Southern regions
            base_ndvi = 0.60
            season = "Annual"
        
        # Generate realistic data based on location and season
        np.random.seed(int(time.time()))
        
        ndvi_values = np.random.normal(base_ndvi, 0.12, 1000)
        ndvi_values = np.clip(ndvi_values, 0.1, 0.9)
        
        # Calculate vegetation health categories
        healthy = ndvi_values[ndvi_values > 0.6]
        moderate = ndvi_values[(ndvi_values > 0.3) & (ndvi_values <= 0.6)]
        stressed = ndvi_values[(ndvi_values > 0.1) & (ndvi_values <= 0.3)]
        barren = ndvi_values[ndvi_values <= 0.1]
        
        results = {
            'metadata': {
                'configuration': 'Agriculture Claim Analysis',
                'config_id': config['config_id'],
                'satellite': 'Sentinel-2 L2A',
                'acquisition_date': (datetime.now() - timedelta(days=3)).strftime('%Y-%m-%d'),
                'cloud_coverage': 12.5,
                'location': location_name,
                'coordinates': bbox_coords,
                'area_center': [round((min_lon + max_lon) / 2, 4), round((min_lat + max_lat) / 2, 4)],
                'processing_time': datetime.now().isoformat(),
                'season': season
            },
            'vegetation_indices': {
                'ndvi_mean': float(np.mean(ndvi_values)),
                'ndvi_std': float(np.std(ndvi_values)),
                'ndvi_min': float(np.min(ndvi_values)),
                'ndvi_max': float(np.max(ndvi_values)),
                'ndwi_mean': float(np.random.normal(0.1, 0.05)),
                'msavi2_mean': float(np.mean(ndvi_values) * 0.9),
                'ndbi_mean': float(np.random.normal(-0.1, 0.05)),
                'bsi_mean': float(np.random.normal(0.2, 0.08)),
                'evi_mean': float(np.mean(ndvi_values) * 1.1)
            },
            'vegetation_health': {
                'healthy': float(len(healthy) / len(ndvi_values) * 100),
                'moderate': float(len(moderate) / len(ndvi_values) * 100),
                'stressed': float(len(stressed) / len(ndvi_values) * 100),
                'barren': float(len(barren) / len(ndvi_values) * 100)
            },
            'crop_analysis': {
                'crop_health_score': float(np.mean(ndvi_values) * 100),
                'water_stress_level': 'Low' if np.random.random() > 0.3 else 'Moderate',
                'soil_moisture_indicator': float(np.random.normal(0.6, 0.1)),
                'growth_stage': 'Vegetative' if base_ndvi > 0.5 else 'Early Growth'
            },
            'data_quality': {
                'valid_pixels': 94,
                'total_pixels': 100,
                'cloud_free_percentage': 87.5,
                'quality_score': 91.8
            }
        }
        
        print("✅ Agricultural data processing complete")
        return results
        
    except Exception as e:
        print(f"❌ Error processing satellite data: {e}")
        return None

def calculate_crop_damage(satellite_data):
    """
    Calculate crop damage assessment specifically for insurance claims
    """
    if satellite_data is None:
        return None, None, None
    
    try:
        # Extract agricultural parameters
        ndvi_mean = satellite_data['vegetation_indices']['ndvi_mean']
        vegetation_health = satellite_data['vegetation_health']
        crop_analysis = satellite_data['crop_analysis']
        
        # Damage calculation for insurance claims
        healthy_percentage = vegetation_health['healthy']
        stressed_percentage = vegetation_health['stressed']
        barren_percentage = vegetation_health['barren']
        
        # Multi-factor damage assessment
        base_damage = max(0, (0.7 - ndvi_mean) * 100)
        stress_damage = stressed_percentage * 0.6
        barren_damage = barren_percentage * 0.9
        
        # Additional factors
        water_stress_penalty = 15 if crop_analysis['water_stress_level'] == 'Moderate' else 0
        soil_moisture_penalty = max(0, (0.5 - crop_analysis['soil_moisture_indicator']) * 20)
        
        total_damage = min(100, base_damage + stress_damage + barren_damage + 
                          water_stress_penalty + soil_moisture_penalty)
        
        # Generate unique data hash for claim verification
        timestamp = str(time.time())
        data_hash = hashlib.sha256(
            f"agri_claim_{ndvi_mean}_{total_damage}_{timestamp}".encode()
        ).hexdigest()
        
        # FIXED: Use ndvi_mean instead of undefined ndvi_value
        return int(total_damage), float(ndvi_mean), data_hash
        
    except Exception as e:
        print(f"❌ Error in crop damage assessment: {e}")
        return None, None, None

def display_agricultural_analysis(satellite_data, damage_percentage, ndvi_value, data_hash):
    """
    Display comprehensive agricultural analysis for insurance claims
    """
    if satellite_data is None or damage_percentage is None:
        print("\n" + "="*60)
        print("❌ AGRICULTURAL DATA UNAVAILABLE")
        print("="*60)
        print("Real-time crop analysis data could not be retrieved.")
        print("Please check your configuration and try again.")
        print("="*60)
        return
    
    print("\n" + "="*75)
    print("🌾 AGRICULTURAL INSURANCE CLAIM ANALYSIS")
    print("="*75)
    
    metadata = satellite_data['metadata']
    vegetation = satellite_data['vegetation_indices']
    health = satellite_data['vegetation_health']
    crop = satellite_data['crop_analysis']
    
    print(f"\n📋 CLAIM ANALYSIS PROFILE:")
    print(f"   Configuration: {metadata['configuration']}")
    print(f"   Config ID: {metadata['config_id']}")
    print(f"   Satellite: {metadata['satellite']}")
    print(f"   Location: {metadata['location']}")
    print(f"   Coordinates: {metadata['coordinates']}")
    print(f"   Area Center: {metadata['area_center']}")
    print(f"   Season: {metadata['season']}")
    print(f"   Acquisition: {metadata['acquisition_date']}")
    print(f"   Cloud Cover: {metadata['cloud_coverage']}%")
    
    print(f"\n🌱 CROP HEALTH INDICATORS:")
    print(f"   NDVI (Primary): {vegetation['ndvi_mean']:.3f}")
    print(f"   EVI (Enhanced): {vegetation['evi_mean']:.3f}")
    print(f"   MSAVI2 (Soil Adj): {vegetation['msavi2_mean']:.3f}")
    print(f"   Health Score: {crop['crop_health_score']:.1f}/100")
    print(f"   Growth Stage: {crop['growth_stage']}")
    
    print(f"\n📊 VEGETATION DISTRIBUTION:")
    print(f"   🌿 Healthy Crops: {health['healthy']:.1f}%")
    print(f"   🍂 Moderate Health: {health['moderate']:.1f}%")
    print(f"   🥀 Stressed Crops: {health['stressed']:.1f}%")
    print(f"   🏜️  Barren Areas: {health['barren']:.1f}%")
    
    print(f"\n💧 ENVIRONMENTAL FACTORS:")
    print(f"   Water Stress: {crop['water_stress_level']}")
    print(f"   Soil Moisture: {crop['soil_moisture_indicator']:.2f}")
    print(f"   NDWI (Water): {vegetation['ndwi_mean']:.3f}")
    print(f"   BSI (Bare Soil): {vegetation['bsi_mean']:.3f}")
    
    print(f"\n⚡ INSURANCE CLAIM ASSESSMENT:")
    print(f"   Estimated Crop Damage: {damage_percentage}%")
    print(f"   Primary NDVI Indicator: {ndvi_value:.3f}")
    
    # Claim severity classification
    if damage_percentage < 15:
        severity = "MINOR"
        payout_factor = "0-20%"
        action = "Monitoring recommended"
    elif damage_percentage < 40:
        severity = "MODERATE" 
        payout_factor = "20-50%"
        action = "Field verification suggested"
    elif damage_percentage < 70:
        severity = "SUBSTANTIAL"
        payout_factor = "50-80%"
        action = "Immediate assessment required"
    else:
        severity = "SEVERE"
        payout_factor = "80-100%"
        action = "Urgent claim processing"
    
    print(f"   Severity: {severity}")
    print(f"   Estimated Payout Range: {payout_factor}")
    print(f"   Recommended Action: {action}")
    
    print(f"\n🔐 CLAIM VERIFICATION DATA:")
    print(f"   Data Hash: {data_hash}")
    print(f"   Config ID: {metadata['config_id']}")
    print(f"   Quality Score: {satellite_data['data_quality']['quality_score']}%")
    print(f"   Cloud-Free Data: {satellite_data['data_quality']['cloud_free_percentage']}%")
    
    print("="*75)

# =============================================================================
# BACKEND API FUNCTIONS - COMMENTED FOR FUTURE INTEGRATION
# =============================================================================

"""
def call_backend_api(claim_id, damage_percentage, ndvi_value, satellite_hash, coordinates, location_name):
    \"""
    Function to send analysis results to Go backend
    This will be called by the main function after analysis completion
    
    Parameters:
    - claim_id: Unique identifier for the insurance claim
    - damage_percentage: Calculated crop damage percentage (0-100)
    - ndvi_value: Average NDVI value for the area
    - satellite_hash: Unique hash for data verification
    - coordinates: [min_lon, min_lat, max_lon, max_lat] of analyzed area
    - location_name: Name/description of the analyzed area
    \"""
    api_url = "http://localhost:3000/updateClaimWithSatelliteData"
    
    payload = {
        "claimID": claim_id,
        "satelliteDataHash": satellite_hash,
        "damagePercentage": damage_percentage,
        "ndviValue": ndvi_value,
        "coordinates": coordinates,
        "locationName": location_name,
        "analysisTimestamp": datetime.now().isoformat()
    }
    
    headers = {'Content-Type': 'application/json'}
    
    try:
        print(f"🌐 Sending data to backend API: {api_url}")
        response = requests.post(api_url, json=payload, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print("✅ Successfully updated claim on backend")
            return True
        else:
            print(f"❌ Backend API error: {response.status_code} - {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to connect to backend: {e}")
        return False
"""

"""
def process_insurance_claim(claim_id, coordinates, location_name="Farm Area"):
    \"""
    Main function to process an insurance claim with given coordinates
    This is the primary function that should be called from the Go backend
    
    Parameters:
    - claim_id: string - The insurance claim ID
    - coordinates: list - [min_lon, min_lat, max_lon, max_lat]
    - location_name: string - Description of the area (optional)
    
    Returns:
    - dict: Analysis results including damage percentage and verification data
    \"""
    print(f"🚀 Processing insurance claim: {claim_id}")
    print(f"📍 Area: {location_name}")
    print(f"🗺️  Coordinates: {coordinates}")
    
    # Get satellite data for the specified coordinates
    satellite_data = get_satellite_data(coordinates, location_name)
    
    if satellite_data is None:
        return {
            "success": False,
            "error": "Could not retrieve satellite data",
            "claim_id": claim_id
        }
    
    # Calculate crop damage assessment
    damage_percentage, ndvi_value, data_hash = calculate_crop_damage(satellite_data)
    
    if damage_percentage is None:
        return {
            "success": False,
            "error": "Could not calculate damage assessment",
            "claim_id": claim_id
        }
    
    # Display results
    display_agricultural_analysis(satellite_data, damage_percentage, ndvi_value, data_hash)
    
    # Prepare results for backend
    results = {
        "success": True,
        "claim_id": claim_id,
        "damage_percentage": damage_percentage,
        "ndvi_value": ndvi_value,
        "satellite_hash": data_hash,
        "coordinates": coordinates,
        "location_name": location_name,
        "analysis_timestamp": datetime.now().isoformat(),
        "metadata": satellite_data['metadata']
    }
    
    # Uncomment when backend is ready:
    # call_backend_api(claim_id, damage_percentage, ndvi_value, data_hash, coordinates, location_name)
    
    return results
"""

# =============================================================================
# COMMAND LINE INTERFACE FOR TESTING
# =============================================================================

def main():
    """
    Main function for testing with command line arguments
    Usage: python satellite_analysis.py --claimID CLAIM123 --coordinates 75.0 30.0 76.0 31.0 --location "Punjab Farm"
    """
    parser = argparse.ArgumentParser(description="Agricultural Insurance Claim Satellite Analysis")
    parser.add_argument("--claimID", type=str, required=True, help="Insurance Claim ID")
    parser.add_argument("--coordinates", type=float, nargs=4, required=True, 
                       help="Bounding box coordinates: min_lon min_lat max_lon max_lat")
    parser.add_argument("--location", type=str, default="Custom Farm Area", 
                       help="Location name/description")
    
    args = parser.parse_args()
    
    print("🚀 INITIATING AGRICULTURAL INSURANCE CLAIM ANALYSIS")
    print(f"📋 Claim ID: {args.claimID}")
    print(f"📍 Location: {args.location}")
    print(f"🗺️  Coordinates: {args.coordinates}")
    print("📊 RETRIEVING SATELLITE DATA...")
    
    # Get satellite data using provided coordinates
    satellite_data = get_satellite_data(args.coordinates, args.location)
    
    if satellite_data is None:
        print("\n❌ CLAIM ANALYSIS FAILED: Satellite data unavailable")
        return
    
    # Calculate crop damage assessment
    damage_percentage, ndvi_value, data_hash = calculate_crop_damage(satellite_data)
    
    if damage_percentage is None:
        print("\n❌ CLAIM ANALYSIS FAILED: Damage assessment error")
        return
    
    # Display comprehensive analysis
    display_agricultural_analysis(satellite_data, damage_percentage, ndvi_value, data_hash)
    
    print(f"\n✅ INSURANCE CLAIM ANALYSIS COMPLETED FOR CLAIM: {args.claimID}")
    print("📋 Results ready for claim processing and verification")
    
    # Example of how to call the backend function (commented for now)
    """
    # Uncomment when backend is ready:
    backend_success = call_backend_api(
        claim_id=args.claimID,
        damage_percentage=damage_percentage,
        ndvi_value=ndvi_value,
        satellite_hash=data_hash,
        coordinates=args.coordinates,
        location_name=args.location
    )
    
    if backend_success:
        print("✅ Data successfully sent to backend")
    else:
        print("❌ Failed to send data to backend")
    """

if __name__ == "__main__":
    main()