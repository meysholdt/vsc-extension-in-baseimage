FROM gitpod/workspace-full

ENV rebuild=5

USER gitpod

RUN mkdir /home/gitpod/extensions
COPY *.vsix /home/gitpod/extensions