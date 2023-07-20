function isValid=isValidCtrlVarName(ctrlVarRowObj,newCtrlVarName)








    if~isvarname(newCtrlVarName)
        isValid=false;
        return;
    end
    ctrlVarNamesList=ctrlVarRowObj.CtrlVarSSSrc.getControlVariableNames();
    ctrlVarNamesList(ctrlVarRowObj.CtrlVarIdx)=[];
    isValid=~ismember(newCtrlVarName,ctrlVarNamesList);
end
