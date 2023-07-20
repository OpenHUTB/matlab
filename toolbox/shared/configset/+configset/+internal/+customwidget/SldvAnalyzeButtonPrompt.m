function prompt=SldvAnalyzeButtonPrompt(cs,~)




    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Design Verifier');
    else
        hObj=cs;
    end

    valMode=get(hObj,'DVMode');

    if isempty(hObj.SubsystemToAnalyze)
        prompt=promptForTopModel(valMode);
    else
        if Sldv.ui.toolstrip.internal.sldvanalyzable.isModelReference(hObj.SubsystemToAnalyze)

            prompt=promptForModelRef(valMode);
        else

            prompt=promptForSubsys(valMode);
        end
    end
end

function prompt=promptForTopModel(valMode)
    if strcmp(valMode,'TestGeneration')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionGenTests');
    elseif strcmp(valMode,'PropertyProving')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionProveProps');
    else
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrs');
    end
end

function prompt=promptForSubsys(valMode)
    if strcmp(valMode,'TestGeneration')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionGenTestSubsys');
    elseif strcmp(valMode,'PropertyProving')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionProvePropsSubsys');
    else
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrsSubs');
    end
end

function prompt=promptForModelRef(valMode)
    if strcmp(valMode,'TestGeneration')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionGenTestModelRef');
    elseif strcmp(valMode,'PropertyProving')
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionProvePropsModelRef');
    else
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrsModelRef');
    end
end
