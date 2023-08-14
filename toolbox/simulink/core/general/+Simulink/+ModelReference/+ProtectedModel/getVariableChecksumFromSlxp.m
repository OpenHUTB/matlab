function[checksumFromDD,varChecksumsFromDD]=getVariableChecksumFromSlxp...
    (protectedModelFile,variables,inlineParameters,ignoreCSCs)










    initialDir=pwd;
    destDir=tempname;
    mkdir(destDir);
    cd(destDir);
    addpath(initialDir);
    ocPath=onCleanup(@()loc_handleTempDirAtClosing(destDir,initialDir));


    Simulink.ModelReference.ProtectedModel.unpackDDForChecksum(protectedModelFile,destDir);

    DataSourceOfVariablesinSLXP=getString(message...
    ('Simulink:protectedModel:dataDictionaryToConfirmChecksumMismatch'));
    mapOfVariablesinSLXP=getString(message...
    ('Simulink:protectedModel:mapToConfirmChecksumMismatch'));



    variables.VarList=getVarlistInSlxpfile...
    (variables.VarList,mapOfVariablesinSLXP,DataSourceOfVariablesinSLXP);

    [~,tempModel,~]=fileparts(tempname);
    new_system(tempModel);
    c=onCleanup(@()close_system(tempModel,0));

    [checksumFromDD,varChecksumsFromDD]=slprivate('get_modelref_global_variable_checksum',...
    tempModel,...
    'SIM',...
    variables,...
    inlineParameters,...
    ignoreCSCs,...
    DataSourceOfVariablesinSLXP,...
    true,...
    true,...
    'off');

end


function varList=getVarlistInSlxpfile(originalVarList,mapFileName,sourceName)
    map=load(mapFileName);
    varList='';
    allOriginalVar=split(originalVarList,',');
    for i=1:numel(allOriginalVar)
        if isKey(map.mapVariables,allOriginalVar{i})
            var=map.mapVariables(allOriginalVar{i});
            qualifiedName=Simulink.dd.private.getQualifiedVarName(var,sourceName);
            varList=append(varList,qualifiedName,',');
        end
    end
    varList=strip(varList,'right',',');

end

function out=loc_handleTempDirAtClosing(tmpBuildFolder,initialDir)
    rmpath(initialDir);
    cd(initialDir);
    slprivate('removeDir',tmpBuildFolder);
end

