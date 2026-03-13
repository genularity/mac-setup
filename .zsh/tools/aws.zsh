if command -v aws &>/dev/null; then
  alias awslocal="aws --endpoint-url=http://localhost:4566"
  alias awswhoami="aws sts get-caller-identity"

  aws-profile() {
    if [[ -z "$1" ]]; then
      echo "Current: ${AWS_PROFILE:-(none)}"
      return
    fi
    export AWS_PROFILE="$1"
    echo "Switched to: $AWS_PROFILE"
  }

  aws-profiles() {
    grep '\[profile' ~/.aws/config 2>/dev/null | sed 's/\[profile \(.*\)\]/\1/'
  }

  # AWS completion
  local aws_completer
  if aws_completer="$(command -v aws_completer 2>/dev/null)"; then
    complete -C "$aws_completer" aws
  fi
fi
