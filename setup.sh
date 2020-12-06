# set home to ubuntu since we dont know the user name
# and since our default machine is ubuntu 16.04
export HOME=/home/ubuntu

#--------- Install miniconda ---------#
echo "Installing miniconda...\n=============================="
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
eval "$($HOME/miniconda/bin/conda shell.bash hook)"
conda init
conda config --add channels bioconda
echo "Done"

#--------- Install snakemake ---------#
echo "\nInstalling snakemake...\n=============================="
conda install -c conda-forge mamba
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
echo "Done"

#--------- Clone the repo ---------#
echo "\nCloning the repo...\n==========================="
cd $HOME
git clone https://github.com/mchowdh200/animal_svs.git
cd $HOME/animal_svs
echo "Done"

#--------- Install python dependencies ---------#
echo "\nInstalling python dependencies...\n==========================="
pip install -r $HOME/animal_svs/requirements.txt
echo "Done"

#--------- Activate snakemake ---------#
conda activate snakemake
echo "############### Parameters associated with the data ###############
input:

  # as of right now, we only support a single experiment
  # with a forward and reverse component
  samples:
    forward: '/home/zamc8857/animal_svs/data/samples/larger1.fq'
    reverse: '/home/zamc8857/animal_svs/data/samples/larger2.fq'
    # forward: 'larger1.fq'
    # reverse: 'larger2.fq'

  # reference genome database
  reference: '/home/zamc8857/animal_svs/data/house-sparrow.fa'
  # reference: 'house-sparrow.fa'

  # used to name output files. Not needed. If left blank,
  # defaults to the filename of the forward sequence
  sample_name: 'cloud-test-local'

############### Parameters associated with the run ###############
run:

  # temporary file store. Files will be deleted
  temp_dir: '../temp'

  # output any issues/progress to this location
  logs_dir: '../logs'

  # directory to save final output files
  output_dir: '/home/zamc8857/animal_svs/data/output'

  # for deployment either locally or to the cloud
  deployment:

    # supported types: 'cloud', 'local'
    type: 'cloud'

    # number of cores to use. If left at 0, max cores are used
    cores: 0

    # Service is ONLY used if deployment is set to 'cloud'
    # current supported services are: 'gcp'
    service: 'gcp'

    # if deployment is cloud, we assume that files are stored in the cloud
    # therefore we need the bucket name. As of right now, we only support
    # storage that is the same as the deployment. So if deployment is 'gcp',
    # data must be stored in a gcp bucket. do NOT add the gs:// or s3:// prefix
    bucket_name: 'vc_pipeline_bucket'

    # the project name. Right now, only supported for GCP project
    project_name: 'dcsc-fall-2020'

    # instance machine type
    # documentation for Google Cloud Compute Enginer machine types can be seen here
    # https://cloud.google.com/compute/docs/machine-types
    # NOTE: for extra large files, its advised to get at least 16 GB ram if not more
    # and at least the size of all files for the hard drive.
    gcp_instance:
        machine_type: 'e2-standard-4'
        disk_space: '20' # in GB
        ram_size: '16' # in GB

        # documentation for region and zone found here
        # https://cloud.google.com/compute/docs/regions-zones
        region: 'us-central1'
        zone: 'us-central1-a'
" > $HOME/animal_svs/rc/config.yaml
cd $HOME/animal_svs/src
python run.py