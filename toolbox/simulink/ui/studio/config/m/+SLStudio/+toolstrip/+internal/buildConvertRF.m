



function buildConvertRF(userdata,cbinfo,action)
    action.enabled=false;

    if isempty(cbinfo.model),return;end
    if isempty(userdata),return;end
    if strcmp(userdata,''),return;end

    config=dig.Configuration.get();
    contextManager=cbinfo.studio.App.getAppContextManager;
    customContext=contextManager.getCustomContext(userdata);
    systemSelectorAction='';
    text='';
    description='';

    if~isempty(customContext)&&ismethod(customContext,'getSystemSelectorConvertButtonProperties')
        [actionName,text,description]=customContext.getSystemSelectorConvertButtonProperties();

        if~isempty(actionName)
            systemSelectorAction=config.getAction(actionName);
        end
    end

    if isempty(systemSelectorAction)
        systemSelectorAction=config.getAction(userdata);
    end

    if isempty(systemSelectorAction)
        return;
    end

    systemSelectorStateFN=systemSelectorAction.refresher.userdata;

    [obj,name,path,selected,state,message]=SLStudio.toolstrip.internal.getSystemSelectorInfo(systemSelectorStateFN,cbinfo,systemSelectorAction);

    action.enabled=true;


    switch state
    case 'convertible'
        action.setCallbackFromArray({'SLStudio.toolstrip.internal.buildConvertCB',obj,systemSelectorAction.name},dig.model.FunctionType.Action);
        action.icon='convertSubsystemToAtomicSubsystem';
        action.text='simulink_ui:studio:resources:buildConvertText';
        action.description='simulink_ui:studio:resources:buildConvertDescription';

        if~isempty(text)
            action.text=text;
        end

        if~isempty(description)
            action.description=description;
        end
    case 'nonsupported'
        action.enabled=false;
    end
end


