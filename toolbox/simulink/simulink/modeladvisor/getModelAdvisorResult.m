function resultArray=getModelAdvisorResult(system)





    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultArray={};
    recordCellArray=mdladvObj.CheckCellArray;
    for i=1:length(recordCellArray)
        if recordCellArray{i}.Selected
            resultArray{end+1}=recordCellArray{i}.Result;
        end
    end
