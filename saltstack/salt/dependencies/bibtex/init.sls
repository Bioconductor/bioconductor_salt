make_beebe:
  file.directory:
    - name: /usr/share/texlive/texmf-dist/bibtex/bst/beebe
    - makedirs: True

get_humannat.bst:
  cmd.run:
    - name: curl -L https://ctan.org/tex-archive/biblio/bibtex/contrib/misc/humannat.bst -o /usr/share/texlive/texmf-dist/bibtex/bst/beebe/humannat.bst
    - creates: /usr/share/texlive/texmf-dist/bibtex/bst/beebe/humannat.bst

run_texhash:
  cmd.run:
    - name: texhash
    - cwd: /usr/share/texlive/texmf-dist/bibtex/bst/beebe
