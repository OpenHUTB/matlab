function ctx=getCodeForContext(studio)



    ctx='';
    editor=studio.App.getActiveEditor;
    cgr=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    if isempty(cgr)
        return;
    end

    mapping=Simulink.CodeMapping.getCurrentMapping(cgr);
    if~isempty(mapping)&&isa(mapping,'Simulink.CoderDictionary.ModelMapping')
        dt=mapping.DeploymentType;
        if strcmp(dt,'Subcomponent')
            ctx='CodeFor_Subcomponent';
        else
            ctx='CodeFor_Component';
        end
    else
        ctx='CodeFor_Component';
    end
