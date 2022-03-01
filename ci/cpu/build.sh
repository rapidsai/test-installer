#!/bin/bash
set -e

export PATH=/opt/conda/bin:/usr/local/cuda/bin:$PATH
. /opt/conda/etc/profile.d/conda.sh

conda config --set ssl_verify False

conda install -y -c gpuci gpuci-tools || conda install -y -c gpuci gpuci-tools

if [[ "$INSTALLER" == "mamba" ]]; then
    gpuci_logger "Install mamba"
    gpuci_conda_retry install -y -c conda-forge mamba
fi

CHANNELS="-c $RAPIDS_CONDA_CHANNEL -c nvidia -c conda-forge"

gpuci_logger "Install rapids"

if [[ "$INSTALLER" == "conda" ]]; then
    gpuci_conda_retry create -n test $CHANNELS rapids=$RAPIDS_VER cudatoolkit=11.5 dask-sql
elif [[ "$INSTALLER" == "mamba "]]; then
    gpuci_mamba_retry create -n test $CHANNELS rapids=$RAPIDS_VER cudatoolkit=11.5 dask-sql
else
    gpuci_logger "Unknown INSTALLER"
    exit 1
fi

gpuci_logger "Activiate test environment"
conda activate test
python -c 'import cudf'