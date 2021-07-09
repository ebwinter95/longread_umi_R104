#!/bin/bash
# DESCRIPTION
#    Local installation of the longread-UMI-pipeline.
#
# IMPLEMENTATION
#    author   Mantas Sereika
#             Søren Karst (sorenkarst@gmail.com)
#             Ryans Ziels (ziels@mail.ubc.ca)
#    license  GNU General Public License

# Make dependency list
echo "
name: longread_umi
channels:
- conda-forge
- bioconda
- defaults
dependencies:
- seqtk=1.3
- parallel=20210622
- racon=1.4.20
- minimap2=2.20
- medaka=1.4.3 
- gawk=5.1.0
- cutadapt=3.4
- filtlong=0.2.0
- bwa=0.7.17
- samtools=1.12
- bcftools=1.12
- porechop=0.2.4
- git=2.30.2
" > ./dependencies.yml

# Install remote environment
CONDA_PREFIX="$(pwd)/longread_umi"
conda env create --prefix $CONDA_PREFIX -f dependencies.yml python=3.8
source activate $CONDA_PREFIX > /dev/null 2>&1

# Add pipeline scripts
git clone https://github.com/Serka-M/longread_umi.git $CONDA_PREFIX/longread_umi
ln -s $CONDA_PREFIX/longread_umi/longread_umi.sh $CONDA_PREFIX/bin/longread_umi

# Make pipeline scripts executable
find \
  $CONDA_PREFIX/longread_umi/ \
  -name "*.sh" \
  -exec chmod +x {} \;

# Modify porechop script
cp $CONDA_PREFIX/longread_umi/scripts/adapters.py $CONDA_PREFIX/lib/python3.8/site-packages/porechop/adapters.py

# Add usearch to pipeline
USEARCH_PATH="$(which usearch11)"
USEARCH_PATH_F=$(sed -e 's/^"//' -e 's/"$//' <<< "$USEARCH_PATH")
unset USEARCH_PATH
ln -s "$USEARCH_PATH_F" $CONDA_PREFIX/bin/usearch 

# Wrap up
source deactivate $CONDA_PREFIX > /dev/null 2>&1
rm dependencies.yml
exit 0
