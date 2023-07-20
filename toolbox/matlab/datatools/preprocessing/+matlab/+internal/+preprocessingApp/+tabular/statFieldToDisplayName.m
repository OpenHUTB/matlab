function displayName=statFieldToDisplayName(varName)

    displayName="";

    switch varName
    case "Min"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Min'));
    case "Max"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Max'));
    case "Mode"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Mode'));
    case "Mean"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Mean'));
    case "Median"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Median'));
    case "SD"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:SD'));
    case "NumMissing"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Missing'));
    case "Type"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Type'));
    case "Size"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Size'));
    case "NumUniqueValues"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Unique'));
    case "HasDuplicates"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Duplicates'));
    case "IsSorted"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Sorted'));
    case "DataType"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:DataType'));
    case "IsRegular"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Regular'));
    case "NumVariables"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumVariables'));
    case "NumObservations"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumObservations'));
    case "NumRows"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumRows'));
    case "NumColumns"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumColumns'));
    case "NumVarsWithMissing"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumVarsWithMissing'));
    case "NumVarsWithDuplicates"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumVarsWithDuplicates'));
    case "TimestampHasMissing"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:TimestampHasMissing'));
    case "TimestampHasDuplicates"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:TimestampHasDuplicates'));
    case "TimestampIsSorted"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:TimestampIsSorted'));
    case "NumOutliers"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:Outliers'));
    case "NumVarsWithOutliers"
        displayName=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:NumVarsWithOutliers'));
    end
end
