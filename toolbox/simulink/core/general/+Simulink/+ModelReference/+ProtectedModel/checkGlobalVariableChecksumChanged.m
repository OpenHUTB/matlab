function checkGlobalVariableChecksumChanged(slxpFileName,checksums)








    computeIndividualVarChecksums=isfield(checksums,'varChecksums');


    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0...
        &&~isfield(checksums,'enableAccessToBaseWorkspace')
        if strcmp(checksums.designDataLocation,'base')
            checksums.enableAccessToBaseWorkspace='on';
        else
            checksums.enableAccessToBaseWorkspace='off';
        end
    end

    [currentChecksum,currentVarChecksums]=slprivate('getGlobalParamChecksum',...
    slxpFileName,...
    'SIM',...
    checksums.variables,...
    checksums.inlineParameters,...
    checksums.ignoreCSCs,...
    checksums.designDataLocation,...
    true,...
    computeIndividualVarChecksums,...
    checksums.enableAccessToBaseWorkspace);

    if isequal(currentChecksum,checksums.checksum)
        return;
    end

    if computeIndividualVarChecksums

        [checksumFromDD,varChecksumsFromDD]=Simulink.ModelReference.ProtectedModel.getVariableChecksumFromSlxp...
        (slxpFileName,checksums.variables,checksums.inlineParameters,checksums.ignoreCSCs);
        if isequal(currentChecksum,checksumFromDD)
            return;
        end


        [varList,~]=slprivate('getChangedGlobalVariablesFromChecksums',...
        checksums.variables.VarList,varChecksumsFromDD,currentVarChecksums);
        msgID='Simulink:protectedModel:protectedModelGlobalVariablesChanged';
    else
        varList=checksums.variables.VarList;
        msgID='Simulink:protectedModel:protectedModelGlobalVariablesChangedBefore21a';
    end
    DAStudio.error(msgID,slxpFileName,varList);
end


