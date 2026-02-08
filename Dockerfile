FROM ubuntu:20.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
# We install both bash and zsh.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    bash \
    zsh \
    git \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Binder User (jovyan)
ARG NB_USER=harry_potter
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# --- SHELL CONFIGURATION ---
# A. Set the interactive shell environment variable to BASH
ENV SHELL /bin/bash

# B. Force /bin/sh to point to ZSH
# Any script starting with #!/bin/sh will now run via ZSH
RUN ln -sf /usr/bin/zsh /bin/sh

# 3. Create user
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    --shell /bin/bash \
    ${NB_USER}

# 4. Setup File System Requirements
RUN echo "Welcome to the course workspace." > ${HOME}/welcome

# Configure .bashrc (Since the user uses Bash)
RUN echo 'echo "--------------------------------------------------------"' >> ${HOME}/.bashrc && \
    echo 'echo "LOGGED IN: Ubuntu 20.04 Restricted Environment"' >> ${HOME}/.bashrc && \
    echo 'echo "Sudo access is disabled."' >> ${HOME}/.bashrc && \
    echo 'echo "--------------------------------------------------------"' >> ${HOME}/.bashrc

# 5. Install Jupyter
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir "notebook<7.0.0"

# ==========================================
# 6. COPY FILES AND SET PERMISSIONS
# ==========================================

# Copy the local 'hw' folder
COPY --chown=${NB_UID} hw ${HOME}/hw

# --- PERMISSION LOGIC ---

# 1. 'exec' files: Owner Root, Permissions 711
#    (User can Execute, but CANNOT Read/Write/Strings)
RUN find ${HOME}/hw -name "exec*" -exec chown root:root {} \; && \
    find ${HOME}/hw -name "exec*" -exec chmod 711 {} \;

# 2. 'flag' files: Owner Root, Permissions 711
#    (User can Execute, but CANNOT Read/Write/Strings)
RUN find ${HOME}/hw -name "flag" -exec chown root:root {} \; && \
    find ${HOME}/hw -name "flag" -exec chmod 711 {} \;

# 3. Text and Source files: Owner Student, Readable
RUN find ${HOME}/hw -name "*.c" -exec chown ${NB_UID} {} \; && \
    find ${HOME}/hw -name "*.txt" -exec chown ${NB_UID} {} \;

# ==========================================

# Finalize User
USER ${NB_USER}
WORKDIR ${HOME}

# Start Jupyter
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
