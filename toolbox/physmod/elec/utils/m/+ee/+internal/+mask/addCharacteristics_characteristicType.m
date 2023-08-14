function addCharacteristics_characteristicType(modelName)
    blockName=[modelName,'/Characteristics'];
    stringInput=get_param(blockName,'targetOrSimulatedData');
    maskNames=get_param(blockName,'MaskNames');
    visibility=cell(1,length(maskNames));
    for ii=1:length(maskNames)
        if(strcmp(maskNames{ii},'sweepRange')&&(strcmp(stringInput,'Target only')||strcmp(stringInput,'Target and simulated')))...
            ||(strcmp(stringInput,'Simulated only')&&(strcmp(maskNames{ii},'sweepValues')||strcmp(maskNames{ii},'outputValues')))
            visibility{ii}='off';
        else
            visibility{ii}='on';
        end
    end
    set_param(blockName,'MaskVisibilities',visibility);
end