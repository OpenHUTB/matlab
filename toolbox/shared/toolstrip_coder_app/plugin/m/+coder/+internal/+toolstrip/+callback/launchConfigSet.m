function launchConfigSet(fcname,cbinfo)




    editor=cbinfo.studio.App.getActiveEditor;
    mdl=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    cs=getActiveConfigSet(mdl);

    if isempty(fcname)||...
        (Simulink.CodeMapping.isAutosarCompliant(mdl)&&...
        ~coder.internal.toolstrip.license.isEmbeddedCoder)


        cs.view;
    else
        if strcmp(fcname,'Report')
            if~coder.internal.toolstrip.util.checkUseSlcoderOrEcoderFeaturesBasedOnTarget(mdl)
                return;
            end
        end

        configset.showParameterGroup(cs,{fcname});
    end
