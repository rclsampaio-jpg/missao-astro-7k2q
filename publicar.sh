#!/bin/bash
# Publica a Missão Astro no GitHub Pages (grátis).
# Como usar: abra o Terminal, entre nesta pasta e rode:  bash publicar.sh
# Para atualizar o app depois, é só rodar de novo.
set -e
cd "$(dirname "$0")"
REPO="missao-astro-7k2q"
USER=$(gh api user -q .login)

if [ ! -d .git ]; then git init -q -b main; fi
git add -A
git commit -q -m "Missão Astro: app de astrologia interativo" || true

if ! gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  gh repo create "$USER/$REPO" --public --source=. --remote=origin --push --description "Missão Astro"
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USER/$REPO.git"
  git push -u origin main
fi

gh api -X POST "repos/$USER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

echo "Aguardando o GitHub publicar (1 a 2 minutos)..."
for i in $(seq 1 24); do
  S=$(gh api "repos/$USER/$REPO/pages/builds/latest" -q .status 2>/dev/null || echo "")
  [ "$S" = "built" ] && break
  sleep 10
done

echo ""
echo "Pronto! Link para mandar para a Sarah:"
echo "https://$USER.github.io/$REPO/"
