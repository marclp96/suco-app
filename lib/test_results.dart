import 'package:flutter/material.dart';

class MindfulnessResultsPage extends StatelessWidget {
  const MindfulnessResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildHeader(context),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall score card
                    _buildOverallScoreCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Section header
                    _buildSectionHeader(),
                    
                    const SizedBox(height: 16),
                    
                    // Dimension cards
                    _buildDimensionCards(),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    _buildActionButtons(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with back button, title, and share button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundedIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          Text(
            'Mindfulness Test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          RoundedIconButton(
            icon: Icons.share,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Overall mindfulness score card
  Widget _buildOverallScoreCard() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mindfulness Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '74/100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Moderately Mindful',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Your mindfulness level indicates a good foundation in present-moment awareness with room for growth. You demonstrate solid understanding of mindfulness principles and show consistent practice in several key areas.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Section header for dimensions
  Widget _buildSectionHeader() {
    return Text(
      'Key Mindfulness Dimensions',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // All dimension score cards
  Widget _buildDimensionCards() {
    final dimensions = [
      DimensionData(
        title: 'Present Moment\nAwareness',
        score: 78,
        description: 'Strong ability to stay present. Focus on maintaining awareness during routine activities to strengthen this skill further.',
      ),
      DimensionData(
        title: 'Non Judgmental\nAcceptance',
        score: 75,
        description: 'Moderate acceptance of experiences. Practice observing thoughts and feelings without immediate judgment or reaction.',
      ),
      DimensionData(
        title: 'Emotional Regulation',
        score: 71,
        description: 'Good emotional balance. Continue developing skills to respond rather than react to challenging emotions.',
      ),
      DimensionData(
        title: 'Attention Focus',
        score: 82,
        description: 'Excellent concentration abilities. Your focused attention is a significant strength in your mindfulness practice.',
      ),
      DimensionData(
        title: 'Self Compassion',
        score: 69,
        description: 'Developing self-kindness. Practice treating yourself with the same compassion you would offer a good friend.',
      ),
    ];

    return Column(
      children: dimensions.map((dimension) {
        final index = dimensions.indexOf(dimension);
        return Padding(
          padding: EdgeInsets.only(bottom: index == dimensions.length - 1 ? 0 : 24),
          child: DimensionCard(dimension: dimension),
        );
      }).toList(),
    );
  }

  // Bottom action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Start Guided Practice',
          onTap: () {},
        ),
        
        const SizedBox(height: 16),
        
        SecondaryButton(
          text: 'View Detailed Report 👑',
          onTap: () {},
        ),
      ],
    );
  }
}

// Data model for dimension information
class DimensionData {
  final String title;
  final int score;
  final String description;

  DimensionData({
    required this.title,
    required this.score,
    required this.description,
  });
}

// Individual dimension score card
class DimensionCard extends StatelessWidget {
  final DimensionData dimension;

  const DimensionCard({
    super.key,
    required this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dimension.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                '${dimension.score}/100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ProgressBar(value: dimension.score / 100),
          
          const SizedBox(height: 16),
          
          Text(
            dimension.description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable card container
class CardContainer extends StatelessWidget {
  final Widget child;

  const CardContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

// Reusable rounded icon button (consistent with previous pages)
class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Progress bar with new green color
class ProgressBar extends StatelessWidget {
  final double value;

  const ProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF404040),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCBFBC7),  
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// Primary button with new green color
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      child: Material(
        color: const Color(0xFFCBFBC7), 
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          splashColor: Colors.black.withOpacity(0.1),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Secondary button with new green accent
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFCBFBC7), 
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          splashColor: const Color(0xFFCBFBC7).withOpacity(0.1),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFCBFBC7), 
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}