





function out=runSingleSim(fh,simInp)
    validateattributes(fh,{'function_handle'},{'scalar'});
    validateattributes(simInp,{'Simulink.SimulationInput'},{'scalar'});






    try
        simulink.multisim.internal.debuglog("Running simulation with runId "+simInp.RunId);
        out=feval(fh,simInp);
        if~isa(out,'Simulink.SimulationOutput')
            error(message('Simulink:Commands:MultiSimExecute',...
            func2str(fh),class(out)));
        end
    catch ME


        if strcmp(ME.identifier,'Simulink:Commands:MultiSimExecute')
            err=MException(message('Simulink:Commands:MultiSimExecute',...
            func2str(fh),class(out)));
            reportAsWarning(err,simInp.ModelName);
        else
            err=MException(message('Simulink:Commands:MultiSimExecuteError',func2str(fh)));
            err=err.addCause(ME);
            reportAsWarning(err,simInp.ModelName);
        end


        out=MultiSim.internal.createSimulationOutput(ME,simInp.ModelName);




        out=out.setUserString(simInp.UserString);
    end
end

function reportAsWarning(ME,modelName)

    warnState=warning('query','backtrace');
    oc=onCleanup(@()warning(warnState));
    warning off backtrace;
    msld=MSLDiagnostic(ME);
    msld.reportAsWarning(modelName,false);
end