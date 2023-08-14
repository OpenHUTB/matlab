function FixOutportIC(block,h)





    parentBlock=get_param(get_param(block,'Parent'),'Handle');



    if strcmp(get_param(parentBlock,'Type'),'block')



        if slprivate('is_stateflow_based_block',parentBlock)
            return;
        end




        portBlocks=find_system(parentBlock,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'RegExp','on',...
        'FirstResultOnly','on',...
        'SearchDepth',1,...
        'BlockType','TriggerPort|EnablePort|ActionPort|WhileIterator|ForIterator');

        if~isempty(portBlocks)
            return;
        end
    else
        return;
    end

    strVal=get_param(block,'InitialOutput');

    try
        val=eval(strVal);
        if isequal(val,0.0)


            if askToReplace(h,block)
                reason=DAStudio.message('SimulinkBlocks:upgrade:setOutportIcEmpty');
                funcSet=uSafeSetParam(h,block,'InitialOutput','[]');
                appendTransaction(h,block,reason,{funcSet});
            end
        end
    catch %#ok<CTCH>
    end

end
