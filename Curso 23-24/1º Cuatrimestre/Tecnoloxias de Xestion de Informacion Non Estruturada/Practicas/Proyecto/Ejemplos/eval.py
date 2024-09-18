import pandas as pd
from sklearn.metrics import f1_score
import os
import sys

'''
This method computes the standard F1 macro metric for a concrete run
Params:
    - folder: path to the folder containing the validation/test webpages grouped by class, where each subfolder represents a class
    - run: path to the run file in csv format
Return:
    - returns the F1 macro score, plus if any error was found
'''
def compute_f1(
    folder:str,
    run:str
)-> tuple:
    run = pd.read_csv(run, names=["docid", "predicted_class"]) #### we use the default separator (','). The predicted class column must be an string, e.g, "departament", "faculty", etc.

    real_values = [] ### list of real classes obtained from the subdir names
    predicted_values = [] ### list of the predicted values from the csv
    for root, _, f in os.walk(folder):
        for fil in f:
            try:
                predicted_class = run[run["docid"]==fil]["predicted_class"].values[0]
                predicted_values.append(predicted_class)
                real_class = root.split('/')[3]
                real_values.append(real_class)
            except:
                print(f'{fil} was not included for prediction. Please predict and rerun') ### You MUST generate a csv file containing all the predictions for the test/val files, otherwise the program does not evaluate your run
                sys.exit(0)
        
    return f1_score(real_values, predicted_values, average='macro')


if __name__=="__main__":
    if len(sys.argv)!=3:
        print(f'El número de parámetros es incorrectos, se necesitan 2')

    ground_truth_folder = sys.argv[1]
    run = sys.argv[2]
    f1 = compute_f1(ground_truth_folder, run)
    print(f"The F1 macro score of your run is:", f1)
