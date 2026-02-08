FROM ubuntu:20.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
# Added 'zsh' to the list.
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
# Set SHELL env to zsh
ENV SHELL /usr/bin/zsh 

# Create user with UID 1000. 
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    --shell /usr/bin/zsh \
    ${NB_USER}

# CHANGE: Force /bin/sh to point to zsh
RUN ln -sf /usr/bin/zsh /bin/sh

# 3. Setup File System Requirements
RUN echo "Welcome to the course workspace." > ${HOME}/welcome

# Configure .zshrc (instead of .bashrc since we switched shells)
RUN echo 'echo "--------------------------------------------------------"' >> ${HOME}/.zshrc && \
    echo 'echo "LOGGED IN: Ubuntu 20.04 Restricted Environment"' >> ${HOME}/.zshrc && \
    echo 'echo "Sudo access is disabled."' >> ${HOME}/.zshrc && \
    echo 'echo "--------------------------------------------------------"' >> ${HOME}/.zshrc

# 4. Install Jupyter
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir "notebook<7.0.0"

# ==========================================
# 5. COPY FILES AND SET PERMISSIONS
# ==========================================

# Copy the local 'hw' folder to the container
COPY --chown=${NB_UID} hw ${HOME}/hw

# Permission Logic:
# Step A: Ensure everything is initially owned by the user (so they can read .c and .txt files)
RUN chown -R ${NB_UID} ${HOME}/hw

# Step B: Find all files starting with "exec" (exec1, exec2...)
# 1. Change their owner to ROOT.
# 2. Change permissions to 711 (User can Execute, but NOT Read/Write).
RUN find ${HOME}/hw -name "exec*" -exec chown root:root {} \; && \
    find ${HOME}/hw -name "exec*" -exec chmod 711 {} \;

# ==========================================

# Finalize User
USER ${NB_USER}
WORKDIR ${HOME}

# Start Jupyter
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
