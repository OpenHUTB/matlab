function[varConfigObjectNames,varConfigObjects]=importFromMFile(fileName)



    varConfigObjectNames={};%#ok<NASGU>
    varConfigObjects={};

    [~,tempVarName]=fileparts(tempname);
    eval([tempVarName,'= fileName;']);
    tempFileName=eval(tempVarName);

    try
        run(fileName);
        variablesInMFileStruct=whos;
        variantConfigurationObjectIndices=strcmp({variablesInMFileStruct.class},'Simulink.VariantConfigurationData');
        varConfigObjectNames={variablesInMFileStruct(variantConfigurationObjectIndices).name};
        for i=1:numel(varConfigObjectNames)
            varConfigObjects{end+1}=eval(varConfigObjectNames{i});%#ok<AGROW>
        end
    catch ME
        msg=message('Simulink:VariantManagerUI:ImportVCDOSyntaxErrorsHeader',tempFileName);
        err=MException(msg);
        err=err.addCause(ME);
        throwAsCaller(err);
    end
end


