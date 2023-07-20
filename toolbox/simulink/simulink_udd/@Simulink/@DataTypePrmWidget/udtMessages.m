function xlatedMessage=udtMessages(message)























    if isempty(message)
        xlatedMessage=message;
        return;
    end

    if ischar(message)
        messages={message};
    elseif iscell(message)
        messages=message;
    else
        assert(true,'Messages has to be a string or a cell array of strings.');
    end
    xlatedMessage=messages;

    for i=1:length(messages)
        assert(ischar(messages{i}),'Message has to be a string or a cell array of strings.');
        switch messages{i}
        case 'Inherit: auto'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTAutoRule');
        case 'Inherit: Same as input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsInputRule');
        case 'Inherit: Same as first input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsFirstInputRule');
        case 'Inherit: Same as second input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsSecondInputRule');
        case 'Inherit: Same as corresponding input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsCorrespondingInputRule');
        case 'Inherit: Same as first data input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsFirstDataInputRule');
        case 'Inherit: Inherit via internal rule'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTInternalRule');
        case 'Inherit: Keep MSB'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTKeepMSBRule');
        case 'Inherit: Keep LSB'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTKeepLSBRule');
        case 'Inherit: Match scaling'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTMatchScalingRule');
        case 'Inherit: Inherit via back propagation'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTBackpropagationRule');
        case 'Inherit: Same as Simulink'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsSimulinkRule');
        case 'Inherit: Inherit from table data'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTFromTableDataRule');
        case 'Inherit: Logical (see Configuration Parameters: Optimization)'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTLogicalRule');
        case 'Inherit: All ports same datatype'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTAllPortsSameDataRule');
        case 'Inherit: Inherit from ''Constant value'''
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsConstantRule');
        case 'Inherit: Same as accumulator'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsAccumulatorRule');
        case 'Inherit: Same as product output'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsProductRule');
        case 'Inherit: Same word length as input'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsInputWordLengthRule');
        case 'Inherit: Inherit from ''Breakpoint data'''
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsBreakpointDataRule');
        case 'Inherit: Inherit from ''Table data'''
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTFromTableDataParamRule');
        case 'Inherit: Same as output'
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTSameAsOutputRule');
        case 'Inherit: Inherit from ''Gain'''
            xlatedMessage{i}=DAStudio.message('Simulink:dialog:UDTInheritFromGain');
        otherwise

        end
    end
    if~iscell(message)
        xlatedMessage=xlatedMessage{1};
    end





