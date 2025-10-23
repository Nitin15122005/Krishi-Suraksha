// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ClaimsListPage extends StatelessWidget {
  final String status;
  final Color statusColor;

  const ClaimsListPage({
    super.key,
    required this.status,
    required this.statusColor,
  });

  // TODO: BACKEND - Replace with actual API data from blockchain and Firebase
  List<ClaimModel> _getClaimsData() {
    switch (status) {
      case 'pending':
        return [
          ClaimModel(
            claimId: 'CLM-001',
            farmId: 'FARM_001',
            farmerId: 'FARMER_001',
            reason: 'Heavy rainfall caused harvest loss',
            status: 'Pending',
            damagePercentage: 0.0, // Will be set by satellite analysis
            payoutAmount: 0.0, // Will be calculated
          ),
          ClaimModel(
            claimId: 'CLM-002',
            farmId: 'FARM_002',
            farmerId: 'FARMER_001',
            reason: 'Pest infestation in corn field',
            status: 'Pending',
            damagePercentage: 0.0,
            payoutAmount: 0.0,
          ),
        ];
      case 'approved':
        return [
          ClaimModel(
            claimId: 'CLM-004',
            farmId: 'FARM_001',
            farmerId: 'FARMER_001',
            reason: 'Storm damage to corn crops',
            status: 'Approved',
            damagePercentage: 65.3, // From satellite analysis
            payoutAmount: 12500.0,
            satelliteDataHash: 'abc123hash',
          ),
          ClaimModel(
            claimId: 'CLM-005',
            farmId: 'FARM_002',
            farmerId: 'FARMER_001',
            reason: 'Fungal disease outbreak',
            status: 'Approved',
            damagePercentage: 45.2,
            payoutAmount: 9800.0,
            satelliteDataHash: 'def456hash',
          ),
        ];
      case 'rejected':
        return [
          ClaimModel(
            claimId: 'CLM-006',
            farmId: 'FARM_001',
            farmerId: 'FARMER_001',
            reason: 'Soil erosion due to heavy winds',
            status: 'Rejected',
            damagePercentage: 15.0,
            payoutAmount: 0.0,
            rejectionReason: 'Damage percentage below threshold',
          ),
        ];
      case 'human_review':
        return [
          ClaimModel(
            claimId: 'CLM-007',
            farmId: 'FARM_001',
            farmerId: 'FARMER_001',
            reason: 'Unusual weather pattern damage',
            status: 'Human_Review',
            damagePercentage: 55.0,
            payoutAmount: 0.0,
            assignedAuditor: 'AUDITOR_001',
          ),
        ];
      default:
        return [];
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'pending':
        return 'Pending Claims';
      case 'approved':
        return 'Approved Claims';
      case 'rejected':
        return 'Rejected Claims';
      case 'human_review':
        return 'Under Review';
      case 'all':
        return 'All Claims';
      default:
        return 'Claims';
    }
  }

  @override
  Widget build(BuildContext context) {
    final claims = _getClaimsData();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getStatusTitle(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: claims.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];
                return _ClaimCard(
                  claim: claim,
                  status: status,
                  statusColor: statusColor,
                  onTap: () {
                    // TODO: Navigate to claim details page
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getStatusTitle().toLowerCase()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any ${_getStatusTitle().toLowerCase()} at the moment',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _ClaimCard({
    required this.claim,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Claim ${claim.claimId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Farm: ${claim.farmId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(claim.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              claim.reason,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            if (claim.damagePercentage > 0) ...[
              Row(
                children: [
                  Icon(Icons.satellite_alt, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Damage: ${claim.damagePercentage}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (claim.payoutAmount > 0) ...[
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Payout: ₹${claim.payoutAmount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (claim.assignedAuditor != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Auditor: ${claim.assignedAuditor}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // ignore: prefer_const_constructors
              SizedBox(height: 8),
            ],
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claim ID',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      claim.claimId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Filed',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      claim.createdAt != null
                          ? '${claim.createdAt!.day}/${claim.createdAt!.month}/${claim.createdAt!.year}'
                          : 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      claim.payoutAmount > 0
                          ? '₹${claim.payoutAmount}'
                          : 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: claim.payoutAmount > 0
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'PENDING';
      case 'Approved':
        return 'APPROVED';
      case 'Rejected':
        return 'REJECTED';
      case 'Human_Review':
        return 'UNDER REVIEW';
      default:
        return status.toUpperCase();
    }
  }
}
