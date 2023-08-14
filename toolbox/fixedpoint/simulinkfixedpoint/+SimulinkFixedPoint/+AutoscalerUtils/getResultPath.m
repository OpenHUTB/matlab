function resultPath=getResultPath(result)






    actualSourcesIDs=SimulinkFixedPoint.AutoscalerUtils.getActualSrcForResult(result);


    resultPath=cell(length(actualSourcesIDs),1);
    for sourceIndex=1:length(actualSourcesIDs)
        if actualSourcesIDs{sourceIndex}.isValid
            resultPath{sourceIndex}=actualSourcesIDs{sourceIndex}.getRelativePath();
        else
            resultPath{sourceIndex}='';
        end
    end
end
