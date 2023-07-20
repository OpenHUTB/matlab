classdef GraphicalErrorReporter<systemcomposer.internal.BaseErrorReporter





    methods
        function reportAsError(~,diagnostic)
            sldiagviewer.reportError(diagnostic);
        end

        function canContinue=reportMultipleWarnings(~,headerDiag,causeDiags)
            diagnosticString=append(headerDiag.string,newline);
            for i=1:numel(causeDiags)
                diagnosticString=append(diagnosticString,newline,...
                sprintf(' - %s',causeDiags(i).string));
            end

            canContinue=showConfirmationDialog(diagnosticString);
        end

        function canContinue=reportAsWarning(~,diagnostic)
            canContinue=showConfirmationDialog(diagnostic.string);
        end
    end
end

function canContinue=showConfirmationDialog(diagnosticString)


    answer=questdlg(...
    diagnosticString,...
    message('SystemArchitecture:SaveAndLink:Warning').string,...
    message('SystemArchitecture:SaveAndLink:OK').string,...
    message('SystemArchitecture:SaveAndLink:Cancel').string,...
    message('SystemArchitecture:SaveAndLink:Cancel').string);


    canContinue=answer==message('SystemArchitecture:SaveAndLink:OK').string;
end
