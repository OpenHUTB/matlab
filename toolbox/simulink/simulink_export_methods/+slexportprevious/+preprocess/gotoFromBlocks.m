function gotoFromBlocks(obj)


    if isR2007bOrEarlier(obj.ver)







        obj.appendRule('<BlockParameterDefaults<Block<BlockType|Goto^From><GotoTag^TagVisibility:remove>>>');

        gotoBlocks=slexportprevious.utils.findBlockType(obj.modelName,'Goto');

        if~isempty(gotoBlocks)

            blkParamDefaults=get_param(obj.modelName,'BlockParameterDefaults');
            gotoDefaultsIndex=find(strcmp({blkParamDefaults.BlockType},'Goto'),1);

            gotoTagDefault=blkParamDefaults(gotoDefaultsIndex).ParameterDefaults.GotoTag;
            gotoTagVisDefault=blkParamDefaults(gotoDefaultsIndex).ParameterDefaults.TagVisibility;

            for i=1:length(gotoBlocks)
                blk=gotoBlocks{i};
                blkGotoTag=get_param(blk,'GotoTag');
                blkTagVis=get_param(blk,'TagVisibility');


                if strcmp(blkGotoTag,gotoTagDefault)
                    blkSID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));

                    obj.appendRule(hAddParameterToBlockUsingSID(blkSID,...
                    'GotoTag',...
                    hWrapParameterValueInQuotes(gotoTagDefault)));
                end


                if strcmp(blkTagVis,gotoTagVisDefault)
                    blkSID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));

                    obj.appendRule(hAddParameterToBlockUsingSID(blkSID,...
                    'TagVisibility',...
                    hWrapParameterValueInQuotes(gotoTagVisDefault)));
                end

            end
        end

        fromBlocks=slexportprevious.utils.findBlockType(obj.modelName,'From');

        if~isempty(fromBlocks)

            blkParamDefaults=get_param(obj.modelName,'BlockParameterDefaults');
            fromDefaultsIndex=find(strcmp({blkParamDefaults.BlockType},'From'),1);

            gotoTagDefault=blkParamDefaults(fromDefaultsIndex).ParameterDefaults.GotoTag;

            for i=1:length(fromBlocks)
                blk=fromBlocks{i};
                blkGotoTag=get_param(blk,'GotoTag');


                if strcmp(blkGotoTag,gotoTagDefault)
                    blkSID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));

                    obj.appendRule(hAddParameterToBlockUsingSID(blkSID,...
                    'GotoTag',...
                    hWrapParameterValueInQuotes(gotoTagDefault)));
                end
            end
        end
    end

end

function addParameterToBlockRule=hAddParameterToBlockUsingSID(blockSID,newParameterName,newParameterValue)
    addNodeRule=hAddSiblingParameterValue(['SID|',blockSID],newParameterName,newParameterValue);
    addParameterToBlockRule=sprintf('<Block%s>',addNodeRule);
end

function addNodeRule=hAddSiblingParameterValue(siblingNode,newNodeName,newNodeValue)
    addNodeRule=sprintf('<%s:insertsibpair %s %s>',...
    siblingNode,newNodeName,newNodeValue);
end

function quotedParamValue=hWrapParameterValueInQuotes(paramValue)
    quotedParamValue=['"',paramValue,'"'];
end
