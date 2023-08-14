function neverReplace=blkrep_is_never_replace_mdlblock(blockH,blockInfo)





    neverReplace=strcmp(get_param(blockH,'ProtectedModel'),'on');
    referencedModelName=get_param(blockH,'ModelName');
    isNotExportFcnMdl=strcmpi(get_param(referencedModelName,'IsExportFunctionModel'),'off');
    if~neverReplace&&...
        ~isempty(blockInfo)&&...
        ~isempty(blockInfo.CompIOInfo)
        for idx=1:length(blockInfo.CompIOInfo)
            cinfo=blockInfo.CompIOInfo(idx);
            if strcmp(cinfo.portAttributes.AliasThruDataType,'fcn_call')&&...
                cinfo.portAttributes.SampleTime(1)==-1&&...
                cinfo.portAttributes.SampleTime(2)<0&&...
isNotExportFcnMdl
                blockInfo.ReplacementInfo.BlockToReplaceH=blockH;
                blockInfo.ReplacementInfo.IsReplaceableMsgs{end+1}=...
                getString(message('Sldv:Compatibility:AsyncFcnCall'));
                neverReplace=true;
            else
                blkObj=get_param(blockH,'Object');
                parent=blkObj.getParent;
                if isa(parent,'Simulink.BlockDiagram')
                    dataTypeOverrifeOfParent=get_param(parent.Handle,'DataTypeOverride');
                else
                    dataTypeOverrifeOfParent=get_param(parent.Handle,'DataTypeOverride_Compiled');
                end
                dataTypeOverrideOnRefModel=get_param(referencedModelName,'DataTypeOverride');
                if~strcmp(dataTypeOverrifeOfParent,'UseLocalSettings')&&...
                    ~strcmp(dataTypeOverrifeOfParent,dataTypeOverrideOnRefModel)

                    blockInfo.ReplacementInfo.BlockToReplaceH=blockH;
                    blockInfo.ReplacementInfo.IsReplaceableMsgs{end+1}=...
                    getString(message('Sldv:Compatibility:DataTypeOverride',dataTypeOverrifeOfParent,referencedModelName));
                    neverReplace=true;
                end
            end
        end
    end
    if~neverReplace&&...
        ~isempty(blockInfo)&&...
        ~slavteng('feature','InstanceSpecificParameters')&&...
        blockInfo.hasMultiLevelModelParameter
        blockInfo.ReplacementInfo.BlockToReplaceH=blockH;
        blockInfo.ReplacementInfo.IsReplaceableMsgs{end+1}=...
        getString(message('Sldv:Compatibility:MultiLevelModelReferenceParameters'));
        neverReplace=true;
    end

    if~neverReplace&&~isempty(blockInfo)&&~blockInfo.isUsageOfSlexprAllowed()
        blockInfo.ReplacementInfo.BlockToReplaceH=blockH;
        blockInfo.ReplacementInfo.IsReplaceableMsgs{end+1}=...
        getString(message('Sldv:Compatibility:SlexprUsedInReferencedModel'));
        neverReplace=true;
    end

end
