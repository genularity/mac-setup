if command -v terraform &>/dev/null; then
  alias tf="terraform"
  alias tfi="terraform init"
  alias tfp="terraform plan"
  alias tfa="terraform apply"
  alias tfd="terraform destroy"
  alias tfo="terraform output"
  alias tfs="terraform state"
  alias tfsl="terraform state list"
  alias tfss="terraform state show"
  alias tfv="terraform validate"
  alias tfw="terraform workspace"

  tfws() {
    if [[ -z "$1" ]]; then
      terraform workspace show
      return
    fi
    terraform workspace select "$1"
  }

  # Terraform completion (bashcompinit loaded in completions.zsh)
  complete -o nospace -C terraform terraform
fi
