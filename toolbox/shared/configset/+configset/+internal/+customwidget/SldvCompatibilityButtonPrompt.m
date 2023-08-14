function prompt=SldvCompatibilityButtonPrompt(cs,~)




    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Design Verifier');
    else
        hObj=cs;
    end

    if isempty(hObj.SubsystemToAnalyze)
        prompt=DAStudio.message('Sldv:dialog:sldvDVOptionChkComp');
    else
        if Sldv.ui.toolstrip.internal.sldvanalyzable.isModelReference(hObj.SubsystemToAnalyze)

            prompt=DAStudio.message('Sldv:dialog:sldvDVOptionChkCompatModelRef');
        else

            prompt=DAStudio.message('Sldv:dialog:sldvDVOptionChkCompatSubs');
        end
    end
