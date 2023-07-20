function val=runClockRatePipelining(this,checkSolver)
    val=true;

    if this.getParameter('clockinputs')~=1
        val=false;
    end

    if this.hasDspba
        val=false;
    end

    if~val
        return;
    end

    gp=pir;
    if checkSolver&&gp.crpSuccess
        checks=doSolverChecksForOverclocking(this,[],'Warning');
        if~isempty(checks)
            for i=1:length(checks)
                this.addCheckCurrentDriver('Warning',message(checks(i).MessageID));
            end
            gp.setSolverAllowsOverclocking(true);
        end
    end
end