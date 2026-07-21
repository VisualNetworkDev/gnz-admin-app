// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unnecessary_underscores, deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'gnz_api.dart';
import 'updater.dart';

typedef JsonMap = Map<String, dynamic>;

const String appVersion = '1.0.6';
const String updateManifestUrl =
    'https://visualnetworkdev.github.io/gnzoilservices/updates/gnz-admin-pro/latest.json';

void main() {
  runApp(const GnzAdminProApp());
}

class GnzAdminProApp extends StatelessWidget {
  const GnzAdminProApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF063F4C);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GNZ Admin Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          primary: seed,
          secondary: const Color(0xFFB7222A),
          surface: const Color(0xFFFFFBF6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3EFE7),
        fontFamily: 'Segoe UI',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8D0C3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8D0C3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seed, width: 1.6),
          ),
        ),
      ),
      home: const AdminShell(),
    );
  }
}

enum AdminSection { citas, aceite, frenos, tracking, catalogo, seguridad }

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _api = GnzApi();
  final _updater = GnzUpdater(manifestUrl: updateManifestUrl);
  String _token = '';
  AdminSection _section = AdminSection.citas;
  bool _busy = false;
  String _busyTitle = 'Procesando';
  String _busyText = 'Sincronizando con GNZ';

  List<JsonMap> _reservas = [];
  JsonMap _summary = {};
  String _selectedReservationId = '';

  final _loginPassword = TextEditingController();
  final _queryFilter = TextEditingController();
  String _statusFilter = '';
  String _serviceFilter = '';
  final _dateFilter = TextEditingController();

  List<JsonMap> _vehicles = [];
  bool _vehiclesLoaded = false;
  String? _oilMake;
  String? _oilModel;
  String? _oilYear;
  String? _oilEngine;
  String? _oilBrand;
  List<String> _oilBrands = [];
  JsonMap? _oilQuote;
  bool _oilAgreement = true;
  bool _oilNotify = true;
  final _oilName = TextEditingController();
  final _oilPhone = TextEditingController();
  final _oilEmail = TextEditingController();
  final _oilDate = TextEditingController();
  final _oilTime = TextEditingController();
  final _oilAddress = TextEditingController();
  final _oilComment = TextEditingController();

  String _brakeService = 'pads';
  String _brakeBody = 'sedan';
  String _brakeAxles = '1';
  String _brakeFlush = 'regular';
  bool _brakeAgreement = true;
  bool _brakeNotify = true;
  final _brakeName = TextEditingController();
  final _brakePhone = TextEditingController();
  final _brakeEmail = TextEditingController();
  final _brakeYear = TextEditingController();
  final _brakeMake = TextEditingController();
  final _brakeModel = TextEditingController();
  final _brakeDate = TextEditingController();
  final _brakeTime = TextEditingController();
  final _brakeAddress = TextEditingController();
  final _brakeComment = TextEditingController();

  final _trackingName = TextEditingController();
  final _trackingContact = TextEditingController();
  JsonMap? _trackingAppointment;
  List<JsonMap> _trackingHistory = [];

  bool _catalogLoaded = false;
  List<JsonMap> _catalogVehicles = [];
  List<JsonMap> _catalogPrices = [];
  final _catalogVehicleSearch = TextEditingController();
  final _catalogPriceSearch = TextEditingController();
  JsonMap? _selectedVehicle;
  JsonMap? _selectedPrice;
  final _vehYear = TextEditingController();
  final _vehMake = TextEditingController();
  final _vehModel = TextEditingController();
  final _vehEngine = TextEditingController();
  final _vehCapacity = TextEditingController();
  final _vehOil = TextEditingController();
  final _vehFilter = TextEditingController();
  final _vehAltFilter = TextEditingController();
  final _priceType = TextEditingController();
  final _priceBrand = TextEditingController();
  final _priceDescription = TextEditingController();
  final _priceBase = TextEditingController();
  final _priceExtra = TextEditingController();
  final _priceFilter = TextEditingController();
  final _priceLabor = TextEditingController();
  final _priceDisposal = TextEditingController();

  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  JsonMap? _auditData;
  UpdateManifest? _latestUpdate;
  bool _checkingUpdate = false;
  bool _downloadingUpdate = false;
  double _downloadProgress = 0;
  String _updateMessage = 'No se ha revisado todavia.';

  bool get _hasPendingUpdate =>
      Platform.isWindows &&
      _latestUpdate != null &&
      compareVersions(_latestUpdate!.version, appVersion) > 0;

  @override
  void dispose() {
    for (final c in [
      _loginPassword,
      _queryFilter,
      _dateFilter,
      _oilName,
      _oilPhone,
      _oilEmail,
      _oilDate,
      _oilTime,
      _oilAddress,
      _oilComment,
      _brakeName,
      _brakePhone,
      _brakeEmail,
      _brakeYear,
      _brakeMake,
      _brakeModel,
      _brakeDate,
      _brakeTime,
      _brakeAddress,
      _brakeComment,
      _trackingName,
      _trackingContact,
      _catalogVehicleSearch,
      _catalogPriceSearch,
      _vehYear,
      _vehMake,
      _vehModel,
      _vehEngine,
      _vehCapacity,
      _vehOil,
      _vehFilter,
      _vehAltFilter,
      _priceType,
      _priceBrand,
      _priceDescription,
      _priceBase,
      _priceExtra,
      _priceFilter,
      _priceLabor,
      _priceDisposal,
      _currentPassword,
      _newPassword,
      _confirmPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token.isEmpty) return _buildLogin();
    final compact = _isCompact(context);
    return Stack(
      children: [
        Scaffold(
          appBar: compact
              ? AppBar(
                  backgroundColor: const Color(0xFFFFFBF6),
                  foregroundColor: const Color(0xFF063F4C),
                  elevation: 0,
                  title: Text(
                    _title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Refrescar datos',
                      onPressed: _refreshSection,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              : null,
          drawer: compact ? Drawer(child: _buildSidebar()) : null,
          body: compact
              ? _animatedSectionBody()
              : Row(
                  children: [
                    _buildSidebar(),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTopbar(),
                          Expanded(child: _animatedSectionBody()),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        if (_busy) _busyOverlay(),
      ],
    );
  }

  Widget _buildLogin() {
    if (_isCompact(context)) return _buildMobileLogin();
    return Scaffold(
      body: Center(
        child: Container(
          width: 980,
          height: 620,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 40,
                offset: Offset(0, 22),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(34),
                  decoration: const BoxDecoration(
                    color: Color(0xFF063F4C),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/gnz-logo.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'GNZ Admin Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Consola nativa para citas, clientes, catalogo de vehiculos, filtros y servicios moviles.',
                        style: TextStyle(
                          color: Color(0xFFE9F5F3),
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                      const Spacer(),
                      const _MiniPill(label: 'Backend Apps Script', dark: true),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(44),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFBF6),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Acceso administrativo',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      const Text('Entra con la clave actual del panel GNZ.'),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _loginPassword,
                        obscureText: true,
                        onSubmitted: (_) => _login(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Clave admin',
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Entrar al panel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLogin() {
    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/gnz-logo.png',
                    width: 112,
                    height: 112,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'GNZ Admin Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF063F4C),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Panel interno para citas, clientes, catalogo y servicios moviles.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF637174), height: 1.35),
              ),
              const SizedBox(height: 26),
              _panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                      'Acceso administrativo',
                      'Entra con la clave actual del panel GNZ.',
                    ),
                    TextField(
                      controller: _loginPassword,
                      obscureText: true,
                      onSubmitted: (_) => _login(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Clave admin',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Entrar al panel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final compact = _isCompact(context);
    return SafeArea(
      top: compact,
      bottom: compact,
      child: Container(
        width: compact ? double.infinity : 260,
        color: const Color(0xFF08333D),
        padding: EdgeInsets.fromLTRB(18, compact ? 18 : 20, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/gnz-logo.png',
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GNZ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'ADMIN PRO',
                        style: TextStyle(
                          color: Color(0xFFE5BE6D),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _navButton(AdminSection.citas, Icons.calendar_month, 'Citas'),
                  _navButton(
                    AdminSection.aceite,
                    Icons.oil_barrel,
                    'Reservar aceite',
                  ),
                  _navButton(
                    AdminSection.frenos,
                    Icons.build_circle,
                    'Frenos / fluidos',
                  ),
                  _navButton(
                    AdminSection.tracking,
                    Icons.manage_search,
                    'Tracking cliente',
                  ),
                  _navButton(
                    AdminSection.catalogo,
                    Icons.inventory_2,
                    'Catalogo',
                  ),
                  _navButton(
                    AdminSection.seguridad,
                    Icons.admin_panel_settings,
                    'Seguridad',
                  ),
                ],
              ),
            ),
            if (_hasPendingUpdate || _downloadingUpdate) ...[
              _sidebarUpdateButton(),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () => setState(() => _token = ''),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x447A9AA2)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarUpdateButton() {
    final latest = _latestUpdate;
    if (!_hasPendingUpdate && !_downloadingUpdate) {
      return const SizedBox.shrink();
    }
    final label = _downloadingUpdate
        ? 'Descargando...'
        : 'Instalar v${latest?.version ?? ''}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D4652),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CB6C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _downloadingUpdate ? 'Actualizando app' : 'Nueva version lista',
            style: TextStyle(
              color: Color(0xFFBCD4D8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _downloadingUpdate
                ? 'Preparando instalador'
                : 'GNZ Admin Pro ${latest?.version ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _downloadingUpdate ? null : _downloadAndRunUpdate,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB7222A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(AdminSection section, IconData icon, String label) {
    final active = _section == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() => _section = section);
          if (section == AdminSection.aceite) _ensureVehiclesLoaded();
          if (section == AdminSection.catalogo) _ensureCatalogLoaded();
          if (section == AdminSection.seguridad) _loadAudit();
          if (_isCompact(context)) Navigator.of(context).maybePop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF214A53) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: active
                ? const Border(
                    left: BorderSide(color: Color(0xFFE5BE6D), width: 4),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: active
                    ? const Color(0xFFE5BE6D)
                    : const Color(0xFFDCE8E7),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopbar() {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF6),
        border: Border(bottom: BorderSide(color: Color(0xFFE2D9CB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eyebrow(),
                  style: const TextStyle(
                    color: Color(0xFFB7222A),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _title(),
                  style: const TextStyle(
                    color: Color(0xFF063F4C),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const _MiniPill(label: 'Sistema conectado'),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _refreshSection,
            icon: const Icon(Icons.refresh),
            label: const Text('Refrescar datos'),
          ),
        ],
      ),
    );
  }

  Widget _sectionBody() {
    return switch (_section) {
      AdminSection.citas => _buildAppointments(),
      AdminSection.aceite => _buildOilBooking(),
      AdminSection.frenos => _buildBrakeBooking(),
      AdminSection.tracking => _buildTracking(),
      AdminSection.catalogo => _buildCatalog(),
      AdminSection.seguridad => _buildSecurity(),
    };
  }

  Widget _animatedSectionBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0.018, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(_section), child: _sectionBody()),
    );
  }

  Widget _busyOverlay() {
    return Positioned.fill(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, value, child) =>
              Opacity(opacity: value, child: child),
          child: Container(
            color: const Color(0x990B1517),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2D9CB)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 34,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 38,
                          height: 38,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: Color(0xFF063F4C),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _busyTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF063F4C),
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _busyText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF637174),
                                  decoration: TextDecoration.none,
                                  fontSize: 13,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointments() {
    final selected = _reservas.cast<JsonMap?>().firstWhere(
      (r) => text(r?['id']) == _selectedReservationId,
      orElse: () => _reservas.isNotEmpty ? _reservas.first : null,
    );

    if (_isCompact(context)) {
      return _screenPadding(
        ListView(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _mobileStatTile(
                  'Pendientes',
                  _summary['pendientes'],
                  Icons.pending_actions,
                ),
                _mobileStatTile(
                  'Confirmadas',
                  _summary['confirmadas'],
                  Icons.verified,
                ),
                _mobileStatTile('Hoy', _summary['hoy'], Icons.today),
                _mobileStatTile(
                  'Completadas',
                  _summary['completadas'],
                  Icons.task_alt,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _appointmentFilters(),
                  const SizedBox(height: 12),
                  if (_reservas.isEmpty)
                    _empty('No hay citas con esos filtros.')
                  else
                    for (final reserva in _reservas.take(60)) ...[
                      _appointmentRow(reserva),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _appointmentDetail(selected),
          ],
        ),
      );
    }

    return _screenPadding(
      Column(
        children: [
          Row(
            children: [
              _stat(
                'Pendientes',
                _summary['pendientes'],
                Icons.pending_actions,
              ),
              _stat('Confirmadas', _summary['confirmadas'], Icons.verified),
              _stat('Hoy', _summary['hoy'], Icons.today),
              _stat('Completadas', _summary['completadas'], Icons.task_alt),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: _panel(
                    child: Column(
                      children: [
                        _appointmentFilters(),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _reservas.isEmpty
                              ? _empty('No hay citas con esos filtros.')
                              : ListView.separated(
                                  itemCount: _reservas.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, i) =>
                                      _appointmentRow(_reservas[i]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: _appointmentDetail(selected)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileStatTile(String label, dynamic value, IconData icon) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 38) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2D9CB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF063F4C)),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF637174),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              text(value, fallback: '0'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF063F4C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appointmentFilters() {
    if (_isCompact(context)) {
      return Column(
        children: [
          TextField(
            controller: _queryFilter,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar cliente, telefono, email, vehiculo o ID',
            ),
            onSubmitted: (_) => _loadReservations(),
          ),
          const SizedBox(height: 10),
          _dropdown(
            label: 'Estado',
            value: _statusFilter,
            items: const [
              '',
              'Pendiente',
              'Confirmada',
              'Cancelada',
              'Completada',
            ],
            labels: const {'': 'Todos'},
            onChanged: (v) {
              setState(() => _statusFilter = v ?? '');
              _loadReservations();
            },
          ),
          const SizedBox(height: 10),
          _dropdown(
            label: 'Servicio',
            value: _serviceFilter,
            items: const ['', 'oil', 'brake', 'flush'],
            labels: const {
              '': 'Todos',
              'oil': 'Aceite',
              'brake': 'Frenos',
              'flush': 'Flush',
            },
            onChanged: (v) {
              setState(() => _serviceFilter = v ?? '');
              _loadReservations();
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dateFilter,
            decoration: const InputDecoration(
              labelText: 'Fecha',
              hintText: 'YYYY-MM-DD',
            ),
            onSubmitted: (_) => _loadReservations(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loadReservations,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _queryFilter,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar cliente, telefono, email, vehiculo o ID',
            ),
            onSubmitted: (_) => _loadReservations(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdown(
            label: 'Estado',
            value: _statusFilter,
            items: const [
              '',
              'Pendiente',
              'Confirmada',
              'Cancelada',
              'Completada',
            ],
            labels: const {'': 'Todos'},
            onChanged: (v) {
              setState(() => _statusFilter = v ?? '');
              _loadReservations();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdown(
            label: 'Servicio',
            value: _serviceFilter,
            items: const ['', 'oil', 'brake', 'flush'],
            labels: const {
              '': 'Todos',
              'oil': 'Aceite',
              'brake': 'Frenos',
              'flush': 'Flush',
            },
            onChanged: (v) {
              setState(() => _serviceFilter = v ?? '');
              _loadReservations();
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: TextField(
            controller: _dateFilter,
            decoration: const InputDecoration(
              labelText: 'Fecha',
              hintText: 'YYYY-MM-DD',
            ),
            onSubmitted: (_) => _loadReservations(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          onPressed: _loadReservations,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _appointmentRow(JsonMap r) {
    final active = text(r['id']) == _selectedReservationId;
    if (_isCompact(context)) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedReservationId = text(r['id'])),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEAF6F3) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _twoLine(
                      text(r['nombre'], fallback: 'Cliente'),
                      text(r['telefono'], fallback: text(r['correo'])),
                    ),
                  ),
                  _statusChip(text(r['estado'], fallback: 'Pendiente')),
                ],
              ),
              const SizedBox(height: 10),
              _twoLine(vehicleLabel(r), text(r['motor'])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('${text(r['fecha'])} ${text(r['hora'])}'),
                  ),
                  Text(
                    money(r['totalFinal'] ?? r['subtotal']),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedReservationId = text(r['id'])),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF6F3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: _twoLine(
                text(r['fecha'], fallback: 'N/A'),
                text(r['hora']),
              ),
            ),
            Expanded(
              flex: 2,
              child: _twoLine(
                text(r['nombre'], fallback: 'Cliente'),
                text(r['telefono'], fallback: text(r['correo'])),
              ),
            ),
            Expanded(
              flex: 3,
              child: _twoLine(
                vehicleLabel(r),
                [
                  text(r['motor']),
                  text(r['aceiteRecomendado']),
                ].where((e) => e.isNotEmpty).join(' | '),
              ),
            ),
            SizedBox(
              width: 115,
              child: _statusChip(text(r['estado'], fallback: 'Pendiente')),
            ),
            SizedBox(
              width: 90,
              child: Text(
                money(r['totalFinal'] ?? r['subtotal']),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appointmentDetail(JsonMap? r) {
    if (r == null)
      return _panel(child: _empty('Selecciona una cita para ver el detalle.'));
    final isOil = text(r['tipoServicio'], fallback: 'oil') == 'oil';
    final children = [
      Row(
        children: [
          Expanded(
            child: Text(
              text(r['nombre'], fallback: 'Cliente'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF063F4C),
              ),
            ),
          ),
          _statusChip(text(r['estado'], fallback: 'Pendiente')),
        ],
      ),
      Text(
        text(r['id']),
        style: const TextStyle(
          color: Color(0xFF637174),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 18),
      _detailBlock('Contacto', {
        'Telefono': r['telefono'],
        'Correo': r['correo'],
        'Direccion': r['direccion'],
      }),
      _detailBlock('Servicio', {
        'Tipo': serviceLabel(r),
        'Fecha': '${text(r['fecha'])} ${text(r['hora'])}',
        'Total': money(r['totalFinal'] ?? r['subtotal']),
        'Comentarios': r['comentarios'],
      }),
      _detailBlock('Vehiculo', {
        'Vehiculo': vehicleLabel(r),
        'Motor': r['motor'],
        'Aceite': r['aceiteRecomendado'] ?? r['marcaAceite'],
        if (isOil) 'Filtro': r['tipoFiltro'],
        if (isOil) 'Alternativo': r['tipoFiltroAlternativo'],
      }),
      if (isOil &&
          (text(r['currentMileage']).isNotEmpty ||
              text(r['nextOilMileage']).isNotEmpty ||
              text(r['nextOilDate']).isNotEmpty))
        _detailBlock('Proximo aceite', {
          'Millas actuales': r['currentMileage'],
          'Proximas millas': r['nextOilMileage'],
          'Proxima fecha': r['nextOilDate'],
          'Intervalo':
              '${text(r['oilIntervalMiles'])} mi / ${text(r['oilIntervalMonths'])} meses',
        }),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _statusAction(r, 'Confirmada', Icons.verified),
          _statusAction(r, 'Pendiente', Icons.pending_actions),
          _statusAction(r, 'Completada', Icons.task_alt),
          _statusAction(r, 'Cancelada', Icons.cancel),
        ],
      ),
    ];
    if (_isCompact(context)) {
      return _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
    return _panel(child: ListView(children: children));
  }

  Widget _statusAction(JsonMap r, String status, IconData icon) {
    if (text(r['estado']) == status) return const SizedBox.shrink();
    final danger = status == 'Cancelada';
    return FilledButton.tonalIcon(
      onPressed: () => _updateReservationStatus(r, status),
      icon: Icon(icon),
      label: Text(status),
      style: danger
          ? FilledButton.styleFrom(foregroundColor: const Color(0xFFB7222A))
          : null,
    );
  }

  Widget _buildOilBooking() {
    final makes = unique(_vehicles.map((v) => text(v['marca'])));
    final models = unique(
      _vehicles
          .where((v) => text(v['marca']) == text(_oilMake))
          .map((v) => text(v['modelo'])),
    );
    final years = unique(
      _vehicles
          .where(
            (v) =>
                text(v['marca']) == text(_oilMake) &&
                text(v['modelo']) == text(_oilModel),
          )
          .map((v) => text(v['ano'])),
    );
    final engines = unique(
      _vehicles
          .where(
            (v) =>
                text(v['marca']) == text(_oilMake) &&
                text(v['modelo']) == text(_oilModel) &&
                text(v['ano']) == text(_oilYear),
          )
          .map((v) => text(v['motor'])),
    );

    if (_isCompact(context)) {
      return _screenPadding(
        ListView(
          children: [
            _panel(child: _oilBookingForm(makes, models, years, engines)),
            const SizedBox(height: 14),
            _quotePanel(),
          ],
        ),
      );
    }

    return _screenPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: _panel(
              child: ListView(
                children: [
                  _sectionHeader(
                    'Nueva cita de aceite',
                    'Formulario interno con calculo administrativo y recibos PDF.',
                  ),
                  _formGrid([
                    _field(_oilName, 'Nombre completo'),
                    _field(
                      _oilPhone,
                      'Telefono',
                      keyboard: TextInputType.phone,
                    ),
                    _field(
                      _oilEmail,
                      'Email',
                      keyboard: TextInputType.emailAddress,
                      span: 2,
                    ),
                    _dropdown(
                      label: 'Marca',
                      value: _oilMake,
                      items: makes,
                      onChanged: (v) => setState(() {
                        _oilMake = v;
                        _oilModel = null;
                        _oilYear = null;
                        _oilEngine = null;
                        _oilBrand = null;
                        _oilBrands = [];
                        _oilQuote = null;
                      }),
                    ),
                    _dropdown(
                      label: 'Modelo',
                      value: _oilModel,
                      items: models,
                      onChanged: (v) => setState(() {
                        _oilModel = v;
                        _oilYear = null;
                        _oilEngine = null;
                        _oilBrand = null;
                        _oilBrands = [];
                        _oilQuote = null;
                      }),
                    ),
                    _dropdown(
                      label: 'Ano',
                      value: _oilYear,
                      items: years,
                      onChanged: (v) => setState(() {
                        _oilYear = v;
                        _oilEngine = null;
                        _oilBrand = null;
                        _oilBrands = [];
                        _oilQuote = null;
                      }),
                    ),
                    _dropdown(
                      label: 'Motor',
                      value: _oilEngine,
                      items: engines,
                      onChanged: (v) async {
                        setState(() {
                          _oilEngine = v;
                          _oilBrand = null;
                          _oilQuote = null;
                          _oilBrands = [];
                        });
                        await _loadOilBrands();
                      },
                    ),
                    _dropdown(
                      label: 'Marca de aceite',
                      value: _oilBrand,
                      items: _oilBrands,
                      onChanged: (v) async {
                        setState(() {
                          _oilBrand = v;
                          _oilQuote = null;
                        });
                        if (v != null && v.isNotEmpty)
                          await _calculateOilQuote();
                      },
                      span: 2,
                    ),
                    _field(_oilDate, 'Fecha', hint: 'YYYY-MM-DD'),
                    _field(_oilTime, 'Hora', hint: '09:00'),
                    _field(_oilAddress, 'Direccion de servicio', span: 2),
                    _field(_oilComment, 'Comentarios', span: 2, maxLines: 3),
                  ]),
                  const SizedBox(height: 10),
                  _checkTile(
                    'Acuerdo aceptado verbalmente o por el cliente.',
                    _oilAgreement,
                    (v) => setState(() => _oilAgreement = v),
                  ),
                  _checkTile(
                    'Enviar confirmacion y recibo PDF al cliente.',
                    _oilNotify,
                    (v) => setState(() => _oilNotify = v),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _submitOil,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Crear cita'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _quotePanel()),
        ],
      ),
    );
  }

  Widget _quotePanel() {
    final vehicle = _selectedOilVehicle();
    final filter = [
      text(_oilQuote?['tipoFiltro'] ?? vehicle?['tipoFiltro']),
      text(
        _oilQuote?['tipoFiltroAlternativo'] ??
            vehicle?['tipoFiltroAlternativo'],
      ),
    ].where((v) => v.isNotEmpty).join(' / ');
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMADO',
            style: TextStyle(
              color: Color(0xFFB7222A),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _oilQuote == null
                ? 'Selecciona vehiculo y aceite'
                : 'Total ${money(_oilQuote?['total'])}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xFF063F4C),
            ),
          ),
          const SizedBox(height: 18),
          _kv(
            'Aceite recomendado',
            vehicle?['aceite'] ?? _oilQuote?['aceiteRecomendado'],
          ),
          _kv('Capacidad', vehicle?['capacidad']),
          _kv('Filtro', filter),
          _kv('Subtotal aceite', money(_oilQuote?['aceite'])),
          _kv('Mano de obra', money(_oilQuote?['manoObra'])),
          _kv('Desecho', money(_oilQuote?['desecho'])),
          if (_isCompact(context))
            const SizedBox(height: 18)
          else
            const Spacer(),
          _notice(
            'El total es un estimado operativo. Confirma disponibilidad, mercado, filtro y precio final antes de cerrar el servicio.',
          ),
        ],
      ),
    );
  }

  Widget _oilBookingForm(
    List<String> makes,
    List<String> models,
    List<String> years,
    List<String> engines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          'Nueva cita de aceite',
          'Formulario interno con calculo administrativo y recibos PDF.',
        ),
        _formGrid([
          _field(_oilName, 'Nombre completo'),
          _field(_oilPhone, 'Telefono', keyboard: TextInputType.phone),
          _field(
            _oilEmail,
            'Email',
            keyboard: TextInputType.emailAddress,
            span: 2,
          ),
          _dropdown(
            label: 'Marca',
            value: _oilMake,
            items: makes,
            onChanged: (v) => setState(() {
              _oilMake = v;
              _oilModel = null;
              _oilYear = null;
              _oilEngine = null;
              _oilBrand = null;
              _oilBrands = [];
              _oilQuote = null;
            }),
          ),
          _dropdown(
            label: 'Modelo',
            value: _oilModel,
            items: models,
            onChanged: (v) => setState(() {
              _oilModel = v;
              _oilYear = null;
              _oilEngine = null;
              _oilBrand = null;
              _oilBrands = [];
              _oilQuote = null;
            }),
          ),
          _dropdown(
            label: 'Ano',
            value: _oilYear,
            items: years,
            onChanged: (v) => setState(() {
              _oilYear = v;
              _oilEngine = null;
              _oilBrand = null;
              _oilBrands = [];
              _oilQuote = null;
            }),
          ),
          _dropdown(
            label: 'Motor',
            value: _oilEngine,
            items: engines,
            onChanged: (v) async {
              setState(() {
                _oilEngine = v;
                _oilBrand = null;
                _oilQuote = null;
                _oilBrands = [];
              });
              await _loadOilBrands();
            },
          ),
          _dropdown(
            label: 'Marca de aceite',
            value: _oilBrand,
            items: _oilBrands,
            onChanged: (v) async {
              setState(() {
                _oilBrand = v;
                _oilQuote = null;
              });
              if (v != null && v.isNotEmpty) await _calculateOilQuote();
            },
            span: 2,
          ),
          _field(_oilDate, 'Fecha', hint: 'YYYY-MM-DD'),
          _field(_oilTime, 'Hora', hint: '09:00'),
          _field(_oilAddress, 'Direccion de servicio', span: 2),
          _field(_oilComment, 'Comentarios', span: 2, maxLines: 3),
        ]),
        const SizedBox(height: 10),
        _checkTile(
          'Acuerdo aceptado verbalmente o por el cliente.',
          _oilAgreement,
          (v) => setState(() => _oilAgreement = v),
        ),
        _checkTile(
          'Enviar confirmacion y recibo PDF al cliente.',
          _oilNotify,
          (v) => setState(() => _oilNotify = v),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _submitOil,
            icon: const Icon(Icons.add_task),
            label: const Text('Crear cita'),
          ),
        ),
      ],
    );
  }

  Widget _buildBrakeBooking() {
    final quote = _brakeQuote();
    if (_isCompact(context)) {
      return _screenPadding(
        ListView(
          children: [
            _panel(child: _brakeBookingForm()),
            const SizedBox(height: 14),
            _brakeEstimatePanel(quote, compact: true),
          ],
        ),
      );
    }
    return _screenPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: _panel(
              child: ListView(
                children: [
                  _sectionHeader(
                    'Nueva cita de frenos / fluidos',
                    'Formulario interno conectado al flujo administrativo y correos.',
                  ),
                  _formGrid([
                    _field(_brakeName, 'Nombre completo'),
                    _field(
                      _brakePhone,
                      'Telefono',
                      keyboard: TextInputType.phone,
                    ),
                    _field(
                      _brakeEmail,
                      'Email',
                      keyboard: TextInputType.emailAddress,
                      span: 2,
                    ),
                    _dropdown(
                      label: 'Servicio',
                      value: _brakeService,
                      items: const ['pads', 'combo', 'flush'],
                      labels: const {
                        'pads': 'Pads only',
                        'combo': 'Pads + rotors',
                        'flush': 'Brake fluid flush',
                      },
                      onChanged: (v) =>
                          setState(() => _brakeService = v ?? 'pads'),
                    ),
                    _dropdown(
                      label: 'Tipo de vehiculo',
                      value: _brakeBody,
                      items: const ['sedan', 'suv'],
                      labels: const {
                        'sedan': 'Sedan / car',
                        'suv': 'SUV / truck',
                      },
                      onChanged: (v) =>
                          setState(() => _brakeBody = v ?? 'sedan'),
                    ),
                    if (_brakeService != 'flush')
                      _dropdown(
                        label: 'Ejes',
                        value: _brakeAxles,
                        items: const ['1', '2', '3', '4'],
                        onChanged: (v) =>
                            setState(() => _brakeAxles = v ?? '1'),
                      ),
                    if (_brakeService == 'flush')
                      _dropdown(
                        label: 'Flush',
                        value: _brakeFlush,
                        items: const ['regular', 'complete'],
                        labels: const {
                          'regular': 'Regular',
                          'complete': 'Completo',
                        },
                        onChanged: (v) =>
                            setState(() => _brakeFlush = v ?? 'regular'),
                      ),
                    _field(_brakeYear, 'Ano'),
                    _field(_brakeMake, 'Marca'),
                    _field(_brakeModel, 'Modelo'),
                    _field(_brakeDate, 'Fecha', hint: 'YYYY-MM-DD'),
                    _field(_brakeTime, 'Hora', hint: '09:00'),
                    _field(_brakeAddress, 'Direccion de servicio', span: 2),
                    _field(_brakeComment, 'Comentarios', span: 2, maxLines: 3),
                  ]),
                  const SizedBox(height: 10),
                  _checkTile(
                    'Acuerdo de servicio aceptado.',
                    _brakeAgreement,
                    (v) => setState(() => _brakeAgreement = v),
                  ),
                  _checkTile(
                    'Enviar confirmacion y recibo PDF al cliente.',
                    _brakeNotify,
                    (v) => setState(() => _brakeNotify = v),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _submitBrake,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Crear cita'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESTIMADO',
                    style: TextStyle(
                      color: Color(0xFFB7222A),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    quote == null
                        ? 'Selecciona servicio'
                        : 'Total ${money(quote['total'])}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF063F4C),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _kv('Servicio', quote?['service']),
                  _kv(
                    'Vehiculo',
                    _brakeBody == 'suv' ? 'SUV / truck' : 'Sedan / car',
                  ),
                  _kv('Detalle', quote?['detail']),
                  const Spacer(),
                  _notice(
                    'Estimado de labor. Partes, fluidos y condiciones reales del vehiculo pueden cambiar el total final.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brakeBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          'Nueva cita de frenos / fluidos',
          'Formulario interno conectado al flujo administrativo y correos.',
        ),
        _formGrid([
          _field(_brakeName, 'Nombre completo'),
          _field(_brakePhone, 'Telefono', keyboard: TextInputType.phone),
          _field(
            _brakeEmail,
            'Email',
            keyboard: TextInputType.emailAddress,
            span: 2,
          ),
          _dropdown(
            label: 'Servicio',
            value: _brakeService,
            items: const ['pads', 'combo', 'flush'],
            labels: const {
              'pads': 'Pads only',
              'combo': 'Pads + rotors',
              'flush': 'Brake fluid flush',
            },
            onChanged: (v) => setState(() => _brakeService = v ?? 'pads'),
          ),
          _dropdown(
            label: 'Tipo de vehiculo',
            value: _brakeBody,
            items: const ['sedan', 'suv'],
            labels: const {'sedan': 'Sedan / car', 'suv': 'SUV / truck'},
            onChanged: (v) => setState(() => _brakeBody = v ?? 'sedan'),
          ),
          if (_brakeService != 'flush')
            _dropdown(
              label: 'Ejes',
              value: _brakeAxles,
              items: const ['1', '2', '3', '4'],
              onChanged: (v) => setState(() => _brakeAxles = v ?? '1'),
            ),
          if (_brakeService == 'flush')
            _dropdown(
              label: 'Flush',
              value: _brakeFlush,
              items: const ['regular', 'complete'],
              labels: const {'regular': 'Regular', 'complete': 'Completo'},
              onChanged: (v) => setState(() => _brakeFlush = v ?? 'regular'),
            ),
          _field(_brakeYear, 'Ano'),
          _field(_brakeMake, 'Marca'),
          _field(_brakeModel, 'Modelo'),
          _field(_brakeDate, 'Fecha', hint: 'YYYY-MM-DD'),
          _field(_brakeTime, 'Hora', hint: '09:00'),
          _field(_brakeAddress, 'Direccion de servicio', span: 2),
          _field(_brakeComment, 'Comentarios', span: 2, maxLines: 3),
        ]),
        const SizedBox(height: 10),
        _checkTile(
          'Acuerdo de servicio aceptado.',
          _brakeAgreement,
          (v) => setState(() => _brakeAgreement = v),
        ),
        _checkTile(
          'Enviar confirmacion y recibo PDF al cliente.',
          _brakeNotify,
          (v) => setState(() => _brakeNotify = v),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _submitBrake,
            icon: const Icon(Icons.add_task),
            label: const Text('Crear cita'),
          ),
        ),
      ],
    );
  }

  Widget _brakeEstimatePanel(JsonMap? quote, {bool compact = false}) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMADO',
            style: TextStyle(
              color: Color(0xFFB7222A),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            quote == null
                ? 'Selecciona servicio'
                : 'Total ${money(quote['total'])}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xFF063F4C),
            ),
          ),
          const SizedBox(height: 18),
          _kv('Servicio', quote?['service']),
          _kv('Vehiculo', _brakeBody == 'suv' ? 'SUV / truck' : 'Sedan / car'),
          _kv('Detalle', quote?['detail']),
          if (compact) const SizedBox(height: 18) else const Spacer(),
          _notice(
            'Estimado de labor. Partes, fluidos y condiciones reales del vehiculo pueden cambiar el total final.',
          ),
        ],
      ),
    );
  }

  Widget _buildTracking() {
    if (_isCompact(context)) {
      return _screenPadding(
        ListView(
          children: [
            _panel(child: _trackingSearchForm()),
            const SizedBox(height: 14),
            _panel(
              child: _trackingAppointment == null
                  ? _empty(
                      'Busca un cliente para ver estado, historial y proximo servicio.',
                    )
                  : _trackingDetail(_trackingAppointment!),
            ),
            const SizedBox(height: 14),
            _panel(child: _trackingHistoryCards()),
          ],
        ),
      );
    }
    return _screenPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 390,
            child: _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeader(
                    'Buscar cliente',
                    'Historial por nombre y telefono o email.',
                  ),
                  _field(_trackingName, 'Nombre completo'),
                  const SizedBox(height: 10),
                  _field(_trackingContact, 'Telefono o email'),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _submitTracking,
                    icon: const Icon(Icons.manage_search),
                    label: const Text('Buscar historial'),
                  ),
                  const SizedBox(height: 18),
                  _notice(
                    'El contacto debe coincidir con la reservacion por privacidad.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _panel(
              child: _trackingAppointment == null
                  ? _empty(
                      'Busca un cliente para ver estado, historial y proximo servicio.',
                    )
                  : Row(
                      children: [
                        Expanded(child: _trackingDetail(_trackingAppointment!)),
                        const SizedBox(width: 16),
                        SizedBox(width: 360, child: _trackingHistoryList()),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingDetail(JsonMap item) {
    final next = asMap(item['nextOilChange']);
    final children = [
      Row(
        children: [
          Expanded(
            child: Text(
              text(item['customerName'], fallback: 'Cliente'),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color(0xFF063F4C),
              ),
            ),
          ),
          _statusChip(text(item['status'], fallback: 'Pendiente')),
        ],
      ),
      Text(
        text(item['id']),
        style: const TextStyle(
          color: Color(0xFF637174),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 18),
      _detailBlock('Servicio', {
        'Tipo': item['serviceSummary'] ?? item['serviceLabel'],
        'Fecha': '${text(item['date'])} ${text(item['time'])}',
        'Vehiculo': item['vehicle'],
        'Total': money(item['total']),
      }),
      if (text(item['serviceType']) == 'oil')
        _detailBlock('Proximo cambio de aceite', {
          'Fecha estimada': next['nextDate'] ?? item['nextOilDate'],
          'Millas estimadas': next['nextMileage'] ?? item['nextOilMileage'],
          'Millas actuales': next['currentMileage'] ?? item['currentMileage'],
          'Intervalo':
              '${text(next['intervalMiles'])} mi / ${text(next['intervalMonths'])} meses',
          'Aceite usado': next['oilType'] ?? item['oilTypeUsed'] ?? item['oil'],
          'Marca usada': next['oilBrand'] ?? item['oilBrandUsed'],
        }),
      _detailBlock('Estado', {'Siguiente paso': item['nextStep']}),
    ];
    if (_isCompact(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return ListView(children: children);
  }

  Widget _trackingSearchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          'Buscar cliente',
          'Historial por nombre y telefono o email.',
        ),
        _field(_trackingName, 'Nombre completo'),
        const SizedBox(height: 10),
        _field(_trackingContact, 'Telefono o email'),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _submitTracking,
          icon: const Icon(Icons.manage_search),
          label: const Text('Buscar historial'),
        ),
        const SizedBox(height: 18),
        _notice(
          'El contacto debe coincidir con la reservacion por privacidad.',
        ),
      ],
    );
  }

  Widget _trackingHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF063F4C),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _trackingHistory.isEmpty
              ? _empty('No hay historial cargado.')
              : ListView.separated(
                  itemCount: _trackingHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = _trackingHistory[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _trackingAppointment = item),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F1E8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text(
                                item['serviceSummary'] ?? item['serviceLabel'],
                                fallback: 'Servicio',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${text(item['vehicle'])} | ${text(item['date'])} ${text(item['time'])}',
                              style: const TextStyle(color: Color(0xFF637174)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _trackingHistoryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Historial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF063F4C),
          ),
        ),
        const SizedBox(height: 12),
        if (_trackingHistory.isEmpty)
          _empty('No hay historial cargado.')
        else
          for (final item in _trackingHistory) ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _trackingAppointment = item),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F1E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _twoLine(
                  text(
                    item['serviceSummary'] ?? item['serviceLabel'],
                    fallback: 'Servicio',
                  ),
                  '${text(item['vehicle'])} | ${text(item['date'])} ${text(item['time'])}',
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _buildCatalog() {
    final compact = _isCompact(context);
    return _screenPadding(
      DefaultTabController(
        length: 2,
        child: _panel(
          child: Column(
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                      'Catalogo GNZ',
                      'Vehiculos, filtros, aceites y precios conectados a Google Sheets.',
                    ),
                    FilledButton.icon(
                      onPressed: () => _ensureCatalogLoaded(force: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recargar'),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _sectionHeader(
                        'Catalogo GNZ',
                        'Vehiculos, filtros, aceites y precios conectados a Google Sheets.',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _ensureCatalogLoaded(force: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recargar'),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              const TabBar(
                tabs: [
                  Tab(text: 'Vehiculos y filtros'),
                  Tab(text: 'Aceites y precios'),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  children: [_catalogVehicleTab(), _catalogPriceTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _catalogVehicleTab() {
    final rows = _catalogVehicles
        .where(
          (v) => _matches(v, _catalogVehicleSearch.text, [
            'ano',
            'marca',
            'modelo',
            'motor',
            'capacidad',
            'aceite',
            'tipoFiltro',
            'tipoFiltroAlternativo',
          ]),
        )
        .take(500)
        .toList();
    return _isCompact(context)
        ? _catalogVehicleTabMobile(rows)
        : _catalogVehicleTabDesktop(rows);
  }

  Widget _catalogVehicleTabMobile(List<JsonMap> rows) {
    return ListView(
      children: [
        TextField(
          controller: _catalogVehicleSearch,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Buscar ano, marca, modelo, motor, filtro o aceite',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: rows.isEmpty
              ? _empty('No hay vehiculos con esa busqueda.')
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _catalogVehicleRow(rows[i]),
                ),
        ),
        const SizedBox(height: 18),
        _vehicleEditor(),
      ],
    );
  }

  Widget _catalogVehicleTabDesktop(List<JsonMap> rows) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              TextField(
                controller: _catalogVehicleSearch,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText:
                      'Buscar ano, marca, modelo, motor, filtro o aceite',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: rows.isEmpty
                    ? _empty('No hay vehiculos con esa busqueda.')
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _catalogVehicleRow(rows[i]),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: _vehicleEditor()),
      ],
    );
  }

  Widget _catalogVehicleRow(JsonMap item) {
    final active =
        text(item['rowNumber']) == text(_selectedVehicle?['rowNumber']);
    if (_isCompact(context)) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _fillVehicle(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEAF6F3) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _twoLine(
                '${text(item['ano'])} ${text(item['marca'])} ${text(item['modelo'])}',
                text(item['motor']),
              ),
              const SizedBox(height: 8),
              Text(
                'Aceite ${text(item['aceite'], fallback: 'N/A')}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                [
                  text(item['tipoFiltro']),
                  text(item['tipoFiltroAlternativo']),
                ].where((e) => e.isNotEmpty).join(' / '),
                style: const TextStyle(color: Color(0xFF637174)),
              ),
            ],
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _fillVehicle(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF6F3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                text(item['ano']),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: _twoLine(
                '${text(item['marca'])} ${text(item['modelo'])}',
                text(item['motor']),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                text(item['aceite']),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              width: 170,
              child: Text(
                [
                  text(item['tipoFiltro']),
                  text(item['tipoFiltroAlternativo']),
                ].where((e) => e.isNotEmpty).join(' / '),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleEditor() {
    final children = [
      _sectionHeader(
        _selectedVehicle == null ? 'Nuevo vehiculo' : 'Editar vehiculo',
        'Guarda cambios directos en la hoja Vehiculos.',
      ),
      _formGrid([
        _field(_vehYear, 'Ano'),
        _field(_vehMake, 'Marca'),
        _field(_vehModel, 'Modelo'),
        _field(_vehEngine, 'Motor'),
        _field(_vehCapacity, 'Capacidad con filtro'),
        _field(_vehOil, 'Aceite recomendado'),
        _field(_vehFilter, 'Filtro'),
        _field(_vehAltFilter, 'Filtro alternativo'),
      ]),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _clearVehicleForm,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
          FilledButton.icon(
            onPressed: _saveVehicle,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
          if (_selectedVehicle != null)
            FilledButton.tonalIcon(
              onPressed: _deleteVehicle,
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFFB7222A),
              ),
            ),
        ],
      ),
    ];
    if (_isCompact(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return ListView(children: children);
  }

  Widget _catalogPriceTab() {
    final rows = _catalogPrices
        .where(
          (p) => _matches(p, _catalogPriceSearch.text, [
            'tipo',
            'marca',
            'descripcion',
          ]),
        )
        .take(500)
        .toList();
    if (_isCompact(context)) {
      return ListView(
        children: [
          TextField(
            controller: _catalogPriceSearch,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar tipo de aceite o marca',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: rows.isEmpty
                ? _empty('No hay precios con esa busqueda.')
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _catalogPriceRow(rows[i]),
                  ),
          ),
          const SizedBox(height: 18),
          _priceEditor(),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              TextField(
                controller: _catalogPriceSearch,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Buscar tipo de aceite o marca',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: rows.isEmpty
                    ? _empty('No hay precios con esa busqueda.')
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _catalogPriceRow(rows[i]),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: _priceEditor()),
      ],
    );
  }

  Widget _catalogPriceRow(JsonMap item) {
    final active =
        text(item['rowNumber']) == text(_selectedPrice?['rowNumber']);
    if (_isCompact(context)) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _fillPrice(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEAF6F3) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _twoLine(
                '${text(item['tipo'])} / ${text(item['marca'])}',
                text(item['descripcion']),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  Text('Base ${money(item['precioBase'])}'),
                  Text('Extra ${money(item['precio1L'])}'),
                  Text('Filtro ${money(item['filtro'])}'),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _fillPrice(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF6F3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF063F4C) : const Color(0xFFE7DED0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _twoLine(
                '${text(item['tipo'])} / ${text(item['marca'])}',
                text(item['descripcion']),
              ),
            ),
            SizedBox(width: 90, child: Text(money(item['precioBase']))),
            SizedBox(
              width: 90,
              child: Text('Extra ${money(item['precio1L'])}'),
            ),
            SizedBox(width: 90, child: Text('Filtro ${money(item['filtro'])}')),
          ],
        ),
      ),
    );
  }

  Widget _priceEditor() {
    final children = [
      _sectionHeader(
        _selectedPrice == null ? 'Nuevo aceite' : 'Editar aceite',
        'Precios usados por las cotizaciones.',
      ),
      _formGrid([
        _field(_priceType, 'Tipo aceite'),
        _field(_priceBrand, 'Marca aceite'),
        _field(_priceDescription, 'Descripcion', span: 2),
        _field(_priceBase, 'Precio base', keyboard: TextInputType.number),
        _field(_priceExtra, 'Extra por litro', keyboard: TextInputType.number),
        _field(_priceFilter, 'Filtro', keyboard: TextInputType.number),
        _field(_priceLabor, 'Mano de obra', keyboard: TextInputType.number),
        _field(_priceDisposal, 'Desecho', keyboard: TextInputType.number),
      ]),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _clearPriceForm,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
          FilledButton.icon(
            onPressed: _savePrice,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
          if (_selectedPrice != null)
            FilledButton.tonalIcon(
              onPressed: _deletePrice,
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFFB7222A),
              ),
            ),
        ],
      ),
    ];
    if (_isCompact(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return ListView(children: children);
  }

  Widget _buildSecurity() {
    final audit = _auditData;
    final summary = asMap(audit?['summary']);
    final catalog = asMap(audit?['catalog']);
    final reservations = asMap(audit?['reservations']);
    final actionableCount = audit == null ? 0 : _actionableAuditCount(catalog);
    final historicalContactCount = audit == null
        ? 0
        : _historicalContactCount(reservations);
    if (_isCompact(context)) {
      return _screenPadding(
        ListView(
          children: [
            _panel(child: _securityPasswordPanel()),
            const SizedBox(height: 14),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeader(
                    'Auditoria del sistema',
                    'Calidad de catalogo, reservas y contactos.',
                  ),
                  FilledButton.icon(
                    onPressed: () => _loadAudit(force: true),
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('Revisar ahora'),
                  ),
                  const SizedBox(height: 16),
                  if (audit == null)
                    _empty('Auditoria no cargada.')
                  else ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _mobileStatTile(
                          'Por revisar',
                          actionableCount,
                          Icons.report_problem,
                        ),
                        _mobileStatTile(
                          'Sin filtro',
                          _countGroup(catalog['vehiclesMissingFilter']),
                          Icons.filter_alt_off,
                        ),
                        _mobileStatTile(
                          'Aceites sin precio',
                          listOfMaps(catalog['missingOilPriceTypes']).length,
                          Icons.oil_barrel,
                        ),
                        _mobileStatTile(
                          'Contactos viejos',
                          historicalContactCount,
                          Icons.history,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _notice(
                      'La auditoria principal cuenta solo problemas accionables del catalogo. Direcciones, telefonos y correos antiguos quedan como referencia historica; las citas nuevas ya se validan antes de guardarse.',
                    ),
                    const SizedBox(height: 14),
                    _auditOverview(summary),
                    const SizedBox(height: 14),
                    _auditBlocks(catalog, reservations),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    return _screenPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 430,
            child: _panel(
              child: ListView(
                children: [
                  _sectionHeader(
                    'Cambiar clave admin',
                    'Actualiza la clave del panel desde la app.',
                  ),
                  _field(_currentPassword, 'Clave actual', obscure: true),
                  const SizedBox(height: 10),
                  _field(_newPassword, 'Nueva clave', obscure: true),
                  const SizedBox(height: 10),
                  _field(
                    _confirmPassword,
                    'Confirmar nueva clave',
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Guardar clave'),
                  ),
                  const SizedBox(height: 26),
                  _notice('La sesion se cerrara despues de cambiar la clave.'),
                  if (_hasPendingUpdate || _downloadingUpdate) ...[
                    const SizedBox(height: 18),
                    _updateCard(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _sectionHeader(
                          'Auditoria del sistema',
                          'Calidad de catalogo, reservas y contactos.',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _loadAudit(force: true),
                        icon: const Icon(Icons.health_and_safety),
                        label: const Text('Revisar ahora'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (audit == null)
                    Expanded(child: _empty('Auditoria no cargada.'))
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              _stat(
                                'Por revisar',
                                actionableCount,
                                Icons.report_problem,
                              ),
                              _stat(
                                'Sin filtro',
                                _countGroup(catalog['vehiclesMissingFilter']),
                                Icons.filter_alt_off,
                              ),
                              _stat(
                                'Aceites sin precio',
                                listOfMaps(
                                  catalog['missingOilPriceTypes'],
                                ).length,
                                Icons.oil_barrel,
                              ),
                              _stat(
                                'Contactos viejos',
                                historicalContactCount,
                                Icons.history,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _notice(
                            'La auditoria principal cuenta solo problemas accionables del catalogo. Direcciones, telefonos y correos antiguos quedan como referencia historica; las citas nuevas ya se validan antes de guardarse.',
                          ),
                          const SizedBox(height: 14),
                          _auditOverview(summary),
                          const SizedBox(height: 14),
                          _auditBlocks(catalog, reservations),
                        ],
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

  Widget _updateCard() {
    if (!_hasPendingUpdate && !_downloadingUpdate) {
      return const SizedBox.shrink();
    }
    final latest = _latestUpdate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D9CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.system_update_alt,
                  color: Color(0xFF946200),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actualizacion disponible',
                      style: TextStyle(
                        color: Color(0xFF063F4C),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Version instalada $appVersion',
                      style: const TextStyle(
                        color: Color(0xFF637174),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _updateMessage,
            style: const TextStyle(color: Color(0xFF4D5D62), height: 1.35),
          ),
          if (latest != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${latest.title} (${latest.version})',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  if (latest.publishedAt.isNotEmpty)
                    Text(
                      latest.publishedAt,
                      style: const TextStyle(
                        color: Color(0xFF637174),
                        fontSize: 12,
                      ),
                    ),
                  if (latest.notes.isNotEmpty) const SizedBox(height: 8),
                  for (final note in latest.notes.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Expanded(child: Text(note)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (_downloadingUpdate) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: _downloadProgress <= 0 ? null : _downloadProgress,
            ),
            const SizedBox(height: 6),
            Text(
              '${(_downloadProgress * 100).clamp(0, 100).toStringAsFixed(0)}% descargado',
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _hasPendingUpdate && !_downloadingUpdate
                ? _downloadAndRunUpdate
                : null,
            icon: const Icon(Icons.download),
            label: Text(
              _downloadingUpdate ? 'Descargando...' : 'Descargar e instalar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditBlocks(JsonMap catalog, JsonMap reservations) {
    final lines = <Widget>[];
    void addCount(String title, dynamic group) {
      final map = asMap(group);
      final count = number(map['count']).round();
      if (count == 0) return;
      lines.add(
        _issueCard(title, _auditCountLabel(count, 'fila'), map['examples']),
      );
    }

    void addDuplicates(String title, dynamic group) {
      final map = asMap(group);
      final count = number(map['count']).round();
      if (count == 0) return;
      lines.add(
        _duplicateIssueCard(
          title,
          _auditCountLabel(
            count,
            'grupo duplicado',
            plural: 'grupos duplicados',
          ),
          map['examples'],
        ),
      );
    }

    addCount('Vehiculos sin filtro', catalog['vehiclesMissingFilter']);
    addCount(
      'Vehiculos con datos faltantes',
      catalog['vehiclesMissingRequired'],
    );
    addCount('Anos invalidos', catalog['invalidVehicleYears']);
    addDuplicates('Vehiculos duplicados', catalog['duplicateVehicles']);
    addDuplicates('Precios duplicados', catalog['duplicatePrices']);
    addCount('Filas de precio incompletas', catalog['priceRowsInvalid']);
    addCount('Reservas sin fecha u hora', reservations['missingSchedule']);

    final missingOil = listOfMaps(catalog['missingOilPriceTypes']);
    if (missingOil.isNotEmpty) {
      lines.insert(
        0,
        _issueCard(
          'Aceites sin precio',
          '${missingOil.length} tipo(s)',
          missingOil,
        ),
      );
    }

    final historicalContactCount = _historicalContactCount(reservations);
    if (historicalContactCount > 0) {
      lines.add(
        _referenceCard(
          'Contactos y direcciones historicas',
          '$historicalContactCount registro(s) antiguos no se cuentan como problema principal.',
          [
            ['Telefonos', _countGroup(reservations['invalidPhones'])],
            ['Correos', _countGroup(reservations['invalidEmails'])],
            ['Direcciones', _countGroup(reservations['invalidAddresses'])],
          ],
        ),
      );
    }

    return lines.isEmpty
        ? _notice(
            'No hay problemas accionables de catalogo reportados por la auditoria.',
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: lines,
          );
  }

  Widget _auditOverview(JsonMap summary) {
    final items = [
      ['Vehiculos en catalogo', text(summary['vehicles'], fallback: '0')],
      ['Precios configurados', text(summary['prices'], fallback: '0')],
      ['Reservas revisadas', text(summary['reservations'], fallback: '0')],
      [
        'Tipos de aceite',
        text(summary['uniqueVehicleOilTypes'], fallback: '0'),
      ],
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D9CB)),
      ),
      child: _isCompact(context)
          ? Wrap(
              spacing: 16,
              runSpacing: 12,
              children: items
                  .map(
                    (item) =>
                        SizedBox(width: 140, child: _twoLine(item[0], item[1])),
                  )
                  .toList(),
            )
          : Row(
              children: items
                  .map((item) => Expanded(child: _twoLine(item[0], item[1])))
                  .toList(),
            ),
    );
  }

  int _actionableAuditCount(JsonMap catalog) {
    return listOfMaps(catalog['missingOilPriceTypes']).length +
        _countGroup(catalog['vehiclesMissingFilter']) +
        _countGroup(catalog['vehiclesMissingRequired']) +
        _countGroup(catalog['invalidVehicleYears']) +
        _countGroup(catalog['duplicateVehicles']) +
        _countGroup(catalog['duplicatePrices']) +
        _countGroup(catalog['priceRowsInvalid']);
  }

  int _historicalContactCount(JsonMap reservations) {
    return _countGroup(reservations['invalidPhones']) +
        _countGroup(reservations['invalidEmails']) +
        _countGroup(reservations['invalidAddresses']);
  }

  int _countGroup(dynamic group) => number(asMap(group)['count']).round();

  Widget _issueCard(String title, String subtitle, dynamic examples) {
    final rows = listOfMaps(examples).take(6).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E7),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFE5BE6D), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF637174))),
          if (rows.isNotEmpty) const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_auditExampleText(row)),
            ),
        ],
      ),
    );
  }

  Widget _duplicateIssueCard(String title, String subtitle, dynamic examples) {
    final groups = listOfMaps(examples).take(8).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E7),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFE5BE6D), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF637174))),
          if (groups.isNotEmpty) const SizedBox(height: 10),
          for (final group in groups) _duplicateGroupRow(group),
        ],
      ),
    );
  }

  Widget _duplicateGroupRow(JsonMap group) {
    final rows = listOfMaps(group['rows']).take(5).toList();
    final count = number(group['count']).round();
    final title = _duplicateGroupTitle(group, rows);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAD9B5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF063F4C),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _auditCountLabel(count, 'repetido'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF073D49),
                ),
              ),
            ],
          ),
          if (rows.isNotEmpty) const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _auditExampleText(row),
                style: const TextStyle(color: Color(0xFF4B5C60)),
              ),
            ),
        ],
      ),
    );
  }

  String _duplicateGroupTitle(JsonMap group, List<JsonMap> rows) {
    if (rows.isNotEmpty) {
      final firstTitle = text(rows.first['title']);
      if (firstTitle.isNotEmpty) return firstTitle;
    }
    final key = text(group['key']);
    if (key.isNotEmpty) {
      return key.split('|').where((p) => p.trim().isNotEmpty).join(' / ');
    }
    return 'Grupo duplicado';
  }

  String _auditExampleText(JsonMap row) {
    final parts = <String>[];
    final rowNumber = text(row['rowNumber']);
    final title = text(row['title'] ?? row['label'] ?? row['id']);
    final detail = text(row['detail']);
    final filter = text(row['filter']);
    if (rowNumber.isNotEmpty) parts.add('#$rowNumber');
    if (title.isNotEmpty) parts.add(title);
    if (detail.isNotEmpty) parts.add(detail);
    if (filter.isNotEmpty) parts.add('Filtro $filter');
    return parts.isEmpty ? 'Fila sin descripcion' : parts.join(' | ');
  }

  String _auditCountLabel(int count, String singular, {String? plural}) {
    return '$count ${count == 1 ? singular : (plural ?? '${singular}s')}';
  }

  Widget _referenceCard(
    String title,
    String subtitle,
    List<List<Object>> rows,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F3),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF063F4C), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Color(0xFF637174))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rows
                .where((row) => number(row[1]) > 0)
                .map(
                  (row) => Chip(
                    label: Text('${row[0]}: ${row[1]}'),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD8E7E3)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final password = _loginPassword.text;
    if (password.isEmpty) return _toast('Escribe la clave admin.', error: true);
    await _busyRun(
      'Abriendo consola',
      'Verificando acceso administrativo',
      () async {
        final res = asMap(await _api.call('adminLogin', [password]));
        if (res['success'] != true || text(res['token']).isEmpty) {
          throw Exception(
            text(res['error'], fallback: 'No se pudo iniciar sesion.'),
          );
        }
        setState(() => _token = text(res['token']));
        await _loadReservations();
        if (Platform.isWindows) unawaited(_checkForUpdates(silent: true));
      },
    );
  }

  Widget _securityPasswordPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          'Cambiar clave admin',
          'Actualiza la clave del panel desde la app.',
        ),
        _field(_currentPassword, 'Clave actual', obscure: true),
        const SizedBox(height: 10),
        _field(_newPassword, 'Nueva clave', obscure: true),
        const SizedBox(height: 10),
        _field(_confirmPassword, 'Confirmar nueva clave', obscure: true),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _changePassword,
          icon: const Icon(Icons.lock_reset),
          label: const Text('Guardar clave'),
        ),
        const SizedBox(height: 18),
        _notice('La sesion se cerrara despues de cambiar la clave.'),
        if (_hasPendingUpdate || _downloadingUpdate) ...[
          const SizedBox(height: 18),
          _updateCard(),
        ],
      ],
    );
  }

  Future<void> _loadReservations() async {
    if (_token.isEmpty) return;
    final filters = {
      'query': _queryFilter.text.trim(),
      'estado': _statusFilter,
      'servicio': _serviceFilter,
      'fecha': _dateFilter.text.trim(),
      'limit': 300,
    };
    final res = asMap(
      await _api.call('adminListarReservas', [_token, filters]),
    );
    if (res['success'] == false)
      throw Exception(
        text(res['error'], fallback: 'No se cargaron las citas.'),
      );
    setState(() {
      _reservas = listOfMaps(res['reservas']);
      _summary = asMap(res['resumen']);
      if (_reservas.isNotEmpty &&
          !_reservas.any((r) => text(r['id']) == _selectedReservationId)) {
        _selectedReservationId = text(_reservas.first['id']);
      }
    });
  }

  Future<void> _updateReservationStatus(JsonMap r, String status) async {
    if (status == 'Completada' &&
        text(r['tipoServicio'], fallback: 'oil') == 'oil') {
      await _completeOilDialog(r);
      return;
    }
    final ok = status == 'Cancelada'
        ? await _confirm('Cancelar cita', 'Quieres cancelar esta cita?')
        : true;
    if (!ok) return;
    final saved = await _busyRun(
      'Actualizando cita',
      'Guardando estado y enviando correos',
      () async {
        final res = asMap(
          await _api.call('adminActualizarEstado', [
            _token,
            text(r['id']),
            status,
          ]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se actualizo el estado.'),
          );
        await _loadReservations();
      },
    );
    if (saved) _toast('Estado actualizado.');
  }

  Future<void> _completeOilDialog(JsonMap r) async {
    final mileage = TextEditingController(text: text(r['currentMileage']));
    final miles = TextEditingController(
      text: text(r['oilIntervalMiles'], fallback: '7000'),
    );
    final months = TextEditingController(
      text: text(r['oilIntervalMonths'], fallback: '3'),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar servicio de aceite'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mileage,
                decoration: const InputDecoration(labelText: 'Millas actuales'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: miles,
                      decoration: const InputDecoration(
                        labelText: 'Intervalo millas',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: months,
                      decoration: const InputDecoration(
                        labelText: 'Intervalo meses',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (mileage.text.trim().isEmpty)
      return _toast('Las millas actuales son obligatorias.', error: true);
    final saved = await _busyRun(
      'Completando servicio',
      'Calculando proximo cambio y enviando confirmacion',
      () async {
        final payload = {
          'millasActuales': mileage.text.trim(),
          'intervaloMillasAceite': miles.text.trim().isEmpty
              ? '7000'
              : miles.text.trim(),
          'intervaloMesesAceite': months.text.trim().isEmpty
              ? '3'
              : months.text.trim(),
        };
        final res = asMap(
          await _api.call('adminActualizarEstado', [
            _token,
            text(r['id']),
            'Completada',
            payload,
          ]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se completo el servicio.'),
          );
        await _loadReservations();
      },
    );
    if (saved) _toast('Servicio completado.');
  }

  Future<void> _ensureVehiclesLoaded({bool force = false}) async {
    if (_vehiclesLoaded && !force) return;
    await _busyRun(
      'Cargando catalogo',
      'Leyendo vehiculos y aceites',
      () async {
        final res = await _api.call('obtenerVehiculos', []);
        setState(() {
          _vehicles = listOfMaps(res);
          _vehiclesLoaded = true;
        });
      },
    );
  }

  Future<void> _loadOilBrands() async {
    if ([
      text(_oilMake),
      text(_oilModel),
      text(_oilYear),
      text(_oilEngine),
    ].any((v) => v.isEmpty))
      return;
    final res = await _api.call('obtenerAceitesCompatibles', [
      _oilYear,
      _oilMake,
      _oilModel,
      _oilEngine,
    ]);
    setState(
      () => _oilBrands =
          (res is List ? res : const [])
              .map((v) => text(v))
              .where((v) => v.isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
    );
  }

  Future<void> _calculateOilQuote() async {
    if ([
      text(_oilMake),
      text(_oilModel),
      text(_oilYear),
      text(_oilEngine),
      text(_oilBrand),
    ].any((v) => v.isEmpty))
      return;
    await _busyRun(
      'Calculando precio',
      'Validando vehiculo, aceite y filtro',
      () async {
        final res = asMap(
          await _api.call('adminCalcularPrecio', [
            _token,
            {
              'ano': _oilYear,
              'marca': _oilMake,
              'modelo': _oilModel,
              'motor': _oilEngine,
              'marcaAceite': _oilBrand,
            },
          ]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se pudo calcular el precio.'),
          );
        setState(() => _oilQuote = res);
      },
    );
  }

  Future<void> _submitOil() async {
    final error = _validateContact(
      _oilPhone.text,
      _oilEmail.text,
      _oilAddress.text,
    );
    if (error != null) return _toast(error, error: true);
    if ([
      text(_oilMake),
      text(_oilModel),
      text(_oilYear),
      text(_oilEngine),
      text(_oilBrand),
    ].any((v) => v.isEmpty)) {
      return _toast(
        'Selecciona marca, modelo, ano, motor y aceite.',
        error: true,
      );
    }
    await _busyRun(
      'Creando cita de aceite',
      'Calculando total, guardando y enviando recibos',
      () async {
        if (_oilQuote == null) await _calculateOilQuote();
        final data = {
          'nombre': _oilName.text.trim(),
          'telefono': cleanPhone(_oilPhone.text),
          'correo': _oilEmail.text.trim(),
          'marca': _oilMake,
          'modelo': _oilModel,
          'ano': _oilYear,
          'motor': _oilEngine,
          'marcaAceite': _oilBrand,
          'fecha': _oilDate.text.trim(),
          'hora': _oilTime.text.trim(),
          'direccion': _oilAddress.text.trim(),
          'comentarios': _oilComment.text.trim(),
          'aceptoAcuerdo': _oilAgreement ? 'SI' : 'ADMIN',
          'notificarCliente': _oilNotify ? 'SI' : 'NO',
          'estado': 'Confirmada',
          'idioma': 'es',
        };
        final res = asMap(await _api.call('adminCrearReserva', [_token, data]));
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se pudo crear la cita.'),
          );
        _clearOilForm();
        await _loadReservations();
        setState(() => _section = AdminSection.citas);
        _toast('Cita de aceite creada. ID: ${text(res['id'])}');
      },
    );
  }

  Future<void> _submitBrake() async {
    final error = _validateContact(
      _brakePhone.text,
      _brakeEmail.text,
      _brakeAddress.text,
    );
    if (error != null) return _toast(error, error: true);
    final quote = _brakeQuote();
    if (quote == null)
      return _toast('Selecciona un servicio valido.', error: true);
    await _busyRun(
      'Creando cita',
      'Guardando frenos / fluidos y enviando recibos',
      () async {
        final data = {
          'Full Name': _brakeName.text.trim(),
          'Phone': cleanPhone(_brakePhone.text),
          'Email': _brakeEmail.text.trim(),
          'Service': _brakeService,
          'Body': _brakeBody,
          'Axles': _brakeService == 'flush' ? 'N/A' : _brakeAxles,
          'FlushType': _brakeFlush,
          'Year': _brakeYear.text.trim(),
          'Make': _brakeMake.text.trim(),
          'Model': _brakeModel.text.trim(),
          'Date': _brakeDate.text.trim(),
          'Time': _brakeTime.text.trim(),
          'Address': _brakeAddress.text.trim(),
          'Comment': _brakeComment.text.trim(),
          'Language': 'es',
          'AgreementAccepted': _brakeAgreement ? 'SI' : 'NO',
          'NotificarCliente': _brakeNotify ? 'SI' : 'NO',
          'Estado': 'Confirmada',
          'price': number(quote['total']).toStringAsFixed(2),
          'basePrice': number(quote['total']).toStringAsFixed(2),
          'discountRate': '0',
          'discountPercent': '0',
          'serviceLabel': text(quote['service']),
        };
        final res = asMap(
          await _api.call('adminCrearReservaFrenosFluidos', [_token, data]),
        );
        if (res['success'] == false)
          throw Exception(
            text(
              res['error'] ?? res['message'],
              fallback: 'No se pudo crear la cita.',
            ),
          );
        _clearBrakeForm();
        await _loadReservations();
        setState(() => _section = AdminSection.citas);
        _toast('Cita de frenos / fluidos creada. ID: ${text(res['id'])}');
      },
    );
  }

  Future<void> _submitTracking() async {
    if (_trackingName.text.trim().isEmpty ||
        _trackingContact.text.trim().isEmpty) {
      return _toast('Escribe nombre y telefono o email.', error: true);
    }
    await _busyRun(
      'Buscando cliente',
      'Cargando historial y proximo servicio',
      () async {
        final res = asMap(
          await _api.call('consultarCitaCliente', [
            {
              'name': _trackingName.text.trim(),
              'contact': _trackingContact.text.trim(),
            },
          ]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se encontro historial.'),
          );
        setState(() {
          _trackingAppointment = asMap(res['appointment']);
          _trackingHistory = listOfMaps(res['history']);
        });
      },
    );
  }

  Future<void> _ensureCatalogLoaded({bool force = false}) async {
    if (_catalogLoaded && !force) return;
    await _busyRun(
      'Cargando catalogo',
      'Leyendo vehiculos, filtros y precios',
      () async {
        final res = asMap(await _api.call('adminObtenerCatalogo', [_token]));
        setState(() {
          _catalogVehicles = listOfMaps(res['vehiculos']);
          _catalogPrices = listOfMaps(res['precios']);
          _catalogLoaded = true;
        });
      },
    );
  }

  Future<void> _saveVehicle() async {
    if (!RegExp(r'^\d{4}$').hasMatch(_vehYear.text.trim()))
      return _toast('Ano invalido. Usa 4 digitos.', error: true);
    if ([
      _vehMake,
      _vehModel,
      _vehEngine,
      _vehCapacity,
      _vehOil,
    ].any((c) => c.text.trim().isEmpty)) {
      return _toast(
        'Completa marca, modelo, motor, capacidad y aceite recomendado.',
        error: true,
      );
    }
    await _busyRun(
      'Guardando vehiculo',
      'Actualizando hoja Vehiculos',
      () async {
        final data = {
          'rowNumber': text(_selectedVehicle?['rowNumber']),
          'ano': _vehYear.text.trim(),
          'marca': _vehMake.text.trim(),
          'modelo': _vehModel.text.trim(),
          'motor': _vehEngine.text.trim(),
          'capacidad': _vehCapacity.text.trim(),
          'aceite': _vehOil.text.trim(),
          'tipoFiltro': _vehFilter.text.trim(),
          'tipoFiltroAlternativo': _vehAltFilter.text.trim(),
        };
        final res = asMap(
          await _api.call('adminGuardarVehiculo', [_token, data]),
        );
        if (res['success'] == false)
          throw Exception(text(res['error'], fallback: 'No se pudo guardar.'));
        _vehiclesLoaded = false;
        await _ensureCatalogLoaded(force: true);
        setState(() => _selectedVehicle = asMap(res['vehiculo']));
        _fillVehicle(_selectedVehicle!);
        _toast(
          res['action'] == 'created'
              ? 'Vehiculo agregado.'
              : 'Vehiculo actualizado.',
        );
      },
    );
  }

  Future<void> _deleteVehicle() async {
    if (_selectedVehicle == null) return;
    if (!await _confirm(
      'Eliminar vehiculo',
      'Eliminar este vehiculo del catalogo?',
    ))
      return;
    await _busyRun(
      'Eliminando vehiculo',
      'Actualizando hoja Vehiculos',
      () async {
        final res = asMap(
          await _api.call('adminEliminarVehiculo', [
            _token,
            text(_selectedVehicle?['rowNumber']),
          ]),
        );
        if (res['success'] == false)
          throw Exception(text(res['error'], fallback: 'No se pudo eliminar.'));
        _clearVehicleForm();
        _vehiclesLoaded = false;
        await _ensureCatalogLoaded(force: true);
        _toast('Vehiculo eliminado.');
      },
    );
  }

  Future<void> _savePrice() async {
    if (_priceType.text.trim().isEmpty || _priceBrand.text.trim().isEmpty)
      return _toast('Completa tipo y marca de aceite.', error: true);
    for (final c in [
      _priceBase,
      _priceExtra,
      _priceFilter,
      _priceLabor,
      _priceDisposal,
    ]) {
      if (double.tryParse(c.text.trim()) == null ||
          double.parse(c.text.trim()) < 0)
        return _toast(
          'Todos los precios deben ser numeros validos.',
          error: true,
        );
    }
    await _busyRun('Guardando aceite', 'Actualizando hoja Precios', () async {
      final data = {
        'rowNumber': text(_selectedPrice?['rowNumber']),
        'tipo': _priceType.text.trim(),
        'marca': _priceBrand.text.trim(),
        'descripcion': _priceDescription.text.trim(),
        'precioBase': _priceBase.text.trim(),
        'precio1L': _priceExtra.text.trim(),
        'filtro': _priceFilter.text.trim(),
        'manoObra': _priceLabor.text.trim(),
        'desecho': _priceDisposal.text.trim(),
      };
      final res = asMap(await _api.call('adminGuardarPrecio', [_token, data]));
      if (res['success'] == false)
        throw Exception(text(res['error'], fallback: 'No se pudo guardar.'));
      _vehiclesLoaded = false;
      await _ensureCatalogLoaded(force: true);
      setState(() => _selectedPrice = asMap(res['precio']));
      _fillPrice(_selectedPrice!);
      _toast(
        res['action'] == 'created' ? 'Aceite agregado.' : 'Aceite actualizado.',
      );
    });
  }

  Future<void> _deletePrice() async {
    if (_selectedPrice == null) return;
    if (!await _confirm(
      'Eliminar aceite',
      'Eliminar este aceite/precio del catalogo?',
    ))
      return;
    await _busyRun('Eliminando aceite', 'Actualizando hoja Precios', () async {
      final res = asMap(
        await _api.call('adminEliminarPrecio', [
          _token,
          text(_selectedPrice?['rowNumber']),
        ]),
      );
      if (res['success'] == false)
        throw Exception(text(res['error'], fallback: 'No se pudo eliminar.'));
      _clearPriceForm();
      _vehiclesLoaded = false;
      await _ensureCatalogLoaded(force: true);
      _toast('Aceite eliminado.');
    });
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.length < 8)
      return _toast(
        'La nueva clave debe tener al menos 8 caracteres.',
        error: true,
      );
    if (_newPassword.text != _confirmPassword.text)
      return _toast('La confirmacion no coincide.', error: true);
    await _busyRun(
      'Cambiando clave',
      'Actualizando seguridad del panel',
      () async {
        final res = asMap(
          await _api.call('adminCambiarPassword', [
            _token,
            _currentPassword.text,
            _newPassword.text,
          ]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se pudo cambiar la clave.'),
          );
        setState(() => _token = '');
        _toast('Clave actualizada. Entra de nuevo.');
      },
    );
  }

  Future<void> _loadAudit({bool force = false}) async {
    if (_auditData != null && !force) return;
    await _busyRun(
      'Revisando datos',
      'Analizando catalogo, reservas y contactos',
      () async {
        final res = asMap(
          await _api.call('adminObtenerAuditoriaSistema', [_token]),
        );
        if (res['success'] == false)
          throw Exception(
            text(res['error'], fallback: 'No se pudo ejecutar auditoria.'),
          );
        setState(() => _auditData = res);
      },
    );
  }

  Future<void> _checkForUpdates({bool silent = false}) async {
    if (_checkingUpdate) return;
    setState(() {
      _checkingUpdate = true;
      if (!silent) _updateMessage = 'Buscando actualizaciones en GitHub...';
    });
    try {
      final latest = await _updater.fetchLatest();
      final hasUpdate = compareVersions(latest.version, appVersion) > 0;
      setState(() {
        _latestUpdate = latest;
        _updateMessage = hasUpdate
            ? 'Hay una nueva version disponible. Puedes descargar el instalador desde aqui.'
            : 'Tu app esta actualizada. No hay una version nueva disponible.';
      });
      if (!silent) {
        _toast(
          hasUpdate
              ? 'Nueva version disponible: ${latest.version}'
              : 'La app esta actualizada.',
        );
      } else if (hasUpdate) {
        _toast('Nueva version disponible: ${latest.version}');
      }
    } catch (error) {
      setState(() {
        _updateMessage =
            'No se pudo revisar GitHub ahora. Verifica internet e intenta de nuevo.';
      });
      if (!silent) {
        _toast(error.toString().replaceFirst('Exception: ', ''), error: true);
      }
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  Future<void> _downloadAndRunUpdate() async {
    final latest = _latestUpdate;
    if (latest == null) return;
    final ok = await _confirm(
      'Instalar actualizacion',
      'Se descargara la version ${latest.version}. La app se cerrara y la actualizacion se instalara automaticamente.',
    );
    if (!ok) return;

    setState(() {
      _downloadingUpdate = true;
      _downloadProgress = 0;
      _updateMessage = 'Descargando instalador desde GitHub...';
    });

    try {
      final file = await _updater.downloadInstaller(
        latest,
        onProgress: (progress) {
          if (mounted) setState(() => _downloadProgress = progress);
        },
      );
      setState(() {
        _updateMessage = 'Descarga completada. Instalando actualizacion...';
      });
      await Process.start(file.path, ['/S'], mode: ProcessStartMode.detached);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      exit(0);
    } catch (error) {
      _toast(error.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _downloadingUpdate = false;
          _downloadProgress = 0;
        });
      }
    }
  }

  Future<void> _refreshSection() async {
    try {
      await switch (_section) {
        AdminSection.citas => _busyRun(
          'Actualizando citas',
          'Leyendo reservas',
          _loadReservations,
        ),
        AdminSection.aceite => _ensureVehiclesLoaded(force: true),
        AdminSection.frenos => Future<void>.value(),
        AdminSection.tracking => Future<void>.value(),
        AdminSection.catalogo => _ensureCatalogLoaded(force: true),
        AdminSection.seguridad => _loadAudit(force: true),
      };
    } catch (e) {
      _toast(e.toString(), error: true);
    }
  }

  Future<bool> _busyRun(
    String title,
    String text,
    Future<void> Function() work,
  ) async {
    setState(() {
      _busy = true;
      _busyTitle = title;
      _busyText = text;
    });
    try {
      await work();
      return true;
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), error: true);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Si'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toast(String message, {bool error = false}) {
    final compact = _isCompact(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: compact
            ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
            : const EdgeInsets.fromLTRB(280, 0, 24, 24),
        elevation: 10,
        duration: const Duration(seconds: 4),
        backgroundColor: error
            ? const Color(0xFF8E1D24)
            : const Color(0xFF063F4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  JsonMap? _selectedOilVehicle() {
    for (final v in _vehicles) {
      if (text(v['marca']) == text(_oilMake) &&
          text(v['modelo']) == text(_oilModel) &&
          text(v['ano']) == text(_oilYear) &&
          text(v['motor']) == text(_oilEngine)) {
        return v;
      }
    }
    return null;
  }

  JsonMap? _brakeQuote() {
    const prices = {
      'pads': {
        'sedan': [70, 130, 180, 220],
        'suv': [90, 170, 240, 300],
      },
      'combo': {
        'sedan': [110, 210, 300, 380],
        'suv': [135, 260, 370, 480],
      },
      'flush': {
        'sedan': {'regular': 107, 'complete': 119},
        'suv': {'regular': 138, 'complete': 150},
      },
    };
    if (_brakeService == 'flush') {
      final value =
          (prices['flush']![_brakeBody] as Map<String, int>)[_brakeFlush];
      if (value == null) return null;
      return {
        'total': value,
        'service': _brakeFlush == 'complete'
            ? 'Flush completo'
            : 'Flush regular',
        'detail': _brakeFlush == 'complete'
            ? 'Servicio completo'
            : 'Servicio regular',
      };
    }
    final axles = int.tryParse(_brakeAxles) ?? 1;
    final list = prices[_brakeService]?[_brakeBody] as List<int>?;
    if (list == null || axles < 1 || axles > 4) return null;
    return {
      'total': list[axles - 1],
      'service': _brakeService == 'combo' ? 'Pads + rotors' : 'Pads only',
      'detail': '$axles eje${axles == 1 ? '' : 's'}',
    };
  }

  void _clearOilForm() {
    for (final c in [
      _oilName,
      _oilPhone,
      _oilEmail,
      _oilDate,
      _oilTime,
      _oilAddress,
      _oilComment,
    ]) {
      c.clear();
    }
    setState(() {
      _oilMake = null;
      _oilModel = null;
      _oilYear = null;
      _oilEngine = null;
      _oilBrand = null;
      _oilBrands = [];
      _oilQuote = null;
      _oilAgreement = true;
      _oilNotify = true;
    });
  }

  void _clearBrakeForm() {
    for (final c in [
      _brakeName,
      _brakePhone,
      _brakeEmail,
      _brakeYear,
      _brakeMake,
      _brakeModel,
      _brakeDate,
      _brakeTime,
      _brakeAddress,
      _brakeComment,
    ]) {
      c.clear();
    }
    setState(() {
      _brakeService = 'pads';
      _brakeBody = 'sedan';
      _brakeAxles = '1';
      _brakeFlush = 'regular';
      _brakeAgreement = true;
      _brakeNotify = true;
    });
  }

  void _fillVehicle(JsonMap item) {
    setState(() {
      _selectedVehicle = item;
      _vehYear.text = text(item['ano']);
      _vehMake.text = text(item['marca']);
      _vehModel.text = text(item['modelo']);
      _vehEngine.text = text(item['motor']);
      _vehCapacity.text = text(item['capacidad']);
      _vehOil.text = text(item['aceite']);
      _vehFilter.text = text(item['tipoFiltro']);
      _vehAltFilter.text = text(item['tipoFiltroAlternativo']);
    });
  }

  void _clearVehicleForm() {
    for (final c in [
      _vehYear,
      _vehMake,
      _vehModel,
      _vehEngine,
      _vehCapacity,
      _vehOil,
      _vehFilter,
      _vehAltFilter,
    ]) {
      c.clear();
    }
    setState(() => _selectedVehicle = null);
  }

  void _fillPrice(JsonMap item) {
    setState(() {
      _selectedPrice = item;
      _priceType.text = text(item['tipo']);
      _priceBrand.text = text(item['marca']);
      _priceDescription.text = text(item['descripcion']);
      _priceBase.text = text(item['precioBase']);
      _priceExtra.text = text(item['precio1L']);
      _priceFilter.text = text(item['filtro']);
      _priceLabor.text = text(item['manoObra']);
      _priceDisposal.text = text(item['desecho']);
    });
  }

  void _clearPriceForm() {
    for (final c in [
      _priceType,
      _priceBrand,
      _priceDescription,
      _priceBase,
      _priceExtra,
      _priceFilter,
      _priceLabor,
      _priceDisposal,
    ]) {
      c.clear();
    }
    setState(() => _selectedPrice = null);
  }

  String? _validateContact(String phone, String email, String address) {
    if (cleanPhone(phone).length != 10)
      return 'Telefono invalido. Usa 10 digitos.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim()))
      return 'Email invalido.';
    final addr = address.trim();
    if (!RegExp(r'\d{1,6}').hasMatch(addr) ||
        !RegExp(r'[A-Za-z]{2,}').hasMatch(addr) ||
        !(addr.contains(',') ||
            RegExp(r'\b\d{5}(?:-\d{4})?\b').hasMatch(addr) ||
            RegExp(r'\b[A-Z]{2}\b', caseSensitive: false).hasMatch(addr))) {
      return 'Direccion incompleta. Incluye numero, calle, ciudad/estado o ZIP.';
    }
    return null;
  }

  bool _matches(JsonMap item, String query, List<String> keys) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return keys.any((key) => text(item[key]).toLowerCase().contains(q));
  }

  String _title() => switch (_section) {
    AdminSection.citas => 'Panel de citas',
    AdminSection.aceite => 'Reservar cambio de aceite',
    AdminSection.frenos => 'Reservar frenos / fluidos',
    AdminSection.tracking => 'Tracking de cliente',
    AdminSection.catalogo => 'Catalogo de vehiculos',
    AdminSection.seguridad => 'Seguridad y auditoria',
  };

  String _eyebrow() => switch (_section) {
    AdminSection.citas => 'OPERACIONES',
    AdminSection.aceite => 'MODULO INTERNO',
    AdminSection.frenos => 'MODULO INTERNO',
    AdminSection.tracking => 'HISTORIAL',
    AdminSection.catalogo => 'DATOS',
    AdminSection.seguridad => 'ADMIN',
  };
}

Widget _screenPadding(Widget child) {
  return Padding(padding: const EdgeInsets.all(14), child: child);
}

bool _isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 820;

Widget _panel({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF6),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2D9CB)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

Widget _sectionHeader(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF063F4C),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF637174))),
      ],
    ),
  );
}

Widget _formGrid(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width < 620) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      }
      final itemWidth = (width - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children.map((child) {
          final span = child is _SpanBox ? child.span : 1;
          return SizedBox(width: span == 2 ? width : itemWidth, child: child);
        }).toList(),
      );
    },
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  String? hint,
  TextInputType? keyboard,
  bool obscure = false,
  int maxLines = 1,
  int span = 1,
}) {
  final field = TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    maxLines: obscure ? 1 : maxLines,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
  return _SpanBox(span: span, child: field);
}

