



function[state,message]=systemSelectorRF_testFN(obj,~)
    message='';

    switch obj.name
    case 'SSA'
        state='supported';
    case 'SSA_1'
        state='nonsupported';
        message=['Selection is not supported.'];
    case 'SSA_2'
        state='nonsupported';
        message=['Selection is not supported.'];
    case 'SSB'
        if strcmpi(get_param(obj.handle,'TreatAsAtomicUnit'),'on')
            state='supported';
        else
            message=['Selection must be converted first.'];
            state='convertible';
        end
    case 'SSB_1'
        state='supported';
    case 'SSB_2'
        state='supported';
    case 'SSC'
        state='nonsupported';
        message=['Selection is not supported.'];
    case 'SSC_1'
        state='supported';
    case 'SSC_2'
        state='supported';
    case 'CA'
        if isa(obj,'Simulink.SubSystem')
            state='supported';
        else
            state='nonsupported';
            message=['Selection is not supported.'];
        end
    case 'CA_1'
        state='supported';
    case 'CA_2'
        if isa(obj,'Stateflow.AtomicSubchart')
            state='supported';
        else
            state='convertible';
            message=['Selection must be converted first.'];
        end
    otherwise
        state='nonsupported';
        message=['Selection is not supported.'];
    end
end