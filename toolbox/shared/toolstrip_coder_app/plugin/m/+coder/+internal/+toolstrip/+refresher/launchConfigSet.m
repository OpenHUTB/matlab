function launchConfigSet(~,~,action)





    if~coder.internal.toolstrip.license.isSimulinkCoder

        action.text='simulink_ui:studio:resources:OpenModelConfigParamActionText';
    else
        action.text='ToolstripCoderApp:toolstrip:CoderModelConfigActionDescription';
    end
