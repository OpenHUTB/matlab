function[varConfigObjectNames,varConfigObjects]=importFromMatFile(fileName)



    variablesInMatFileStruct=load(fileName);
    variablesInMatFile=fieldnames(variablesInMatFileStruct);
    variantConfigurationObjectIndices=cellfun(@(X)(isa(variablesInMatFileStruct.(X),'Simulink.VariantConfigurationData')),variablesInMatFile);
    varConfigObjectNames=variablesInMatFile(variantConfigurationObjectIndices);
    varConfigObjects=cellfun(@(X)(variablesInMatFileStruct.(X)),varConfigObjectNames,'UniformOutput',false);
end
