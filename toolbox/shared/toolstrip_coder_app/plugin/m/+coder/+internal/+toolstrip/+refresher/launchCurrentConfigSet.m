function launchCurrentConfigSet(name,cbinfo,action)





    if strcmp(name,'CodeGeneration')
        if~coder.internal.toolstrip.license.isSimulinkCoder

            action.text='simulink_ui:studio:resources:OpenModelConfigParamActionText';
        else
            action.text='ToolstripCoderApp:toolstrip:CoderModelConfigActionDescription';
        end
    end


    editor=cbinfo.studio.App.getActiveEditor;
    cgr=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    current=editor.blockDiagramHandle;
    if cgr==current
        action.enabled=false;
    end