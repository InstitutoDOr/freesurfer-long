# Longitudinal processing pipeline
This pipeline has some scripts to use recon-all and extract stats.

Main reference: http://freesurfer.net/fswiki/LongitudinalProcessing

## Getting Started

### Software requirements
* [freesurfer](https://surfer.nmr.mgh.harvard.edu/)
* [MATLAB](https://www.mathworks.com/products/matlab.html) 
* Sun Grid Engine
* LobesScalingCode, MATLAB toolbox
    
### Steps

1. First, export your data using BIDS specs.

2. Copy file `.env_sample` renaming to `.env` and set the environment variables inside this file with the path for each directory.

3. Run recon-all using this command in a terminal:

    ```bash
    ./01-preproc_sge.sh
    ```

    This script looks for each session present in the BIDS dataset and performs the command `recon-all` for them. Output directories that already exist are skipped. It also generates the template and longitudinal folders. Reference: http://freesurfer.net/fswiki/LongitudinalProcessing

4. recon-all again, but this time with the flag -localGI. Run this command in a terminal:

    ```bash
    ./02-scriptalllgi.sh
    ```

    This step requires the software MATLAB. Output are located at `$LOGDIR`.

    **Note:** Check for errors using the script `check-logs.sh`

5. Extract some stats using this command in a terminal:

    ```bash
    ./03-extracts_stats.sh
    ```

    The results will be placed inside `$STATSDIR`

6. In MATLAB, run this command:

    ```matlab
    lobes_scaling_code.m
    ```

    The results will be placed inside the output directory of each subject, inside the directory `LobesScaling`