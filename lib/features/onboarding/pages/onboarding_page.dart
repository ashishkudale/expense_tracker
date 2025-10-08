import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/currencies.dart';
import '../../../core/di/di.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Currency _selectedCurrency = Currencies.getByCode('INR') ?? Currencies.all.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<OnboardingBloc>().add(
            OnboardingSubmitted(
              name: _nameController.text.trim(),
              currencyCode: _selectedCurrency.code,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(
        userProfileRepository: getIt(),
        prefs: getIt(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingSuccess) {
                context.go('/home');
              } else if (state is OnboardingFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (blocContext, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Expense Tracker',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s get you started with some basic information',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Name must be less than 50 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<Currency>(
                        value: _selectedCurrency,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return Currencies.all.map<Widget>((Currency currency) {
                            return Row(
                              children: [
                                Text(
                                  currency.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${currency.code} - ${currency.name}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          }).toList();
                        },
                        items: Currencies.all.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      currency.symbol,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      '${currency.code} - ${currency.name}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (currency) {
                          if (currency != null) {
                            setState(() {
                              _selectedCurrency = currency;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: state is OnboardingInProgress ? null : () => _submit(blocContext),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: state is OnboardingInProgress
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Get Started',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}