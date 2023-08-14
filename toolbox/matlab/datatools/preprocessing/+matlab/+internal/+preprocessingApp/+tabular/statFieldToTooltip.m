function tooltip=statFieldToTooltip(varName)


    tooltip="";
    switch varName
    case "Min"
        tooltip="";
    case "Max"
        tooltip="";
    case "Mode"
        tooltip="";
    case "Mean"
        tooltip="";
    case "Median"
        tooltip="";
    case "SD"
        tooltip="";
    case "NumMissing"
        tooltip="";
    case "Type"
        tooltip="";
    case "Size"
        tooltip="";
    case "NumUniqueValues"
        tooltip="";
    case "HasDuplicates"
        tooltip="";
    case "IsSorted"
        tooltip="";
    case "DataType"
        tooltip="";
    case "IsRegular"
        tooltip="";
    case "NumVariables"
        tooltip="";
    case "NumObservations"
        tooltip="";
    case "NumRows"
        tooltip="";
    case "NumColumns"
        tooltip="";
    case "NumVarsWithMissing"
        tooltip="";
    case "NumVarsWithDuplicates"
        tooltip="";
    case "TimestampHasMissing"
        tooltip="";
    case "TimestampHasDuplicates"
        tooltip="";
    case "TimestampIsSorted"
        tooltip="";
    case "NumOutliers"
        tooltip=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:OutliersTooltip'));
    case "NumVarsWithOutliers"
        tooltip=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:OutliersTooltip'));
    end
end
