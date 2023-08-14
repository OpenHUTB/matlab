classdef(Abstract)BaseErrorReporter




    methods(Abstract)

        reportAsError(diagnostic);



        canContinue=reportAsWarning(diagnostic);



        canContinue=reportMultipleWarnings(headerDiagnostic,causeDiagnostics);
    end
end
