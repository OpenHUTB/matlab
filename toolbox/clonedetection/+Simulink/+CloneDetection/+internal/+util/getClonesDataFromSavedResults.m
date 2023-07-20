
function clonesRawData=getClonesDataFromSavedResults(cloneResults)





    if~isa(cloneResults,'Simulink.CloneDetection.Results')||isempty(cloneResults)...
        ||~isprop(cloneResults,'ClonesId')||isempty(cloneResults.ClonesId)
        DAStudio.error('sl_pir_cpp:creator:InvalidCloneResultsObject');
    end

    clonesId=split(cloneResults.ClonesId,",");

    if~(length(clonesId)>=3)
        DAStudio.error('sl_pir_cpp:creator:InvalidCloneResultsObject');
    end

    modelName=clonesId{2};
    clonesDataId=clonesId{3};

    clonesRawData=Simulink.CloneDetection.internal.util.getSavedResultsForVersion(...
    clonesDataId,modelName);
end

