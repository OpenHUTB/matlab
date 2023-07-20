function className=isSupportedSFunction(block)




    className='';
    if strcmp(get_param(block,'BlockType'),'S-Function')&&...
        strcmp(get_param(block,'MaskType'),'Bitwise Operator')&&...
        strcmp(get_param(block,'FunctionName'),'sfix_bitop')
        className='Bitwise_Operator';
    end

    if strcmp(get_param(block,'BlockType'),'S-Function')...
        &&(strcmp(get_param(block,'FunctionName'),'fcgen')...
        ||strcmp(get_param(block,'FunctionName'),'fcncallgen'))
        className='FcnCallGen';
    end



    if strcmp(get_param(block,'BlockType'),'S-Function')&&...
        strcmp(get_param(block,'MaskType'),'Data Type Propagation')&&...
        strcmp(get_param(block,'FunctionName'),'sfix_dtprop')
        className='DataTypePropagation';
    end


    if slci.internal.isStateflowBasedBlock(block)
        if sfprivate('is_eml_chart_block',block)
            className='MatlabFunction';
        elseif~sfprivate('is_truth_table_chart_block',block)&&...
            ~Stateflow.STT.StateEventTableMan.isStateTransitionTable(...
            sfprivate('block2chart',block))&&...
            ~strcmp('Requirements Table',get_param(block,'SFBlockType'))
            className='Stateflow';
        end
    end
end
