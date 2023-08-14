function replace=askToReplace(h,block)









    if getPrompt(h)

        name=h.cleanLocationName(block);
        SL_ReplacementPrompt=DAStudio.message('SimulinkUpgradeEngine:engine:replacementPrompt',name);
        replaceReply=input(SL_ReplacementPrompt,'s');

        if isempty(replaceReply),
            replace=true;
        else
            switch replaceReply(1)
            case 'y'
                replace=true;
            case 'n'
                replace=false;
                dispSkipping(h,block);
            case 'a'
                replace=true;
                h.Prompt=false;

            otherwise
                MSLDiagnostic('SimulinkUpgradeEngine:engine:invalidPromptResponse',replaceReply).reportAsWarning;
                replace=false;
                dispSkipping(h,block);
            end
        end
    else
        replace=true;
    end

end


