#!/bin/bash

# pre_tech_pre_damage_export_folder="model_original"
pre_tech_pre_damage_export_folder="model_original_baseline"
pre_tech_post_damage_export_folder="${pre_tech_pre_damage_export_folder}/pre_tech_post_damage"
post_tech_pre_damage_export_folder="${pre_tech_pre_damage_export_folder}/post_tech_pre_damage"

pretrained_pre_tech_pre_damage_export_folder="None"
pretrained_pre_tech_post_damage_export_folder="None"
pretrained_post_tech_pre_damage_export_folder="None"

# pretrained_pre_tech_pre_damage_export_folder="${pre_tech_pre_damage_export_folder}"
# pretrained_pre_tech_post_damage_export_folder="${pre_tech_pre_damage_export_folder}/pre_tech_post_damage"
# pretrained_post_tech_pre_damage_export_folder="${pre_tech_pre_damage_export_folder}/post_tech_pre_damage"

# log_xi_min="-3.0"
# log_xi_max="-2.0"

log_xi_min="-1.0"
log_xi_max="-0.5"

# log_xi_min="5"
# log_xi_max="5.1"

batch_size="64"
num_iterations="500000"

A_g_prime="0.15"
logging_frequency="1000"
learning_rates="10e-5,10e-5,10e-5,10e-5"
hidden_layer_activations="swish,tanh,tanh,softplus"
output_layer_activations="None,custom,custom,softplus"
num_hidden_layers="4"
num_neurons="64"
learning_rate_schedule_type="sgd+piecewiseconstant"
delta="0.025"

tensorboard='True'

echo "Export folder: $pre_tech_pre_damage_export_folder"

job_file="pre_tech_pre_damage_simulation_${model_num}.job"

echo "#!/bin/bash
#SBATCH --job-name=DGM_64_4
#SBATCH --output=run.out
#SBATCH --error=run.err
#SBATCH --account=pi-lhansen
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=2-00:00:00
##SBATCH --exclude=mcn53,mcn52,mcn51,mcn08
#SBATCH --qos=clay  # Use a higher-priority QOS

# load CUDA environment
module load cuda/11.4 

# run the scripts inside the Singularity container
srun singularity run --nv ${container} python3 version_Joe/pre_tech_post_damage.py $pre_tech_post_damage_export_folder $log_xi_min $log_xi_max $batch_size $num_iterations $A_g_prime $pretrained_pre_tech_post_damage_export_folder $logging_frequency $learning_rates $hidden_layer_activations $output_layer_activations $num_hidden_layers $num_neurons $learning_rate_schedule_type $delta $tensorboard
srun singularity run --nv ${container} python3 version_Joe/post_tech_pre_damage.py $post_tech_pre_damage_export_folder $pre_tech_post_damage_export_folder $log_xi_min $log_xi_max $batch_size $num_iterations $A_g_prime $pretrained_post_tech_pre_damage_export_folder $logging_frequency $learning_rates $hidden_layer_activations $output_layer_activations $num_hidden_layers $num_neurons $learning_rate_schedule_type $delta $tensorboard
srun singularity run --nv ${container} python3 version_Joe/pre_tech_pre_damage.py $pre_tech_pre_damage_export_folder $post_tech_pre_damage_export_folder $pre_tech_post_damage_export_folder -10 $log_xi_min $log_xi_max $batch_size $num_iterations $A_g_prime $pretrained_pre_tech_pre_damage_export_folder $logging_frequency $learning_rates $hidden_layer_activations $output_layer_activations $num_hidden_layers $num_neurons $learning_rate_schedule_type $delta $tensorboard" > $job_file

sbatch $job_file


