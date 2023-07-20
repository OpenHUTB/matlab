function[show,enable]=isCompatible(sourceModel,sourceBlock)






    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
    isInport=strcmp(get_param(sourceBlock,'BlockType'),'Inport');
    isRootLevelBlock=strcmp(get_param(sourceBlock,'Parent'),sourceModel);









    if strcmp(mappingType,'AutosarTarget')




        show=autosarinstalled()...
        &&~isempty(mapping)...
        &&isRootLevelBlock&&isInport...
        &&~strcmp(get_param(sourceBlock,'OutputFunctionCall'),'on');




        enable=show&&autosar.api.Utils.autosarlicensed();
    elseif strcmp(mappingType,'CoderDictionary')
        show=~isempty(mapping)...
        &&isRootLevelBlock&&isInport...
        &&~strcmp(get_param(sourceBlock,'OutputFunctionCall'),'on');
        if show
            [isNonAutoStorageCls,~]=Simulink.CodeMapping.isSignalObjectSpecified(sourceModel,sourceBlock,true);
            show=~isNonAutoStorageCls;
        end
        enable=show&&Simulink.CodeMapping.codersLicensed();
    else
        show=false;
        enable=false;
    end
end
