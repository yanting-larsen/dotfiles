autoload -U vcs_info
precmd_functions+=(vcs_info)

VCS_INFO_CLEAN="%F{green}✓%f"
VCS_INFO_STAGED="%F{yellow}⚡%f"
VCS_INFO_UNSTAGED="%F{red}⚡%f"
VCS_INFO_AHEAD="%F{red}!%f"

VCS_INFO_UNTRACKED="%F{cyan}✭%f"
VCS_INFO_ADDED="%F{green}✚%f"
VCS_INFO_MODIFIED="%F{blue}*%f"
VCS_INFO_DELETED="%F{red}✖%f"
VCS_INFO_RENAMED="%F{magenta}➜%f"
VCS_INFO_UNMERGED="%F{yellow}═%f"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '|%F{green}%b%f%c%u%m'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr $VCS_INFO_STAGED
zstyle ':vcs_info:git:*' unstagedstr $VCS_INFO_UNSTAGED

zstyle ':vcs_info:git*+set-message:*' hooks git-status
+vi-git-status() {
  hook_com[misc]+=$(_git_status)
}

_git_status() {
  local gitindex gitstatus
  gitindex=$(git status --porcelain 2> /dev/null)

  if [ -z "$gitindex" ]; then
    echo $VCS_INFO_CLEAN
    return
  fi

  if $(echo "$gitindex" | grep '^?? ' &> /dev/null); then
    gitstatus+=$VCS_INFO_UNTRACKED
  fi
  if $(echo "$gitindex" | grep '^A  \|^M  ' &> /dev/null); then
    gitstatus+=$VCS_INFO_ADDED
  fi
  if $(echo "$gitindex" | grep '^ M \|^AM \|^ T ' &> /dev/null); then
    gitstatus+=$VCS_INFO_MODIFIED
  fi
  if $(echo "$gitindex" | grep '^ D \|^AD ' &> /dev/null); then
    gitstatus+=$VCS_INFO_DELETED
  fi
  if $(echo "$gitindex" | grep '^R  ' &> /dev/null); then
    gitstatus+=$VCS_INFO_RENAMED
  fi
  if $(echo "$gitindex" | grep '^UU ' &> /dev/null); then
    gitstatus+=$VCS_INFO_UNMERGED
  fi

  echo $gitstatus
}
