function gw=generateSaveRefModelsPopupList(cbinfo)




    gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
    header=gw.Widget.addChild('PopupListHeader','manageAllChangedRefFilesHeader');
    header.Label='simulink_ui:studio:resources:manageAllChangedRefFilesHeader';

    item=gw.Widget.addChild('ListItem','showReferencedFilesListItem');
    item.ActionId='showReferencedFilesAction';
    item.TextOverride='simulink_ui:studio:resources:manageAllChangedRefFilesLabel';
    item.DescriptionOverride='simulink_ui:studio:resources:manageAllChangedRefFilesDescription';

    header=gw.Widget.addChild('PopupListHeader','saveSpecificRefFileHeader');
    header.Label='simulink_ui:studio:resources:saveSpecificRefFileHeader';

    dirtyRefs=SLStudio.toolstrip.internal.getDirtyRefModels(cbinfo);
    if~isempty(dirtyRefs)
        dirtyRefs=sort(dirtyRefs);
        for index=1:length(dirtyRefs)
            modelName=dirtyRefs{index};
            handle=get_param(modelName,'handle');

            if handle==cbinfo.editorModel.handle

                actionId='saveCurrentRefModelAction';
                config=dig.Configuration.get();
                action=config.getAction(actionId);

            else
                actionName=['saveRefModelAction_',num2str(index)];
                actionId=[gw.Namespace,':',actionName];
                action=gw.createAction(actionName);
                action.setCallbackFromArray(@(m)SLM3I.saveBlockDiagramAndDirtyRefModels(handle),dig.model.FunctionType.Action);
            end
            action.text=modelName;






            action.enabled=true;
            action.icon='saveReferencedModel';

            itemName=['saveRefModelItem_',num2str(index)];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=actionId;
            item.IconSize=16;
        end
    end

    dirtySSRefs=SLStudio.toolstrip.internal.getDirtySubsystemBDs(cbinfo);
    if~isempty(dirtySSRefs)
        if~isempty(dirtyRefs)
            gw.Widget.addChild('Separator','');
        end
        for index=1:length(dirtySSRefs)
            handle=dirtySSRefs(index);
            modelName=get_param(handle,'Name');

            if handle==cbinfo.editorModel.handle
                actionName='saveCurrentRefSubsystemAction';
            else
                actionName=['saveRefSubsystemAction_',num2str(index)];
            end
            action=gw.createAction(actionName);
            action.text=modelName;
            action.enabled=true;
            action.icon='saveReferencedSubsystem';
            action.setCallbackFromArray(@(m)SLM3I.saveBlockDiagramAndDirtyRefModels(handle),dig.model.FunctionType.Action);

            itemName=['saveRefSubsystemItem_',num2str(index)];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
            item.IconSize=16;
        end
    end
end
