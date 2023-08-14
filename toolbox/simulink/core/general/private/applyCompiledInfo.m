function applyCompiledInfo()

    isSolverAuto=false;
    compSolver=get_param(bdroot,'CompiledSolverName');
    if(or(strcmp(get_param(bdroot,'Solver'),'VariableStepAuto'),...
        strcmp(get_param(bdroot,'Solver'),'FixedStepAuto')))
        isSolverAuto=true;
    end

    solverFlags=get_param(bdroot,'SolverStatusFlags');







    SL_CS_STATUS_SLVR_FINALIZED=64;
    isSolverFinalized=bitand(solverFlags,SL_CS_STATUS_SLVR_FINALIZED);

    compStepSize=get_param(bdroot,'CompiledStepSize');
    isFixedStep=false;
    isStepAuto=false;
    if(strcmp(get_param(bdroot,'SolverType'),'Fixed-step'))
        isFixedStep=true;
        if(strcmpi(get_param(bdroot,'FixedStep'),'auto'))
            isStepAuto=true;
        end
    else
        if(strcmpi(get_param(bdroot,'MaxStep'),'auto'))
            isStepAuto=true;
        end
    end

    cs=getActiveConfigSet(bdroot);
    isCSref=strcmp(cs.class,'Simulink.ConfigSetRef');

    if(isCSref)
        if(and(isSolverAuto,isSolverFinalized))
            SLStudio.Utils.setConfigSetParam(bdroot,'Solver',compSolver);
        end
        if(and(isFixedStep,isStepAuto))
            SLStudio.Utils.setConfigSetParam(bdroot,'FixedStep',compStepSize);
        end
        if(and(~isFixedStep,isStepAuto))
            SLStudio.Utils.setConfigSetParam(bdroot,'MaxStep',compStepSize);
        end
    else
        if(and(isSolverAuto,isSolverFinalized))
            set_param(cs,'Solver',compSolver);
        end
        if(and(isFixedStep,isStepAuto))
            set_param(cs,'FixedStep',compStepSize);
        end
        if(and(~isFixedStep,isStepAuto))
            set_param(cs,'MaxStep',compStepSize);
        end
    end

end
