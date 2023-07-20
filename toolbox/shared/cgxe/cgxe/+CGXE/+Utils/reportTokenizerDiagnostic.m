function reportTokenizerDiagnostic(tokenizerDiags,topErrorID)






    tokenizeErrors=tokenizerDiags(cellfun(@(s)s.TreatDiagAsError,tokenizerDiags));
    tokenizeWarnings=tokenizerDiags(cellfun(@(s)~s.TreatDiagAsError,tokenizerDiags));


    if(nargin<2)
        topException=MException(message('Simulink:CustomCode:TokenizeError'));
    else
        topException=MException(message(topErrorID));
    end

    if~isempty(tokenizeErrors)
        for i=1:numel(tokenizeErrors)
            topException=topException.addCause(MException(['Simulink:CustomCode:TokenizeError',num2str(i)],strrep(tokenizeErrors{i}.Msg,'\','\\')));
        end
        throw(topException);
    end

    if~isempty(tokenizeWarnings)
        for i=1:numel(tokenizeWarnings)
            topException=topException.addCause(MException(['Simulink:CustomCode:TokenizeError',num2str(i)],strrep(tokenizeWarnings{i}.Msg,'\','\\')));
        end
        MSLDiagnostic(topException).reportAsWarning;
    end
end