Widget _dropdown({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  Map<String, String> labels = const {},
  int span = 1,
}) {
  final cleanItems = items
      .where((item) => item.trim().isNotEmpty || labels.containsKey(item))
      .toSet()
      .toList();
  final safeValue = value != null && cleanItems.contains(value) ? value : null;
  return _SpanBox(
    span: span,
    child: DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: cleanItems
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(labels[item] ?? item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );
}

class _SpanBox extends StatelessWidget {
  const _SpanBox({required this.child, this.span = 1});
  final Widget child;
  final int span;
  @override
  Widget build(BuildContext context) => child;
}

Widget _checkTile(String label, bool value, ValueChanged<bool> onChanged) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F4EC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2D9CB)),
    ),
    child: CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      controlAffinity: ListTileControlAffinity.leading,
    ),
  );
}

Widget _stat(String label, dynamic value, IconData icon) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D9CB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF063F4C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF637174),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  text(value, fallback: '0'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF063F4C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _twoLine(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      if (subtitle.isNotEmpty)
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF637174), fontSize: 12),
        ),
    ],
  );
}

Widget _statusChip(String status) {
  final color = switch (status) {
    'Confirmada' => const Color(0xFF0B6B4B),
    'Completada' => const Color(0xFF1D4ED8),
    'Cancelada' => const Color(0xFFB7222A),
    _ => const Color(0xFF946200),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      status,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
    ),
  );
}

