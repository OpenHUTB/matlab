function status=isSafeToReplaceUnderSelfModifMask(obj,blockInfo)




    status=true;








    if~(obj.CopyOrigDialogParams||obj.IgnoreUnderSelfModifMaskedSubsystemCheck)
        if isempty(obj.AllParamNamesOnReplacementBlock)

            maskParamNamesReplacementBlock=...
            Sldv.xform.maskUtils.getMaskParameterNames(obj.ReplacementPath);
            intrinsicParamNamesReplacementBlock=...
            fieldnames(get_param(obj.ReplacementPath,'IntrinsicDialogParameters'));
            allParamNames=...
            union(maskParamNamesReplacementBlock,intrinsicParamNamesReplacementBlock);
            if isstruct(obj.ParameterMap)
                allParamNames=...
                union(allParamNames,fieldnames(obj.ParameterMap));
            end
            if isempty(allParamNames)
                obj.AllParamNamesOnReplacementBlock={'DVBlockRepNoPARAM'};
            else
                obj.AllParamNamesOnReplacementBlock=allParamNames;
            end
        end

        if length(obj.AllParamNamesOnReplacementBlock)==1&&...
            strcmp(obj.AllParamNamesOnReplacementBlock{1},'DVBlockRepNoPARAM')
            allParamNamesOnReplacementBlock={};
        else
            allParamNamesOnReplacementBlock=...
            obj.AllParamNamesOnReplacementBlock;
        end

        maskParamNamesBlockToReplace=...
        Sldv.xform.maskUtils.getMaskParameterNames(blockInfo.BlockH);
        intrinsicParamNamesBlockToReplace=...
        fieldnames(get_param(blockInfo.BlockH,'IntrinsicDialogParameters'));
        if(~isempty(setdiff(maskParamNamesBlockToReplace,allParamNamesOnReplacementBlock)))||...
            (~isempty(setdiff(intrinsicParamNamesBlockToReplace,allParamNamesOnReplacementBlock)))
            status=false;
        end
    end
end
