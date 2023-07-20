function ResultDescription=bugReport_StyleOneCallback(system)



    tproductID={'208','3051','10441'};productID={};
    tproductNames={'Simulink Coder','Embedded Coder','MATLAB Coder'};productNames={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=modelAdvisorObject.getInputParameters;
    for i=1:length(inputParams)
        if inputParams{i}.Value
            productID{end+1}=tproductID{i};
            productNames{end+1}=tproductNames{i};
        end
    end
    if~isempty(productID)
        ResultDescription=ModelAdvisor.Common.modelAdvisorCheck_bugReport(system,productID,productNames);
    else
        ResultDescription='Select a product and rerun the check';
    end
end