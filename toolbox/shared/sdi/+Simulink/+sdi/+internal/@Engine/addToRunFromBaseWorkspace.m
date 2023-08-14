function signalIDs=addToRunFromBaseWorkspace(this,runID,VarNames)




    VarValues=Simulink.sdi.internal.Util.baseWorkspaceValuesForNames(VarNames);


    emptyInd=cellfun(@isempty,VarValues);
    indices=find(emptyInd,1);


    if~isempty(indices)
        Simulink.sdi.internal.warning(message('SDI:sdi:notValidBaseWorkspaceVar'));
    end


    signalIDs=this.addToRunFromNamesAndValues(runID,VarNames,VarValues);
end
