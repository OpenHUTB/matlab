function replaceBlock(obj,blockInfo)




    if obj.UseOriginalBlockAsReplacement
        Block=getfullname(blockInfo.ReplacementInfo.BlockToReplaceH);

        blockInfo.ReplacementInfo.AfterReplacementH=get_param(Block,'Handle');

        obj.safeRunPostReplacementCallBack(blockInfo);

        blockInfo.ReplacementInfo.Replaced=true;

        blockInfo.ReplacementInfo.PostReplacementMsgs{end+1}=...
        blockInfo.ReplacementInfo.Rule.FileName;

    else


        if strcmp(obj.ReplacementMode,'Stub')&&slavteng('feature','SSysStubbing')
            obj.updateStubBlock(blockInfo);
        else
            obj.updateReplacementBlock(blockInfo);
        end

        obj.parseParameterMap(blockInfo);

        obj.replaceBlockWithLibraryLink(blockInfo);

        obj.setParameterMap(blockInfo);

        if isa(blockInfo,'Sldv.xform.RepMdlRefBlkTreeNode')

            obj.setParameterMap(blockInfo,true);
        end

        obj.safeRunPostReplacementCallBack(blockInfo);

        Sldv.xform.BlkRepRule.fixAttributesFormatString(blockInfo.ReplacementInfo.AfterReplacementH);


        blockInfo.ReplacementInfo.Replaced=true;

        afterReplacementH=blockInfo.ReplacementInfo.AfterReplacementH;

        Sldv.xform.BlkRepRule.fixMaskParameterEvalSettings(afterReplacementH);

        if strcmp(get_param(afterReplacementH,'BlockType'),'SubSystem')&&...
            ~isempty(get_param(afterReplacementH,'MaskDescription'))
            blockInfo.ReplacementInfo.PostReplacementMsgs{end+1}=...
            get_param(afterReplacementH,'MaskDescription');
        else
            blockInfo.ReplacementInfo.PostReplacementMsgs{end+1}=...
            blockInfo.ReplacementInfo.Rule.FileName;
        end

        if~obj.InlineOnlyMode
            if blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk||...
                blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
                blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk
                subsystemsH=Sldv.xform.getChildSubSystem(blockInfo.ReplacementInfo.AfterReplacementH);
                nameaAfterRep=get_param(blockInfo.ReplacementInfo.AfterReplacementH,'Name');
                set_param(subsystemsH,'Name',nameaAfterRep);
                blockInfo.ReplacementInfo.AfterReplacementH=subsystemsH;
            end
        end
    end
end

