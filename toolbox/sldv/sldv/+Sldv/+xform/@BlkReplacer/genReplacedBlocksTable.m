function genReplacedBlocksTable(obj)




    if obj.RepMdlGenerated
        mdlRefBlockInlined=~isempty(obj.ReplacedMdlRefBlks);
        for idx=1:length(obj.ReplacedMdlRefBlks)
            [blockH,maskBlockH]=getSubsystemReplacedModelBlock(obj.ReplacedMdlRefBlks{idx}.ReplacementInfo);
            repInfo=genRepInfo(blockH,obj.ReplacedMdlRefBlks{idx}.ReplacementInfo,maskBlockH);
            repInfo.BeforeRepFullPath=obj.deriveOriginalBlockPath(maskBlockH,...
            repInfo.BeforeRepFullPath,mdlRefBlockInlined);
            obj.ReplacedBlocksTable(maskBlockH)=repInfo;
        end

        for idx=1:length(obj.MdlInfo.SubSystemsToReplace)
            if obj.MdlInfo.SubSystemsToReplace{idx}.ReplacementInfo.Replaced
                blockH=obj.MdlInfo.SubSystemsToReplace{idx}.ReplacementInfo.AfterReplacementH;
                repInfo=genRepInfo(blockH,obj.MdlInfo.SubSystemsToReplace{idx}.ReplacementInfo);
                repInfo.BeforeRepFullPath=obj.deriveOriginalBlockPath(blockH,...
                repInfo.BeforeRepFullPath,mdlRefBlockInlined);
                obj.ReplacedBlocksTable(blockH)=repInfo;
            end
        end

        for idx=1:length(obj.MdlInfo.BuiltinBlksToReplace)
            if obj.MdlInfo.BuiltinBlksToReplace{idx}.ReplacementInfo.Replaced
                blockH=obj.MdlInfo.BuiltinBlksToReplace{idx}.ReplacementInfo.AfterReplacementH;
                repInfo=genRepInfo(blockH,obj.MdlInfo.BuiltinBlksToReplace{idx}.ReplacementInfo);
                repInfo.BeforeRepFullPath=obj.deriveOriginalBlockPath(blockH,...
                repInfo.BeforeRepFullPath,mdlRefBlockInlined);
                obj.ReplacedBlocksTable(blockH)=repInfo;
            end
        end
    end
end

function[blockH,maskBlockH]=getSubsystemReplacedModelBlock(replacementInfo)
    blockH=replacementInfo.AfterReplacementH;
    if replacementInfo.IsMaskConstructedMdlBlk||...
        replacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
        replacementInfo.IsSignalSpecReqEnabledMdlBlk
        maskBlockH=get_param(get_param(blockH,'Parent'),'Handle');
    else
        maskBlockH=blockH;
    end
end

function repInfo=genRepInfo(blockH,replacementInfo,maskBlockH)
    if nargin<3
        maskBlockH=blockH;
    end
    repInfo.BeforeRepFullPath=getfullname(maskBlockH);
    repInfo.ReplacementFullPath=getfullname(blockH);
    repRuleApplied=replacementInfo.Rule;
    repInfo.RepRuleInfo.RuleName=repRuleApplied.FileName;
    repInfo.RepRuleInfo.IsBuiltin=repRuleApplied.IsBuiltin;
    repInfo.RepRuleInfo.IsAuto=repRuleApplied.IsAuto;
    repInfo.RepRuleInfo.Priority=repRuleApplied.Priority;
    repInfo.RepRuleInfo.BlockType=repRuleApplied.BlockType;
    repInfo.RepRuleInfo.Description=replacementInfo.PostReplacementMsgs{1};
    repInfo.RepRuleInfo.IsMaskConstructedMdlBlk=replacementInfo.IsMaskConstructedMdlBlk;
    repInfo.RepRuleInfo.IsSignalSpecReqTriggeredMdlBlk=replacementInfo.IsSignalSpecReqTriggeredMdlBlk;
    repInfo.RepRuleInfo.IsSignalSpecReqEnabledMdlBlk=replacementInfo.IsSignalSpecReqEnabledMdlBlk;
    repInfo.RepRuleInfo.InlinedWithNewSubsys=(replacementInfo.IsMaskConstructedMdlBlk||...
    replacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
    replacementInfo.IsSignalSpecReqEnabledMdlBlk);
end