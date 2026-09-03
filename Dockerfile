FROM us-central1-docker.pkg.dev/cal-icor-hubs/user-images/base-python-image:d75bc2e30f96

ENV NB_USER=jovyan

# ------------------------------------------------------------
# Conda / Python packages
# ------------------------------------------------------------
# Copy environment.yml for additional packages
USER ${NB_USER}
COPY --chown=${NB_USER}:${NB_USER} environment.yml /tmp/environment.yml

# Update existing /srv/conda/notebook environment with new packages
RUN mamba env update -n notebook -f /tmp/environment.yml && \
    mamba clean -afy && rm -rf /tmp/environment.yml

COPY --chown=${NB_USER}:${NB_USER} postBuild /tmp/postBuild
RUN chmod +x /tmp/postBuild && /tmp/postBuild && rm -rf /tmp/postBuild

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
USER root
RUN rm -rf /tmp/*
RUN rm -rf /root/.cache

ENV REPO_DIR=/srv/repo
RUN install -d -o ${NB_USER} -g ${NB_USER} ${REPO_DIR}
COPY --chown=${NB_USER}:${NB_USER} . ${REPO_DIR}

# Add start script
RUN chmod +x "${REPO_DIR}/start"
ENV R2D_ENTRYPOINT="${REPO_DIR}/start"
# Add entrypoint
ENV PYTHONUNBUFFERED=1

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]

#ENTRYPOINT ["tini", "--"]
