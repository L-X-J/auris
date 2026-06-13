import 'package:auris/auris.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AurisExampleApp());

/// The walking-skeleton showcase: a minimal runnable app that applies
/// [AurisTheme.light] and renders representative Material widgets, proving the
/// whole spine (fonts -> tokens -> resolved scheme -> ThemeExtension -> theme ->
/// app) end to end.
class AurisExampleApp extends StatelessWidget {
  const AurisExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auris — Walking Skeleton',
      debugShowCheckedModeBanner: false,
      theme: AurisTheme.light(),
      home: const _ShowcaseScreen(),
    );
  }
}

class _ShowcaseScreen extends StatelessWidget {
  const _ShowcaseScreen();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme text = theme.textTheme;

    // Read the resolved scheme from the ThemeExtension to prove it resolves,
    // and use one of its role colors in the UI (the panel header strip below).
    final AurisScheme scheme = theme.extension<AurisScheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('AURIS // WALKING SKELETON', style: text.titleLarge),
        backgroundColor: scheme.surfacePanel,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('SYSTEM ONLINE', style: text.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Augmentation-era interface. Amber-on-near-black, chamfered '
                  'geometry, glow in place of drop shadow.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Card surface — chamfered border driven by the bevel role,
                // header strip painted with a resolved scheme role color.
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          // Scheme role color proves the extension resolves.
                          color: scheme.surfaceInset,
                          border: Border(
                            bottom: BorderSide(color: scheme.borderResting),
                          ),
                        ),
                        child: Text('DIAGNOSTICS', style: text.labelLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Core integrity nominal.', style: text.bodyMedium),
                            const SizedBox(height: 4),
                            Text(
                              'All subsystems reporting within tolerance.',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons — re-skinned via the derived ColorScheme.
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('ENGAGE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('STANDBY'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('RUN DIAGNOSTIC'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
