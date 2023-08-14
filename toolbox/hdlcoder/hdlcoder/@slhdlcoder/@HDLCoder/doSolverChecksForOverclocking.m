function checks=doSolverChecksForOverclocking(this,checks,level)

    mdlName=this.ModelName;

    solver=get_param(mdlName,'Solver');
    solverType=get_param(mdlName,'SolverType');
    multitaskingMode=get_param(mdlName,'EnableMultiTasking');
    solverStep=get_param(mdlName,'FixedStep');

    singleTaskRateTransition=this.CachedSingleTaskRateTransMsg;
    multiTaskRateTransition=get_param(mdlName,'MultiTaskRateTransMsg');

    if~(strcmpi(solver,'FixedStepDiscrete')&&strcmpi(solverType,'Fixed-step')&&strcmpi(multitaskingMode,'off')&&strcmpi(solverStep,'auto'))
        msg=message('hdlcoder:engine:MultirateSolver');
        checks=logMessage(checks,mdlName,level,'model',msg);
    end

    if~(strcmpi(singleTaskRateTransition,'error')&&strcmpi(multiTaskRateTransition,'error'))
        msg=message('hdlcoder:engine:MultirateMultiTasking');
        checks=logMessage(checks,mdlName,level,'model',msg);
    end

end


function checks=logMessage(checks,mdlName,level,type,msg)
    checks(end+1).level=level;
    checks(end).path=mdlName;
    checks(end).type=type;
    checks(end).message=msg.getString;
    checks(end).MessageID=msg.Identifier;
end
