function flag=checkBlockSupport(this)







    blocks_in_DUT=setdiff(find_system(this.m_DUT,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices),this.m_DUT);


    supported_blocks=this.getSupportedBlocks();


    unsupported_blocks=detectUnsupportedBlocks(this,blocks_in_DUT,supported_blocks,1);

    flag=isempty(unsupported_blocks);
end

function unsupported_blocks=detectUnsupportedBlocks(this,blocks,supported_blocks,level)





    block_types=cellfun(@(x)strrep(hdlgetblocklibpath(x),newline,' '),...
    blocks,'UniformOutput',false);

    unsupported_blocks={};
    for block_num=1:length(blocks)
        blkType=get_param(blocks{block_num},'BlockType');

        if~any(strcmpi(supported_blocks,block_types{block_num}))

            if strcmpi(blkType,'SubSystem')


                allSubBlocks=find_system(blocks{block_num},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on');
                subBlocks=setdiff(allSubBlocks,blocks{block_num});


                unsupported_subblocks=detectUnsupportedBlocks(this,subBlocks,supported_blocks,level+1);

                if~isempty(unsupported_subblocks)
                    unsupported_blocks{end+1}=blocks{block_num};%#ok<AGROW>




                    if(level==1)
                        this.addCheck('warning',message('HDLShared:hdlmodelchecker:unsupportedBlocks').getString,unsupported_blocks{end},0);
                    end
                end
            else
                unsupported_blocks{end+1}=blocks{block_num};%#ok<AGROW>
                if(level==1)
                    this.addCheck('warning',message('HDLShared:hdlmodelchecker:unsupportedBlocks').getString,unsupported_blocks{end},0);
                end
            end
        else
            if strcmpi(blkType,'TriggerPort')
                TriggerKind=get_param(blocks{block_num},'TriggerType');
                if strcmpi(TriggerKind,'function-call')||strcmpi(TriggerKind,'message')
                    unsupported_blocks{end+1}=blocks{block_num};%#ok<AGROW>
                    if(level==1)
                        this.addCheck('warning',message('HDLShared:hdlmodelchecker:unsupportedBlocks').getString,unsupported_blocks{end},0);
                    end
                end
            end
        end
    end
end
