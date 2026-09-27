import 'package:flutter/material.dart';
import '../services/getProjects_service.dart';
import '../services/findUserById_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _getProjectsService = GetProjectsService();
  final _findUserByIdService = FindUserByIdService();
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final result = await _getProjectsService.getProjects();

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.message ?? 'Não foi possível carregar os projetos.';
      });
      return;
    }

    final responseData = result.data;
    final projectsData = responseData is Map<String, dynamic>
        ? responseData['data']
        : null;

    final projects = projectsData is List
        ? projectsData
              .whereType<Map>()
              .map((project) => Map<String, dynamic>.from(project))
              .toList()
        : <Map<String, dynamic>>[];

    await Future.wait(
      projects.map((project) async {
        final userId = project['userId'] as String?;
        if (userId == null || userId.isEmpty) return;

        final userResult = await _findUserByIdService.findUserById(userId);
        if (!userResult.success) return;

        final userData = userResult.data;
        if (userData is! Map<String, dynamic>) return;

        final user = userData['data'];
        if (user is Map<String, dynamic> && user['email'] is String) {
          project['creatorEmail'] = user['email'];
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _projects = projects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Boost Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF161B2E),
      ),
      backgroundColor: const Color(0xFFF4F6FB),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF536DFE)),
            )
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFF263238)),
                textAlign: TextAlign.center,
              ),
            )
          : _projects.isEmpty
          ? const Center(
              child: Text(
                'Nenhum projeto encontrado.',
                style: TextStyle(color: Color(0xFF263238)),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 3
                    : constraints.maxWidth >= 650
                    ? 2
                    : 1;
                final horizontalPadding = constraints.maxWidth >= 650
                    ? 32.0
                    : 16.0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    28,
                    horizontalPadding,
                    28,
                  ),
                  children: [
                    const Text(
                      'Descubra projetos que estão fazendo a diferença',
                      style: TextStyle(
                        color: Color(0xFF161B2E),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Encontre ideias promissoras e oportunidades para fazer parte.',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _projects.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: columns == 1
                            ? 0.95
                            : columns == 2
                            ? 0.78
                            : 0.82,
                      ),
                      itemBuilder: (context, index) =>
                          _projectCard(_projects[index]),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _projectCard(Map<String, dynamic> project) {
    final name = project['name'] as String? ?? 'Projeto sem nome';
    final resume = project['resume'] as String? ?? '';
    final city = project['city'] as String? ?? '';
    final state = project['state'] as String? ?? '';
    final sector = project['sector'] as String? ?? '';
    final status = project['status'] as String? ?? '';
    final imageUrl = project['projectImageUrl'] as String?;
    final creatorEmail = project['creatorEmail'] as String?;
    final location = [
      city,
      state,
    ].where((value) => value.isNotEmpty).join(', ');

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 132,
            width: double.infinity,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (sector.isNotEmpty)
                        _tag(
                          sector,
                          const Color(0xFFE7E9FF),
                          const Color(0xFF4353D8),
                        ),
                      if (status.isNotEmpty)
                        _tag(
                          status,
                          const Color(0xFFE8F7EF),
                          const Color(0xFF16834B),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF161B2E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (resume.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      resume,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (location.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: Color(0xFF667085),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: creatorEmail == null || creatorEmail.isEmpty
                          ? null
                          : () => _contactCreator(creatorEmail),
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: const Text('Entrar em contato'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4353D8),
                        side: const BorderSide(color: Color(0xFF4353D8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactCreator(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Interesse no projeto Boost Help'},
    );

    if (await launchUrl(uri)) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir o aplicativo de e-mail.'),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent
      ),
      child: const Center(
        child: Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 42),
      ),
    );
  }

  Widget _tag(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
