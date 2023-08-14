function[TunableParamNameList,TunableParamDimList,TunableParamDTypeList,TunableParamValueList]=getTunableParameter(dutBlk)




    TunableParamNameList={};
    TunableParamDimList={};
    TunableParamDTypeList={};
    TunableParamValueList={};
    dutBlkH=get_param(dutBlk,'handle');

    topLevelH=bdroot(dutBlkH);
    topLevelName=get_param(topLevelH,'Name');
    needsCompile=strcmpi(get_param(topLevelH,'CompiledSinceLastChange'),'off');

    if needsCompile
        searchMethod='compiled';
    else
        searchMethod='precached';
    end




    registerReadBlks=find_system(dutBlkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','IP Core Register Read');
    for i=1:numel(registerReadBlks)
        slbh=registerReadBlks(i);
        value=get_param(slbh,'RegisterName');
        dim=[1,str2num(get_param(slbh,'OutputVectorSize'))];
        dtype=get_param(slbh,'OutDataTypeStr');
        TunableParamNameList{end+1}=value;
        TunableParamDimList{end+1}=dim;
        TunableParamDTypeList{end+1}=dtype;
        TunableParamValueList{end+1}=zeros(dim);
    end




    constBlocks=find_system(dutBlkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Constant');
    for i=1:numel(constBlocks)
        slbh=constBlocks(i);
        value=get_param(slbh,'Value');
        var=[];
        try
            var=Simulink.findVars(topLevelName,'name',value,'searchmethod',searchMethod);
        catch
        end
        if~isempty(var)&&(numel(var)==1)
            switch var.SourceType
            case 'data dictionary'
                dictionaryObj=Simulink.data.dictionary.open(var.Source);
                sectionObj=getSection(dictionaryObj,'Design Data');
                obj=evalin(sectionObj,value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    if~any(strcmp(value,TunableParamNameList))
                        TunableParamNameList{end+1}=value;
                        TunableParamDimList{end+1}=obj.Dimensions;
                        TunableParamDTypeList{end+1}=obj.DataType;
                        TunableParamValueList{end+1}=obj.Value;
                    end
                end
                close(dictionaryObj);
            case 'base workspace'
                obj=evalin('base',value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    if~any(strcmp(value,TunableParamNameList))
                        TunableParamNameList{end+1}=value;
                        TunableParamDimList{end+1}=obj.Dimensions;
                        TunableParamDTypeList{end+1}=obj.DataType;
                        TunableParamValueList{end+1}=obj.Value;
                    end
                end
            otherwise

            end
        end
    end




    gainBlocks=find_system(dutBlkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Gain');
    for i=1:numel(gainBlocks)
        slbh=gainBlocks(i);
        value=get_param(slbh,'Gain');
        var=[];
        try
            var=Simulink.findVars(topLevelName,'name',value,'searchmethod',searchMethod);
        catch
        end
        if~isempty(var)&&(numel(var)==1)
            switch var.SourceType
            case 'data dictionary'
                dictionaryObj=Simulink.data.dictionary.open(var.Source);
                sectionObj=getSection(dictionaryObj,'Design Data');
                obj=evalin(sectionObj,value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    if~any(strcmp(value,TunableParamNameList))
                        TunableParamNameList{end+1}=value;
                        TunableParamDimList{end+1}=obj.Dimensions;
                        TunableParamDTypeList{end+1}=obj.DataType;
                        TunableParamValueList{end+1}=obj.Value;
                    end
                end
                close(dictionaryObj);
            case 'base workspace'
                obj=evalin('base',value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    if~any(strcmp(value,TunableParamNameList))
                        TunableParamNameList{end+1}=value;
                        TunableParamDimList{end+1}=obj.Dimensions;
                        TunableParamDTypeList{end+1}=obj.DataType;
                        TunableParamValueList{end+1}=obj.Value;
                    end
                end
            otherwise

            end
        end
    end
end

