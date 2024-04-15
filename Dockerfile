FROM ubuntu:22.04
WORKDIR /workspace
EXPOSE 8888

ENV JUPYTER_TOKEN=123456

RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y vim git wget curl libgl1 unzip libsndfile1 ffmpeg gedit zsh gcc make perl build-essential &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &&\
    bash miniconda_installer.sh -b &&\
    rm miniconda_installer.sh

RUN /root/miniconda3/bin/conda init bash && /root/miniconda3/bin/conda init zsh &&\
    /root/miniconda3/bin/conda install -y jupyter jupyterlab -c conda-forge &&\
    /root/miniconda3/bin/pip install xeus-python &&\
    /root/miniconda3/bin/pip cache purge && /root/miniconda3/bin/conda clean -a

COPY assets/jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

# setup oh-my-zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# download theme
RUN curl -fsSL https://raw.githubusercontent.com/ControlNet/my-zsh-theme-env/main/files/mzz-ys.zsh-theme > /root/.oh-my-zsh/themes/mzz-ys.zsh-theme

# modify the .zshrc file to change the theme and add plugins
RUN cat /root/.zshrc | sed 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"mzz-ys\"\nZSH_DISABLE_COMPFIX=\"true\"/' \
    | sed 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' > /root/temp.zshrc
RUN mv /root/temp.zshrc /root/.zshrc

# setup git alias
RUN git config --global alias.lsd "log --graph --decorate --pretty=oneline --abbrev-commit --all"

# hide conda prefix
RUN echo "changeps1: false" >> /root/.condarc

RUN cat /root/.zshrc | sed 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"mzz-ys\"\nZSH_DISABLE_COMPFIX=\"true\"/' \
    | sed 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' > /root/temp.zshrc

# install mojo
RUN curl -s https://get.modular.com | sh - && modular install mojo
ENV MODULAR_HOME="/root/.modular"
ENV PATH="/root/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

SHELL ["/root/miniconda3/bin/conda", "run", "--no-capture-output", "-n", "base", "/bin/zsh", "-c"]

ENTRYPOINT [ "/root/miniconda3/bin/conda", "run", "--no-capture-output", "-n", "base", "jupyter", "lab", "--allow-root"]