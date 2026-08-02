#!/bin/bash
# 공연 허브를 깃허브에 올리고 Pages를 켠다 (최초 1회)
# 이후 수정은 이 파일을 다시 눌러도 되고, git push 만 해도 된다.
cd "$(dirname "$0")"
REPO=show-hub
USER=$(gh api user --jq .login 2>/dev/null) || { echo "gh 로그인 필요: gh auth login"; exit 1; }

if gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "저장소가 이미 있다 — 변경분만 올린다."
  git add -A && git commit -q -m "허브 갱신" 2>/dev/null
  git push -q && echo "푸시 완료"
else
  gh repo create "$REPO" --public --source=. --push \
    --description "인터랙티브 덜미쇼 「그건 문제가 아니야」 공연 운영 링크 허브 — 망이 바뀌어도 고정 주소" || exit 1
fi

# GitHub Pages 켜기 (main 브랜치 루트)
gh api -X POST "repos/$USER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  || gh api -X PUT "repos/$USER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1

echo "=============================================="
echo "  ✅ 공연 허브 공개 주소"
echo "  https://$USER.github.io/$REPO/"
echo "  (Pages 최초 반영까지 1~2분)"
echo "----------------------------------------------"
echo "  공연장(자가망)에서는 인터넷이 없다 → http://<맥북IP>:8899/hub 를 써라."
echo "  이 깃허브 주소는 인터넷 되는 곳에서 IP만 넣고 여는 용도다."
echo "=============================================="
read -n 1 -s -r -p "아무 키나 누르면 닫힘"
