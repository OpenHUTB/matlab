function updateModelState(slObj,simPhase)





    model=bdroot(slObj);
    if strcmpi(simPhase,'start')
        originalCS=getActiveConfigSet(model);
        if isempty(originalCS.getComponent('Simscape'))
            error(message(...
            'physmod:common:state2op:core:state2op:InitialStateNotAvailable',...
            model));
        end
        simscape.internal.sim0(model);
    else
        set_param(model,'SimulationCommand','Update');
    end

end