Widget _detailBlock(String title, Map<String, dynamic> values) {
  final entries = values.entries
      .where((e) => text(e.value).isNotEmpty)
      .toList();
  if (entries.isEmpty) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.only(bottom: 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE7DED0))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF063F4C),
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        for (final entry in entries) _kv(entry.key, entry.value),
      ],
    ),
  );
}

Widget _kv(String label, dynamic value) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 360;
      if (compact) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF637174),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text(value, fallback: 'N/A'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF637174),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text(value, fallback: 'N/A'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _empty(String text) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D9CB)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF637174),
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget _notice(String text) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: const BoxDecoration(
      color: Color(0xFFFFF6E7),
      border: Border(left: BorderSide(color: Color(0xFFE5BE6D), width: 4)),
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4D5D62),
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
    ),
  );
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, this.dark = false});
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: dark ? const Color(0x2232D583) : const Color(0xFFDDF8E9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 9, color: Color(0xFF087443)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF075E3D),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

String text(dynamic value, {String fallback = ''}) {
  final clean = value == null ? '' : value.toString().trim();
  return clean.isEmpty ? fallback : clean;
}

double number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(
        value?.toString().replaceAll(RegExp(r'[^0-9.\-]'), '') ?? '',
      ) ??
      0;
}

String money(dynamic value) {
  final n = number(value);
  return n == 0 ? 'N/A' : '\$${n.toStringAsFixed(2)}';
}

String cleanPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('1')) return digits.substring(1);
  return digits;
}

String vehicleLabel(JsonMap r) {
  return [
    text(r['ano']),
    text(r['marca']),
    text(r['modelo']),
  ].where((e) => e.isNotEmpty).join(' ');
}

String serviceLabel(JsonMap r) {
  final type = text(r['tipoServicio'], fallback: 'oil');
  if (type == 'brake') return 'Frenos';
  if (type == 'flush') return 'Flush';
  return 'Aceite';
}

List<String> unique(Iterable<String> values) {
  final set = values.where((v) => v.trim().isNotEmpty).toSet().toList();
  set.sort((a, b) => a.compareTo(b));
  return set;
}

JsonMap asMap(dynamic value) {
  if (value is Map)
    return value.map((key, val) => MapEntry(key.toString(), val));
  return {};
}

List<JsonMap> listOfMaps(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((m) => m.map((key, val) => MapEntry(key.toString(), val)))
      .toList();
}
