FROM ubuntu:20.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
# 'sudo' is intentionally omitted. 
# python3/pip are required to run the Jupyter server that hosts the terminal.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    bash \
    git \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Binder User (jovyan)
# Binder requires a user with UID 1000.
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Create user with UID 1000. 
# We do NOT add this user to the sudo group or sudoers file.
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# 3. Setup File System Requirements
# Create the "welcome" file
RUN echo "Welcome to the course workspace." > ${HOME}/welcome

# Configure the login message via .bashrc
# This will display every time a terminal session is opened.
RUN echo 'echo "--------------------------------------------------------"' >> ${HOME}/.bashrc && \
    echo 'echo "LOGGED IN: Ubuntu 20.04 Restricted Environment"' >> ${HOME}/.bashrc && \
    echo 'echo "Sudo access is disabled for this session."' >> ${HOME}/.bashrc && \
    echo 'echo "--------------------------------------------------------"' >> ${HOME}/.bashrc

# 4. Install Jupyter
# Required to proxy the web-based terminal.
RUN pip3 install --no-cache-dir notebook

# 5. Finalize Permissions and User
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
WORKDIR ${HOME}

# Start the Jupyter Notebook server (hosting the terminal)
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
