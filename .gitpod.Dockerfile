FROM gitpod/workspace-full

ENV rebuild=1

USER gitpod

RUN mkdir /home/gitpod/extensions
COPY *.vsix /home/gitpod/extensions
COPY install-extensions.sh /home/gitpod/.bashrc.d/110-vsix