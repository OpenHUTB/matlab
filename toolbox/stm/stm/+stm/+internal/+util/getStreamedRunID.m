

function streamedRunID=getStreamedRunID(model)
    if strcmpi(get_param(model,'SimulationMode'),'rapid-accelerator')

        r=Simulink.sdi.getCurrentSimulationRun(model,'',false);
        if isempty(r)
            streamedRunID=0;
        else
            streamedRunID=r.id;
        end
    else
        streamedRunID=stm.internal.getCurrentStreamingRunID(model);
    end
end