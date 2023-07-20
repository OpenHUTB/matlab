function ctrlVarNamesList=getCtrlVarNamesList(config)






    ctrlVarNamesList=cell(1,length(config.ControlVariables));
    for ctrlVarIndex=1:length(config.ControlVariables)
        ctrlVarNamesList{ctrlVarIndex}=config.ControlVariables(ctrlVarIndex).Name;
    end
end
