function isSF=isStateFlowSignal(signal)



    if~isempty(signal)
        if isfield(signal,'isSF')

            isSF=signal.isSF;
        else
            isValidState=strcmpi(signal.DomainType_,'sf_state');
            isSF=isprop(signal,'DomainType_')&&isValidState||strcmpi(signal.DomainType_,'sf_chart');
        end
    end