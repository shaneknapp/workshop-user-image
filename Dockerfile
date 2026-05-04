FROM us-central1-docker.pkg.dev/cal-icor-hubs/user-images/base-python-image:040508dda2f9

# ------------------------------------------------------------
# Conda / Python packages
# ------------------------------------------------------------
# Copy environment.yml for additional packages
USER ${NB_USER}
COPY --chown=${NB_USER}:${NB_USER} environment.yml /tmp/environment.yml

# Update existing /srv/conda/notebook environment with new packages
RUN mamba env update -n notebook -f /tmp/environment.yml && \
    mamba clean -afy && rm -rf /tmp/environment.yml

# overrides.json is a file that jupyterlab reads to determine some settings
# 1) remove the 'create shareable link' option from the filebrowser context menu
RUN install -d -o ${NB_USER} -g ${NB_USER} ${CONDA_DIR}/share/jupyter/lab/settings
COPY --chown=${NB_USER}:${NB_USER} overrides.json ${CONDA_DIR}/share/jupyter/lab/settings

COPY --chown=${NB_USER}:${NB_USER} postBuild /tmp/postBuild
RUN chmod +x /tmp/postBuild && /tmp/postBuild && rm -rf /tmp/postBuild

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
USER root
RUN rm -rf /tmp/*
RUN rm -rf /root/.cache

ENV REPO_DIR=/srv/repo

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888

ENTRYPOINT ["tini", "--"]
