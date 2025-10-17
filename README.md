# Krishi Suraksha
AI-powered crop insurance system for Indian farmers. Uses satellite imagery to automatically assess crop damage from natural calamities. Farmers submit claims via mobile app, system analyzes NDVI data vs historical patterns, and processes payouts via blockchain. Eliminates manual verification delays.


# 🌾 Agri-Claim: AI-Powered Crop Insurance System

A revolutionary insurance claim system for Indian farmers that uses satellite imagery and blockchain technology to automate crop damage assessment and claim processing.

## 🚀 Overview

Agri-Claim leverages **remote sensing** and **artificial intelligence** to help farmers get instant insurance payouts when their crops are destroyed by natural calamities like floods, droughts, or excessive rainfall. By analyzing satellite data in real-time, we eliminate lengthy manual verification processes and provide transparent, automated claim settlements.

## ✨ Key Features

### 🌍 Satellite-Powered Damage Assessment
- **Real-time NDVI Analysis**: Uses Sentinel-2 satellite imagery to calculate Normalized Difference Vegetation Index
- **Historical Comparison**: Compares current crop health with 3-year historical data
- **Automated Verification**: AI-driven damage percentage calculation
- **Cloud-Based Processing**: No manual field visits required

### 📱 Farmer-Friendly Mobile App
- **Farm Registration**: Draw farm boundaries directly on maps
- **Easy Claim Submission**: Simple 3-step claim process
- **Real-time Tracking**: Live claim status updates
- **Document Management**: Upload land records and documents

### ⛓️ Blockchain Transparency
- **Hyperledger Fabric**: Permissioned blockchain for all transactions
- **Immutable Records**: Tamper-proof claim history
- **Smart Contracts**: Automated payout triggers
- **Multi-party Access**: Insurance companies, government, and farmers

### 🎯 India-Specific Integration
- **7/12 Document Support**: Native land record integration
- **PMFBY Compliance**: Compatible with Pradhan Mantri Fasal Bima Yojana
- **Multi-language Support**: Available in Hindi and English
- **Offline Capability**: Work without internet connectivity

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile app
- **Google Maps** - Farm boundary mapping
- **Provider** - State management

### Backend
- **Go (Fiber Framework)** - High-performance API server
- **PostgreSQL** - Primary database
- **Redis** - Caching and sessions

### Satellite Analysis
- **Python** - NDVI calculation and analysis
- **Sentinel Hub API** - Satellite imagery access
- **FastAPI** - Microservice for image processing
- **NumPy/Geopandas** - Geospatial data processing

### Blockchain
- **Hyperledger Fabric** - Enterprise blockchain
- **Chaincode (Go)** - Smart contracts for claim processing

### Infrastructure
- **Docker** - Containerization
- **GitHub Actions** - CI/CD Pipeline
- **AWS/GCP** - Cloud deployment

## 🎯 How It Works

1. **Registration**: Farmer registers with land details and documents
2. **Farm Mapping**: Farmer draws farm boundary using interactive maps
3. **Claim Submission**: Farmer submits claim with calamity details
4. **Satellite Analysis**: System fetches current and historical satellite data
5. **NDVI Calculation**: AI calculates crop health and damage percentage
6. **Blockchain Recording**: Claim details stored on immutable ledger
7. **Auto-Processing**: System approves/rejects based on damage threshold
8. **Payout**: Approved claims trigger automatic bank transfers
