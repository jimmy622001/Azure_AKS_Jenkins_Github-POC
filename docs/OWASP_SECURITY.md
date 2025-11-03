# OWASP Security Implementation Guide

This document provides guidance on how the OWASP security features are implemented in the Azure AKS Jenkins GitHub project and how to use them effectively.

## Overview

The security implementation in this project follows the OWASP (Open Web Application Security Project) recommendations and best practices to protect against common web application vulnerabilities. The security features are implemented primarily through the `security` module, which adds Azure Web Application Firewall (WAF), Azure Defender, and Azure Security Center to provide multi-layered security protection.

## Components

### 1. Azure Web Application Firewall (WAF)

Azure WAF is configured to protect against the OWASP Top 10 vulnerabilities:

- **SQL Injection Protection**: Blocks SQL injection attempts
- **XSS Protection**: Blocks cross-site scripting attacks
- **Size Constraint**: Prevents abnormally large requests
- **Rate-Based Protection**: Limits request rate to prevent DDoS attacks
- **Known Bad Inputs Protection**: Blocks common attack patterns
- **IP-based Protection**: Blocks requests from known malicious IPs

#### How to customize WAF rules:

To block specific IP addresses, update the `blocked_ip_addresses` variable in your environment's terraform.tfvars file:

```hcl
blocked_ip_addresses = ["203.0.113.1", "198.51.100.2"]
```

To adjust rate limiting:

```hcl
request_limit = 500  # Lower for stricter protection
```

To adjust maximum request size:

```hcl
max_request_size = 65536  # 64 KB
```

### 2. Security Headers

The application implements recommended security headers through Azure Application Gateway:

- **Content-Security-Policy**: Controls resources the browser is allowed to load
- **X-Content-Type-Options**: Prevents MIME-type sniffing
- **X-Frame-Options**: Prevents clickjacking via iframe embedding
- **X-XSS-Protection**: Enables browser-level XSS filtering
- **Strict-Transport-Security**: Forces HTTPS connections
- **Referrer-Policy**: Controls information sent in the Referer header

### 3. TLS Configuration

The application enforces modern TLS protocols:

- **Minimum TLS Version**: TLS 1.2
- **Secure Cipher Suites**: Using secure encryption algorithms

### 4. Azure Defender

Azure Defender (part of Microsoft Defender for Cloud) is enabled for continuous threat detection:

- Monitors for malicious activity and unauthorized behavior
- Analyzes Azure Activity logs and other data sources
- Sends findings to the security alerts topic

### 5. Azure Security Center

Azure Security Center monitors security compliance:

- Tracks resource configurations against security best practices
- Evaluates resources against security rules
- Sends notifications when resources violate policies

### 6. Security Dashboard

An Azure Monitor dashboard provides visibility into security events:

- WAF blocked requests
- WAF allowed requests
- WAF rule triggers

## Implementation by Environment

### Development Environment

The development environment has less restrictive security settings:

- WAF rules are set to "Detection" mode to monitor without blocking
- Lower request rate limits
- Security Center may be disabled by default

### Production Environment

For production, you should enable stricter security:

```hcl
module "security" {
  # Other settings...
  
  # OWASP Security settings
  blocked_ip_addresses = var.blocked_ip_addresses
  max_request_size     = 65536  # 64 KB - stricter than dev
  request_limit        = 500    # Lower than dev for better protection
  enable_security_center = true # Enable Security Center in production
}
```

## Monitoring Security Events

### WAF Logs

WAF logs are stored in an Azure Storage Account and can be analyzed using Azure Log Analytics or other log analysis tools.

To query WAF logs with Log Analytics:

1. Create a Log Analytics workspace and connect WAF logs
2. Run queries to analyze blocked requests
3. Set up automated alerts based on specific patterns

### Azure Defender Findings

Azure Defender findings are sent to the security alerts topic. You can:

1. Subscribe to Azure Monitor alerts to receive notifications
2. Integrate with a SIEM solution
3. Trigger automated remediation with Azure Functions or Logic Apps

### Azure Security Center Compliance

Azure Security Center evaluation results can be viewed in the Azure Portal.

## Security Best Practices

1. **Regularly review WAF logs** to identify potential threats
2. **Tune WAF rules** based on false positives/negatives
3. **Configure security alert notifications** for timely notifications
4. **Periodically test** the security controls with penetration testing
5. **Update IP blocklists** with known threat actors

## Adding Custom WAF Rules

To add custom WAF rules, modify the `modules/security/main.tf` file:

```hcl
# Example custom rule to block specific User-Agent strings
custom_rules {
  name      = "BlockMaliciousUserAgents"
  priority  = 100
  rule_type = "MatchRule"

  match_conditions {
    match_variables {
      variable_name = "RequestHeaders"
      selector      = "User-Agent"
    }
    operator           = "Contains"
    negation_condition = false
    match_values       = ["Malicious-Bot"]
  }
  action = "Block"
}
```

## Additional Security Enhancements

Consider implementing these additional security measures:

1. **Azure DDoS Protection** for enhanced DDoS protection
2. **Azure Key Vault** for managed secrets and certificates
3. **Azure Firewall** for deeper network-layer protection
4. **Azure Bastion** for secure VM access without direct SSH/RDP exposure
5. **Azure Sentinel** for advanced threat detection and response