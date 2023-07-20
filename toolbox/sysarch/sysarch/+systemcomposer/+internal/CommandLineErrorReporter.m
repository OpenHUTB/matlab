classdef CommandLineErrorReporter<systemcomposer.internal.BaseErrorReporter




    methods
        function reportAsError(~,diagnostic)
            throw(diagnostic);
        end

        function canContinue=reportAsWarning(~,diagnostic)
            warning(diagnostic);
            canContinue=true;
        end

        function canContinue=reportMultipleWarnings(~,headerDiagnostic,causeDiagnostics)
            mainDiag=MSLDiagnostic(headerDiagnostic);
            for i=1:numel(causeDiagnostics)
                mainDiag=addCause(mainDiag,MSLDiagnostic(causeDiagnostics(i)));
            end

            mainDiag.reportAsWarning();
            canContinue=true;
        end
    end
end
