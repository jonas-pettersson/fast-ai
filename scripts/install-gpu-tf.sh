# This script is designed to work with ubuntu 16.04 LTS
# This is the python 3 / tensorflow version needed for part II

sudo apt-get update && apt-get --assume-yes upgrade
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils
sudo apt-get --assume-yes install software-properties-common

wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
sudo apt-get update
sudo apt-get -y install cuda
sudo modprobe nvidia
nvidia-smi

mkdir downloads
cd downloads
wget https://repo.continuum.io/archive/Anaconda3-4.3.0-Linux-x86_64.sh
bash Anaconda3-4.3.0-Linux-x86_64.sh -b
echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc
export PATH="$HOME/anaconda3/bin:$PATH"
conda install -y bcolz
conda upgrade -y --all

pip install tensorflow-gpu

pip install keras
pip install git+git://github.com/fchollet/keras.git
mkdir ~/.keras
echo '{
    "image_dim_ordering": "tf",
    "epsilon": 1e-07,
    "floatx": "float32",
    "backend": "tensorflow"
}' > ~/.keras/keras.json

wget http://platform.ai/files/cudnn-8.0-linux-x64-v5.1.tgz
tar -zxf cudnn-8.0-linux-x64-v5.1.tgz
cd cuda
sudo cp lib64/* /usr/local/cuda/lib64/
sudo cp include/* /usr/local/cuda/include/

# juypter extensions
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user

jupyter notebook --generate-config
jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py
mkdir nbs

# from my setup process
# pip / unzip is not installed by the script. cliff needed for kaggle-cli
sudo apt install python-pip
pip install --upgrade cliff
pip install kaggle-cli
sudo apt-get install unzip

# otherwise jupyter notebook does not work properly
pip install backports.shutil_get_terminal_size

# emacs
sudo apt-get install -y emacs24-nox emacs24-el emacs24-common-non-dfsg
