function updateModelForAnalysis(model,isSim)





    if slfeature('SLMulticore')>0||slde.isDesModel(model)
        set_param(model,'SimulationCommand','update');
    elseif isSim
        simMode=get_param(model,'SimulationMode');
        if~strcmpi(simMode,'rapid-accelerator')
            set_param(model,'SimulationCommand','update');
        else
            Simulink.BlockDiagram.buildRapidAcceleratorTarget(model);
        end
    else
        try
            evalc('feval(model,''initForChecksumsOnly'',''rtwgen'')');
            feval(model,[],[],[],'term');
        catch ME
            rethrow(ME);
        end
    end
