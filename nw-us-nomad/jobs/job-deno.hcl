task "example" {
  driver = "exec"

  config {
    command = "deno"
    args = [
      "run"
    ]
  }

  artifact {
    # source = "git::https://gitlab.com/oinkbark/tubbyland"
    # source = "git::https://google.com/oinkbark/tubbyland-graphql"
    # source = google oinkcloud bucket with deno files
    options {
      #checksum = "sha256:abd123445ds4555555555"
      sshkey = "${base64encode(file(pathexpand("~/.ssh/id_rsa")))}"
      ref = "main"
      depth = 1
    }
  }

  # 1.7.5
  artifact {
    source = "https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip"
    destination = "local/repo"
    options {
      #checksum = "sha256:abd123445ds4555555555"
    }
  }
}