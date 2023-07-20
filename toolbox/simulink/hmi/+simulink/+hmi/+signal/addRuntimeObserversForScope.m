function addRuntimeObserversForScope(observer,mdl,bindings)
    if~isempty(bindings)
        if bdIsLoaded(mdl)&&~strcmpi(get_param(mdl,'SimulationStatus'),'stopped')
            for idx=1:length(bindings)
                simulink.hmi.signal.addRuntimeObserver(bindings{idx}.BlockPath,...
                bindings{idx}.OutputPortIndex,observer,true);
            end
        end
    end
end

