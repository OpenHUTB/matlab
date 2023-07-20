





function fixReplacementCustomCodeSettings(originalModelH,replacementModelH)
    try
        rootModelName=get_param(originalModelH,'Name');


        if strcmpi(get_param(originalModelH,'SimulationStatus'),'stopped')
            set_param(originalModelH,'SimulationCommand','update');
        end
        customCodeSettings=sldv.code.slcc.internal.getMergedCustomCodeInfo(rootModelName);

        if~isempty(customCodeSettings)&&customCodeSettings.hasCustomCode()
            customCodeSettings.saveToModel(replacementModelH);

            cs=getActiveConfigSet(replacementModelH);
            if customCodeSettings.parseCC
                set_param(cs,'SimParseCustomCode','on');
            end

            if customCodeSettings.analyzeCC
                set_param(cs,'SimAnalyzeCustomCode','on');
            end
        end
    catch Me
        if startsWith(Me.identifier,'sldv_sfcn:')
            rethrow(Me);
        end
    end
