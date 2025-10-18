import 'package:flutter/material.dart';

class ClaimsListPage extends StatelessWidget {
  final String status;
  final Color statusColor;

  const ClaimsListPage({
    super.key,
    required this.status,
    required this.statusColor,
  });

  // TODO: BACKEND - Replace with actual API data
  List<Map<String, dynamic>> _getClaimsData() {
    switch (status) {
      case 'pending':
        return [
          {
            'id': 'CLM-001',
            'title': 'Wheat Harvest Loss',
            'date': 'Dec 10, 2024',
            'amount': '₹8,200',
            'crop': 'Wheat',
            'description': 'Heavy rainfall caused harvest loss',
          },
          {
            'id': 'CLM-002',
            'title': 'Corn Pest Attack',
            'date': 'Dec 05, 2024',
            'amount': '₹12,500',
            'crop': 'Corn',
            'description': 'Pest infestation in corn field',
          },
          {
            'id': 'CLM-003',
            'title': 'Rice Flood Damage',
            'date': 'Nov 28, 2024',
            'amount': '₹15,000',
            'crop': 'Rice',
            'description': 'Flood damage to rice plantation',
          },
        ];
      case 'approved':
        return [
          {
            'id': 'CLM-004',
            'title': 'Corn Crop Damage',
            'date': 'Dec 15, 2024',
            'amount': '₹12,500',
            'crop': 'Corn',
            'description': 'Storm damage to corn crops',
          },
          {
            'id': 'CLM-005',
            'title': 'Soybean Disease',
            'date': 'Nov 20, 2024',
            'amount': '₹9,800',
            'crop': 'Soybean',
            'description': 'Fungal disease outbreak',
          },
        ];
      case 'rejected':
        return [
          {
            'id': 'CLM-006',
            'title': 'Soil Erosion',
            'date': 'Nov 15, 2024',
            'amount': '₹15,000',
            'crop': 'Multiple',
            'description': 'Soil erosion due to heavy winds',
          },
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
  final Map<String, dynamic> claim;
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
                        claim['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crop: ${claim['crop']}',
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
                    status.toUpperCase(),
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
              claim['description'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
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
                      claim['id'],
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
                      claim['date'],
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
                      claim['amount'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
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
}
