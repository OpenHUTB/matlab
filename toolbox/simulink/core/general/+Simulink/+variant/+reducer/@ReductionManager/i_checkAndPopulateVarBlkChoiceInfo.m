

function varBlkChoiceInfoStructsVec=i_checkAndPopulateVarBlkChoiceInfo(compVarBlockPath,varBlkChoiceInfoStructsVec,varBlkActChoice,varargin)



    if nargin==5
        isLib=true;
        varBlock=varargin{1};
        isMultiInstance=varargin{2};
    else
        isLib=false;
        varBlock=compVarBlockPath;
        isMultiInstance=false;
    end


    idx=Simulink.variant.reducer.utils.searchNameInCell(varBlock,{varBlkChoiceInfoStructsVec.BlockPath});

    if isempty(idx)













        varBlkChoiceInfoStruct=Simulink.variant.reducer.types.VRedVariantBlockChoiceInfo;
        varBlockType=get_param(varBlock,'BlockType');
        isVSS=slInternal('isVariantSubsystem',get_param(varBlock,'Handle'));
        isVarSrc=~isVSS&&strcmp(varBlockType,'VariantSource');
        isVarSnk=~isVarSrc&&strcmp(varBlockType,'VariantSink');
        isMdlVar=~isVarSnk&&strcmp(varBlockType,'ModelReference')&&...
        strcmp('on',get_param(varBlock,'Variant'));
        isVarSLFcn=~isMdlVar&&slInternal('isSimulinkFunction',get_param(varBlock,'Handle'));
        isVarIRTFcn=~isVarSLFcn&&slInternal('isInitTermOrResetSubsystem',get_param(varBlock,'Handle'));

        if isVSS
            varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SUBSYSTEM;
            varStruct=get_param(varBlock,'Variants');
            varBlkChoiceInfoStruct.AllChoiceNames=(i_replaceCarriageReturnWithSpace({varStruct.BlockName}))';
            updateVSSActiveChoice(varBlkChoiceInfoStruct,...
            varBlkActChoice.CompiledActiveChoice,compVarBlockPath,...
            varBlock,isLib);
            varBlkChoiceInfoStruct.isAZVCActivated=varBlkActChoice.isAZVCActivated;

        elseif isVarSrc||isVarSnk
            if isVarSrc
                varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SOURCE;
            elseif isVarSnk
                varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SINK;
            end
            varBlkChoiceInfoStruct.NumberOfChoices=numel(get_param(varBlock,'VariantControls'));
            varBlkChoiceInfoStruct.ActiveChoiceNumbers=str2double(varBlkActChoice.CompiledActiveChoice);
        elseif isMdlVar
            varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.MODEL_VARIANT;
            varStruct=get_param(varBlock,'Variants');
            varBlkChoiceInfoStruct.NumberOfChoices=numel(varStruct);
            varBlkChoiceInfoStruct.ActiveChoiceNumbers=Simulink.variant.reducer.utils.searchNameInCell(varBlkActChoice.CompiledActiveChoice,{varStruct.Name});
        elseif isVarSLFcn
            varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SIMULINK_FUNCTION;
        elseif isVarIRTFcn
            varBlkChoiceInfoStruct.BlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_IRT_SUBSYSTEM;
        end

        varBlkChoiceInfoStruct.BlockPath=varBlock;
        varBlkChoiceInfoStruct.NumberOfConfigsActive=1;
        varBlkChoiceInfoStructsVec(end+1)=varBlkChoiceInfoStruct;

    else

        varBlkChoiceInfoStruct=varBlkChoiceInfoStructsVec(idx);
        varBlockType=varBlkChoiceInfoStruct.BlockType;

        if varBlockType.isVariantSubsystem()
            updateVSSActiveChoice(varBlkChoiceInfoStruct,...
            varBlkActChoice.CompiledActiveChoice,compVarBlockPath,...
            varBlock,isLib);
            varBlkChoiceInfoStruct.isAZVCActivated=varBlkChoiceInfoStruct.isAZVCActivated||...
            varBlkActChoice.isAZVCActivated;
        elseif varBlockType.isVariantSource()||varBlockType.isVariantSink()
            varBlkChoiceInfoStruct.ActiveChoiceNumbers=unique([varBlkChoiceInfoStruct.ActiveChoiceNumbers;str2double(varBlkActChoice.CompiledActiveChoice)]);
        elseif varBlockType.isModelVariant()
            varStruct=get_param(compVarBlockPath,'Variants');
            varBlkChoiceInfoStruct.ActiveChoiceNumbers=unique([varBlkChoiceInfoStruct.ActiveChoiceNumbers;Simulink.variant.reducer.utils.searchNameInCell(varBlkActChoice.CompiledActiveChoice,{varStruct.Name})]);
        elseif varBlockType.isVariantSimulinkFunction()||varBlockType.isVariantIRTSubsystem

        end





        if~isMultiInstance
            varBlkChoiceInfoStruct.NumberOfConfigsActive=1+varBlkChoiceInfoStruct.NumberOfConfigsActive;
        end
        varBlkChoiceInfoStructsVec(idx)=varBlkChoiceInfoStruct;

    end
end

function updateVSSActiveChoice(varBlkChoiceInfoStruct,activeChoices,compVarBlockPath,varBlock,isLib)





    if~iscell(activeChoices)
        activeChoices={activeChoices};
    end

    currActiveChoices=cell(numel(activeChoices),1);
    for choiceIdx=1:numel(activeChoices)
        activeChoice=activeChoices{choiceIdx};
        if isLib

            currActiveChoices{choiceIdx}=[varBlock,...
            activeChoice((numel(compVarBlockPath)+1):end)];
        else

            currActiveChoices{choiceIdx}=activeChoice;
        end
    end
    allActiveChoices=[varBlkChoiceInfoStruct.ActiveChoiceNames;currActiveChoices];
    varBlkChoiceInfoStruct.ActiveChoiceNames=unique(allActiveChoices);
end


