function parseParameterMap(obj,blockInfo)




    parameterMap=obj.ParameterMap;
    if~isempty(parameterMap)
        fields=fieldnames(parameterMap);
        for i=1:length(fields)
            replacementfield=fields{i};
            sourcefield=parameterMap.(replacementfield);
            newsourcefield=[];
            while(1)
                [head,sourcefield]=strtok(sourcefield,'$');%#ok<STTOK>
                if~isempty(head)
                    if contains(head,'original.')
                        parameter=strrep(head,'original.','');
                        try
                            actualparam=get_param(blockInfo.ReplacementInfo.BlockToReplaceH,parameter);
                        catch Mex
                            if~strcmp(Mex.identifier,...
                                'Simulink:modelReference:InstParam_ModelContainsPromotedInstParam')
                                error(message('Sldv:xform:BlkRepRule:parseParameterMap:ParameterValue',...
                                parameter,getfullname(blockInfo.ReplacementInfo.BlockToReplaceH)));
                            else
                                actualparam='';
                            end
                        end
                        newsourcefield=[newsourcefield,actualparam];%#ok<AGROW>
                    else
                        newsourcefield=[newsourcefield,head];%#ok<AGROW>
                    end
                else
                    break;
                end
            end
            parameterMap.(replacementfield)=newsourcefield;
        end
    end
    if obj.CopyOrigDialogParams
        if strcmp(get_param(blockInfo.ReplacementInfo.BlockToReplaceH,'Mask'),'on')
            paramNames=...
            Sldv.xform.maskUtils.getMaskParameterNames(blockInfo.ReplacementInfo.BlockToReplaceH);
        else
            srcBlockDialogParameters=...
            get_param(blockInfo.ReplacementInfo.BlockToReplaceH,'IntrinsicDialogParameters');
            paramNames=fieldnames(srcBlockDialogParameters);
        end
        for i=1:length(paramNames)
            replacementfield=paramNames{i};
            if~isfield(parameterMap,replacementfield)
                parameterMap.(replacementfield)=...
                get_param(blockInfo.ReplacementInfo.BlockToReplaceH,replacementfield);
            end
        end
    end

    if~obj.ReplacementBlockUpdatedOnInstance&&...
        ~isempty(parameterMap)
        parametersToSet=fieldnames(parameterMap);
        obj.refreshPopupParams;
        if~isempty(obj.PopupParamsReplacementBlk)
            maskParamNames=fieldnames(obj.PopupParamsReplacementBlk);
            common=intersect(parametersToSet,maskParamNames);
            for idx=1:length(common)
                if ischar(parameterMap.(common{idx}))
                    enumchoices=obj.PopupParamsReplacementBlk.(common{idx});
                    if~any(strcmp(parameterMap.(common{idx}),enumchoices))
                        error(message('Sldv:xform:BlkRepRule:parseParameterMap:ParameterEnumValue',...
                        getfullname(obj.ReplacementPath),...
                        common{idx},...
                        parameterMap.(common{idx}),...
                        getfullname(blockInfo.ReplacementInfo.BlockToReplaceH)));
                    end
                end
            end
        end
    end

    blockInfo.ReplacementInfo.ParameterMapReplacement=parameterMap;
end