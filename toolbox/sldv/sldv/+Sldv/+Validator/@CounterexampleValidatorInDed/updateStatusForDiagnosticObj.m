



function validatedGoalStatus=updateStatusForDiagnosticObj(obj,objectiveWithStatus,currentGoalStatus)




    validatedGoalStatus=currentGoalStatus;

    switch objectiveWithStatus.status
    case{Sldv.Validator.ValidationStatus.Success,...
        Sldv.Validator.ValidationStatus.Ignored}
        validatedGoalStatus='GOAL_FALSIFIABLE';
        obj.sldvData.Objectives(objectiveWithStatus.objective).status=getFalsifiablePrefix(obj);
    end
end

function satisfiablePrefix=getFalsifiablePrefix(aObj)


    opts=aObj.sldvData.AnalysisInformation.Options;

    if slavteng('feature','DedValidation')&&...
        strcmp(opts.Mode,'DesignErrorDetection')
        satisfiablePrefix='Falsified';
    end
end
