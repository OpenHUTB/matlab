function originalFullPath=deriveOriginalBlockPath(obj,blockH,...
    originalFullPath,mdlRefBlockInlined)




    parentHToCheck=[];
    if mdlRefBlockInlined
        blockHToCheck=blockH;
        while true
            parent=get_param(blockHToCheck,'Parent');
            if strcmp(get_param(parent,'Type'),'block_diagram')||...
                ~strcmp(get_param(parent,'BlockType'),'SubSystem')
                break;
            else
                parentH=get_param(parent,'Handle');
                if obj.ReplacedBlocksTable.isKey(parentH)&&...
                    strcmp(obj.ReplacedBlocksTable(parentH).RepRuleInfo.BlockType,'ModelReference')

                    parentHToCheck=parentH;
                    break;
                else
                    blockHToCheck=parentH;
                end
            end
        end
        if~isempty(parentHToCheck)


            preReplacementFullPathInInlinedMdl=originalFullPath;
            replacedParentInfo=obj.ReplacedBlocksTable(parentHToCheck);
            if replacedParentInfo.RepRuleInfo.IsMaskConstructedMdlBlk||...
                replacedParentInfo.RepRuleInfo.IsSignalSpecReqTriggeredMdlBlk||...
                replacedParentInfo.RepRuleInfo.IsSignalSpecReqEnabledMdlBlk
                subsystemsH=Sldv.xform.getChildSubSystem(parentHToCheck);
                parentFullPathInInlinedMdl=getfullname(subsystemsH);
            else
                parentFullPathInInlinedMdl=getfullname(parentHToCheck);
            end
            relativePath=...
            preReplacementFullPathInInlinedMdl(length(parentFullPathInInlinedMdl)+1:end);
            RefMdlName=get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');
            originalPath=[RefMdlName,relativePath];
            originalFullPath=getfullname(get_param(originalPath,'Handle'));
        end
    end
    if~mdlRefBlockInlined||isempty(parentHToCheck)
        blockFullPathInReplacedMdl=getfullname(blockH);
        replacedModel=get_param(obj.MdlInfo.ModelH,'Name');
        originalModel=get_param(obj.MdlInfo.OrigModelH,'Name');

        if startsWith(blockFullPathInReplacedMdl,[replacedModel,'/'])
            blockRelativePath=blockFullPathInReplacedMdl(length(replacedModel)+1:end);
            blockOriginalPath=[originalModel,blockRelativePath];
            originalFullPath=getfullname(get_param(blockOriginalPath,'Handle'));
        end
    end
end
