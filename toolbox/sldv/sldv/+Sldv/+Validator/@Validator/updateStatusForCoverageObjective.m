



function validatedGoalStatus=updateStatusForCoverageObjective(obj,objectiveWithStatus,currentGoalStatus)

    validatedGoalStatus=currentGoalStatus;

    switch objectiveWithStatus.status
    case{Sldv.Validator.ValidationStatus.IgnoredDueToBlockReplacement,...
        Sldv.Validator.ValidationStatus.NoCoverage,...
        Sldv.Validator.ValidationStatus.Unvalidated}


        if strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentGoalStatus)
            validatedGoalStatus='GOAL_UNDECIDED_STUB';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
        end
    case{Sldv.Validator.ValidationStatus.Success,...
        Sldv.Validator.ValidationStatus.Ignored}


        if(Sldv.Validator.ValidationStatus.Ignored==objectiveWithStatus.status)&&...
            SlCov.CovMode.isXIL(obj.simMode)
            validatedGoalStatus='GOAL_SATISFIABLE_NEEDS_SIMULATION';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status=[getSatisfiablePrefix(obj),' - needs simulation'];

        elseif(Sldv.Validator.ValidationStatus.Ignored==objectiveWithStatus.status)&&...
            strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentGoalStatus)
            validatedGoalStatus='GOAL_UNDECIDED_STUB';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
        elseif strcmp('GOAL_SATISFIED_BY_EXISTING_TESTCASE',currentGoalStatus)
            validatedGoalStatus='GOAL_SATISFIED_BY_EXISTING_TESTCASE';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='satisfied by existing testcase';
        else
            validatedGoalStatus='GOAL_SATISFIABLE';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status=getSatisfiablePrefix(obj);
        end
    case Sldv.Validator.ValidationStatus.RuntimeError

        if strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentGoalStatus)
            validatedGoalStatus='GOAL_UNDECIDED_STUB';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
        else
            validatedGoalStatus='GOAL_UNDECIDED_RUNTIME_ERROR';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to runtime error';
        end
    case{Sldv.Validator.ValidationStatus.NotSuccess,...
        Sldv.Validator.ValidationStatus.Inconclusive}
        if strcmp('GOAL_SATISFIABLE_NEEDS_SIMULATION',currentGoalStatus)
            validatedGoalStatus='GOAL_UNDECIDED_WITH_TESTCASE';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided with testcase';

        elseif strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentGoalStatus)
            validatedGoalStatus='GOAL_UNDECIDED_STUB';
            obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
        end
    end
end

function satisfiablePrefix=getSatisfiablePrefix(aObj)
    opts=aObj.sldvData.AnalysisInformation.Options;

    if Sldv.utils.isActiveLogic(opts)
        satisfiablePrefix='Active Logic';
    else
        assert(strcmp(opts.Mode,'TestGeneration'));
        satisfiablePrefix='Satisfied';
    end
end
