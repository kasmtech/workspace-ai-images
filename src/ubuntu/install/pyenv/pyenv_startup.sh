

grep -q 'export REQUESTS_CA_BUNDLE' $HOME/.bashrc || echo export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt >> $HOME/.bashrc
grep -q 'export PIP_CERT' $HOME/.bashrc || echo export PIP_CERT=/etc/ssl/certs/ca-certificates.crt >> $HOME/.bashrc

if ! grep -q 'export PYENV_ROOT' "$HOME/.bashrc"; then
  echo "export PYENV_ROOT=$PYENV_ROOT" >> $HOME/.bashrc
  echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc
  echo 'eval "$(pyenv init - bash)"' >> $HOME/.bashrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc
fi

