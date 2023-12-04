function setDeploymentType(dpType,cbinfo)

    if~cbinfo.EventData
        return;
    end

    studio=cbinfo.studio;
    refresher=coder.internal.toolstrip.util.Refresher(studio);%#ok<NASGU>
    mdl=cbinfo.editorModel.Handle;

    switch dpType
    case{'Component','SubAssembly'}
        if strcmp(dpType,'SubAssembly')
            dpType='Subcomponent';
        end
        coder.mapping.utils.create(mdl);
        mapping=Simulink.CodeMapping.getCurrentMapping(mdl);
        mapping.DeploymentType=dpType;
        set_param(mdl,'CodeGenBehavior','Default');
    case 'Auto'
        mapping=Simulink.CodeMapping.getCurrentMapping(mdl);
        if~isempty(mapping)
            mapping.DeploymentType='Unset';
        end
        set_param(mdl,'CodeGenBehavior','Default');
    case 'None'
        set_param(mdl,'CodeGenBehavior','None');
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        cv=cp.getTask('CodeReport');
        if~isempty(cv)
            cv.turnOff(studio);
        end
    end
