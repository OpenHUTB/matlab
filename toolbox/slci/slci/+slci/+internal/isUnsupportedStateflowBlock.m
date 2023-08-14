


function unsupported=isUnsupportedStateflowBlock(blkH)

    unsupported=false;

    if slci.internal.isStateflowBasedBlock(blkH)
        if sfprivate('is_eml_chart_block',blkH)
            unsupported=true;
        elseif sfprivate('is_truth_table_chart_block',blkH)
            unsupported=true;
        elseif Stateflow.STT.StateEventTableMan.isStateTransitionTable(...
            sfprivate('block2chart',blkH))

            unsupported=true;
        elseif strcmp('Requirements Table',get_param(blkH,'SFBlockType'))

            unsupported=true;
        else

        end
    end
end
