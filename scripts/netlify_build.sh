#!/usr/bin/env bash

set -euo pipefail

flutter_dir="${HOME}/flutter"

if [[ ! -x "${flutter_dir}/bin/flutter" ]]; then
  git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git \
    "${flutter_dir}"
fi

export PATH="${flutter_dir}/bin:${PATH}"

flutter config --enable-web
flutter pub get

if [[ -z "${API_URL:-}" ]]; then
  echo "The API_URL environment variable is required."
  exit 1
fi

printf 'API_URL="%s"\n' "${API_URL}" > .env
flutter build web --release
