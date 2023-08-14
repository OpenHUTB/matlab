function replacedBlocksInfo=genReplacedBlocksInfo(replacementModelH,varargin)



    replacementInfo=[];
    if(nargin>1)
        replacementInfo=varargin{1};
    end

    if isempty(replacementInfo)
        replacedBlocksTable=Sldv.xform.BlkReplacer.getInstance().ReplacedBlocksTable;
        entryKeys=replacedBlocksTable.keys;

        if isempty(entryKeys)
            replacedBlocksInfo={};
        else
            nonAuto=0;
            for idx=1:length(entryKeys)
                entry=replacedBlocksTable(entryKeys{idx});
                if~entry.RepRuleInfo.IsAuto
                    nonAuto=nonAuto+1;
                end
            end

            if nonAuto==0
                replacedBlocksInfo={};
            else
                blockColumn=cell(1,nonAuto+1);
                ruleColumn=cell(1,nonAuto+1);
                blockTypeColumn=cell(1,nonAuto+1);
                descriptionColumn=cell(1,nonAuto+1);

                blockColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:ReplacedBlockColname'));
                ruleColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:ReplacementRuleMATLABFileColName'));
                blockTypeColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:BlockTypesColName'));
                descriptionColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RuleDescriptionsColName'));

                replacementModelName=get_param(replacementModelH,'Name');

                counter=2;
                for idx=1:length(entryKeys)
                    entry=replacedBlocksTable(entryKeys{idx});
                    if~entry.RepRuleInfo.IsAuto
                        path=strrep(getfullname(entryKeys{idx}),replacementModelName,'.');
                        blockColumn{counter}=cr_to_space(path);
                        ruleColumn{counter}=entry.RepRuleInfo.RuleName;
                        blockTypeColumn{counter}=entry.RepRuleInfo.BlockType;
                        descriptionColumn{counter}=cr_to_space(entry.RepRuleInfo.Description);
                        counter=counter+1;
                    end
                end

                replacementTable.blocks=blockColumn;
                replacementTable.rules=ruleColumn;
                replacementTable.blockTypes=blockTypeColumn;
                replacementTable.descriptions=descriptionColumn;
                replacedBlocksInfo=replacementTable;
            end
        end
    else

        nonAuto=0;
        for i=1:length(replacementInfo)
            if~replacementInfo(i).RepRuleInfo.IsAuto
                nonAuto=nonAuto+1;
            end
        end

        if nonAuto==0
            replacedBlocksInfo={};
        else
            blockColumn=cell(1,nonAuto+1);
            ruleColumn=cell(1,nonAuto+1);
            blockTypeColumn=cell(1,nonAuto+1);
            descriptionColumn=cell(1,nonAuto+1);
            blockSid=cell(1,nonAuto+1);

            blockColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:ReplacedBlockColname'));
            ruleColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:ReplacementRuleMATLABFileColName'));
            blockTypeColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:BlockTypesColName'));
            descriptionColumn{1}=getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RuleDescriptionsColName'));

            nameparts=regexp(replacementInfo(1).ReplacementFullPath,...
            '/','split');
            replacementModelName=nameparts{1};

            counter=2;
            for idx=1:length(replacementInfo)
                currRep=replacementInfo(idx);
                if~currRep.RepRuleInfo.IsAuto
                    path=strrep(currRep.ReplacementFullPath,replacementModelName,'.');
                    blockColumn{counter}=cr_to_space(path);
                    ruleColumn{counter}=currRep.RepRuleInfo.RuleName;
                    blockTypeColumn{counter}=currRep.RepRuleInfo.BlockType;
                    descriptionColumn{counter}=cr_to_space(currRep.RepRuleInfo.Description);
                    blockSid{counter}=currRep.sid;
                    counter=counter+1;
                end
            end

            replacementTable.blocks=blockColumn;
            replacementTable.rules=ruleColumn;
            replacementTable.blockTypes=blockTypeColumn;
            replacementTable.descriptions=descriptionColumn;
            replacementTable.sids=blockSid;
            replacedBlocksInfo=replacementTable;
        end
    end
end

function out=cr_to_space(in)
    out=in;
    if~isempty(in)
        out(in==10)=char(32);
    end
end

