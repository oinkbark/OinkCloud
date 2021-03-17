# Manual Steps

## Website Ownership
- Website DNS servers must be pointed to Cloudflare
- The GCloud service account email for Terraform must be listed as a domain owner

## Service Credentials

Here is a list of the required credentials and their permissions that must initially be supplied:
___
> **DigitalOcean**
> - Type: API Token
> - Permissions: Default (All)

> **Google Cloud Platform**
> - Type: Service Account
> - Permissions: Project Owner

> **Cloudflare**
> - Type: API Token
> - Permissions: All zones - Zone Settings:Edit, Zone:Edit, SSL and Certificates:Edit, DNS:Edit

> **Cloudflare #2**
> - Type: API Token
> - Permissions: All zones - DNS:Edit

Depending on the setup, these may be required as well:
___
> **Database**
> - Type: Username
> - Permissions: N/A

> **SSH Access**
> - Type: Public Keys
> - Permissions: N/A

> **Google Cloud Platform #2**
> - Type: Project OAuth Consent
> - Permissions: N/A