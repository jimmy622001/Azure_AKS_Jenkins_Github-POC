# Contributing to Azure AKS Jenkins GitHub

Thank you for your interest in contributing to our Azure AKS Jenkins GitHub project! This document provides guidelines and instructions for contributing to this repository.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Pull Request Process](#pull-request-process)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [project_email@example.com].

## Getting Started

1. Fork the repository
2. Clone your forked repository locally
3. Set up the development environment as described in the [README.md](README.md)

## How to Contribute

### Reporting Bugs

- Use the GitHub issue tracker to report bugs
- Describe the issue in detail, including steps to reproduce
- Include the version of Terraform, Azure provider, and other relevant tools
- Add appropriate labels to your issue

### Feature Requests

- Use the GitHub issue tracker to suggest features
- Clearly describe the feature and its benefits
- Discuss potential implementation approaches if possible

### Code Contributions

1. Find an issue to work on or create a new one
2. Comment on the issue to let others know you're working on it
3. Follow the [Pull Request Process](#pull-request-process)

## Pull Request Process

1. Ensure your code follows the project's [Coding Standards](#coding-standards)
2. Update documentation if necessary
3. Add tests for new features
4. Run existing tests to ensure nothing was broken
5. Create a pull request with a clear title and description
6. Link the pull request to any related issues
7. Wait for code review and address any feedback

## Coding Standards

### Terraform

- Follow the [Terraform Style Conventions](https://www.terraform.io/docs/language/syntax/style.html)
- Use meaningful variable and resource names
- Document all variables with descriptions
- Group related resources together
- Use modules for reusable components
- Format code with `terraform fmt` before committing

### General Guidelines

- Keep code DRY (Don't Repeat Yourself)
- Write clear, readable code with appropriate comments
- Use consistent naming conventions
- Follow the principle of least privilege for IAM roles and permissions

## Testing Guidelines

- Write tests for new features and bug fixes
- Run existing tests before submitting a pull request
- Ensure tests are reliable and don't depend on external state
- Include both unit tests and integration tests when appropriate

### Testing Infrastructure Code

- Use `terraform validate` to check for syntax errors
- Use `terraform plan` to verify expected changes
- Consider using tools like Terratest for more complex tests

## Documentation

- Update README.md with any necessary changes
- Document new features in appropriate markdown files
- Keep the documentation up to date with code changes
- Use clear, concise language in documentation

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [LICENSE](LICENSE) file.

Thank you for contributing to our project!