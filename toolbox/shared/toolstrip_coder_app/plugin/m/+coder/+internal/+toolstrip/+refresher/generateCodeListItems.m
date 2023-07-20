function generateCodeListItems(cbinfo,action)










    if slfeature('SDPToolStrip')
        editor=cbinfo.studio.App.getActiveEditor;
        mdl=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    else
        mdl=cbinfo.model.Handle;
    end


    cs=getActiveConfigSet(mdl);
    if isa(cs,'Simulink.ConfigSetRef')
        if get_param(cs,'GenCodeOnly')=="on"
            if strcmp('coderGenerateCodeAndBuildAction',action.name)
                action.enabled=false;
            end
        else
            if strcmp('coderGenerateCodeOnlyAction',action.name)
                action.enabled=false;
            end
        end
    end



    if strcmp(get_param(cs,'AutosarCompliant'),'on')

        if strcmp('coderGenerateCodeAndBuildAction',action.name)
            action.enabled=false;
            action.description='autosarstandard:toolstrip:BuildNotSupportedAutosar';
        else

            selectedSystem=coder.internal.toolstrip.util.getSelectedSystem(cbinfo);
            if isSelectedSystemValid(selectedSystem)
                modelHandle=bdroot(selectedSystem.Handle);
                if strcmp('coderGenerateCodeOnlyAction',action.name)&&...
                    Simulink.CodeMapping.isMappedToAutosarSubComponent(modelHandle)
                    action.enabled=false;
                    action.description='autosarstandard:toolstrip:CodeGenNotSupportedSubComponent';
                end
            end
        end
    end
end

function out=isSelectedSystemValid(selectedSystem)
    out=isa(selectedSystem,'Simulink.BlockDiagram')||...
    isa(selectedSystem,'Simulink.SubSystem')||...
    isa(selectedSystem,'Simulink.ModelReference');
end


