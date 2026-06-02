# Setting IV Source Data Drop Folder

This folder holds the local cleaned Project Quit / Forever Free dataset used to understand the Setting IV structure.

Current uploaded local filename:

```text
cleaned_data.05.21.csv
```

The dataset is not a production simulation input. It is used only to confirm required variables, treatment coding, the `FFConsent = 1` population size, complete-case counts for design variables, the 16 Project Quit fractional-factorial arms, and the aggregate Forever Free allocation ratio.

Required structural columns:

```text
FFConsent
FFArm
QuitOverallSEBin
QuitOverallMotivBin
EDUCATION
PQ6Quitstatus
PQ6OverallSEBin
PQ6OverallMotivBin
SOURCE.DEPTH
OUTCOME.DEPTH
STORY.DEPTH
EFFICACY.DEPTH
EXPOSURE
```

Production Setting IV simulations are synthetic-parametric and are run from:

```bash
module load r/4.4.0
Rscript Simulation_random_walk/Setting4/Simulation_Setting4.R
```

Files uploaded here are ignored by Git by default. Only this README and `.gitignore` should be committed.
