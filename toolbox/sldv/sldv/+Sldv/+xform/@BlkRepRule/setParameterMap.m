function setParameterMap(obj,blockInfo,setAdditionalMaskParamForMdlRef)



    if nargin<3
        setAdditionalMaskParamForMdlRef=false;
    end

    blockH=blockInfo.ReplacementInfo.AfterReplacementH;


    paramValues={};
    parameterMapReplacement=blockInfo.ReplacementInfo.ParameterMapReplacement;

    if isa(blockInfo,'Sldv.xform.RepMdlRefBlkTreeNode')&&~isempty(parameterMapReplacement)
        if setAdditionalMaskParamForMdlRef
            inlinedWithNewSubsys=(blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk||...
            blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
            blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk);
            if inlinedWithNewSubsys


                blockH=Sldv.xform.getChildSubSystem(blockInfo.ReplacementInfo.AfterReplacementH);
            end
            fields=fieldnames(parameterMapReplacement);
            for idx=1:length(fields)
                if any(strcmp(fields{idx},blockInfo.ExtraMaskParameters))
                    parameterMapReplacement=rmfield(parameterMapReplacement,fields{idx});
                end
            end
        else
            fields=fieldnames(parameterMapReplacement);
            for idx=1:length(fields)
                if~any(strcmp(fields{idx},blockInfo.ExtraMaskParameters))
                    parameterMapReplacement=rmfield(parameterMapReplacement,fields{idx});
                end
            end
        end
    end


    parameterMap=...
    filterParamMap(blockH,'IntrinsicDialogParameters',parameterMapReplacement);
    if strcmp(get_param(blockH,'Mask'),'on')



        parameterMap=...
        filterParamMap(blockH,'DialogParameters',parameterMapReplacement);
    end
    if~isempty(parameterMap)
        fields=fieldnames(parameterMap);
        paramValues=cell(1,2*length(fields));
        index=1;
        for i=1:length(fields)
            value=parameterMap.(fields{i});
            paramValues{index}=fields{i};
            paramValues{index+1}=value;
            index=index+2;
        end
    end

    paramValues=removeParameterFromList(obj,paramValues);

    if~isempty(paramValues)
        Sldv.xform.maskUtils.safeSetParamBlk(blockH,paramValues{:});
    end
end

function parameterMap=filterParamMap(blockH,filterType,parameterMap)
    if~isempty(parameterMap)

        diagParams=get_param(blockH,filterType);
        fields=fieldnames(parameterMap);
        for idx=1:length(fields)
            if isfield(diagParams,fields{idx})
                diagParam=diagParams.(fields{idx});







                if any(strcmp(diagParam.Attributes,'read-only'))||...
                    ~any(strcmp(diagParam.Attributes,'read-write'))
                    parameterMap=rmfield(parameterMap,fields{idx});
                end
            end
        end
    end
end













function paramValues=removeParameterFromList(obj,paramValues)
    if isempty(paramValues)
        return;
    end

    paramsToRemoveOnlyWhenEmpty={'LookupTableObject','BreakpointObject'};

    for idx=1:numel(paramsToRemoveOnlyWhenEmpty)
        paramToRemove=paramsToRemoveOnlyWhenEmpty{idx};
        paramValues=removeParameter(obj,paramValues,paramToRemove,true);
    end

    paramsToRemoveAlways={'TemplateBlock',...
    'MemberBlocks',...
    'ParameterArgumentNames',...
    'ParameterArgumentValues',...
    'AvailSigsDefaultProps'};

    for idx=1:numel(paramsToRemoveAlways)
        paramToRemove=paramsToRemoveAlways{idx};
        paramValues=removeParameter(obj,paramValues,paramToRemove,false);
    end
end

function paramValues=removeParameter(obj,paramValues,paramName,removeOnlyWhenEmpty)
    index=find(endsWith(paramValues(1:2:end),paramName));
    index=2*index-1;

    if~isempty(index)

        if~removeOnlyWhenEmpty||isempty(paramValues{index+1})
            paramValues(index+1)=[];
            paramValues(index)=[];

            if~obj.CopyOrigDialogParams&&~obj.IsBuiltin




                msgID='Sldv:xform:BlkRepRule:setParameterMap:ReadOnlyParameter';
                msg=getString(message(msgID,paramName,obj.FileName,obj.ReplacementPath));
                warning(msgID,msg);
            end
        end
    end
end


