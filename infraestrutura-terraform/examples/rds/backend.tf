terraform {
  backend "s3" {
    # Valores fornecidos via: terraform init -backend-config=backend.hcl
    bucket       = ""
    key          = ""
    region       = ""
    use_lockfile = true
  }
}
