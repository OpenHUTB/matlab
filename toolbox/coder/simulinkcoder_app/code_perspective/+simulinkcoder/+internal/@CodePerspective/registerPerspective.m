function registerPerspective(obj)




    GLUE2.addDomainTransformativeGroupCreatorCallback('Simulink','Code',...
    @(callbackInfo)loc_createPerspectiveGroupCallback(obj,callbackInfo));
    GLUE2.addDomainTransformativeGroupCreatorCallback('Stateflow','Code',...
    @(callbackInfo)loc_createPerspectiveGroupCallback(obj,callbackInfo));
    location=GLUE2.getPerspectivesGroupLocation('Coder');
    otherGroupLockedOutTooltip=message('glue2:studio:PerspectiveDisabledAsCoderActive').getString;
    coderGroupLockedOutTooltip=message('glue2:studio:CoderPerspectiveDisabledAsOtherActive').getString;
    GLUE2.setAllPerspectivesGroupsInterlock('Coder',otherGroupLockedOutTooltip,coderGroupLockedOutTooltip);


    function loc_createPerspectiveGroupCallback(obj,callbackInfo)

        info=callbackInfo.EventData;
        if info.getBlockHandle()==0
            client=info.getPerspectivesClient;
            loc_displayControls(obj,client);
        end

        function loc_displayControls(obj,client)

            editor=client.getEditor;
            src=simulinkcoder.internal.util.getSource(editor);

            if~obj.isAvailable(src.modelName)
                return;
            end

            if obj.getStatus(editor)
                location=GLUE2.getPerspectivesSystemGroupLocation();
                name=message('SimulinkCoderApp:codeperspective:SystemIconName').getString;
                myPath=obj.iconPathOff;
                title=message('SimulinkCoderApp:codeperspective:CodePerspectiveIconExitTitle').getString;
                tooltip=message('SimulinkCoderApp:codeperspective:CodePerspectiveIconExitTooltip').getString;
            else
                location=GLUE2.getPerspectivesGroupLocation('Coder');
                name=message('SimulinkCoderApp:codeperspective:CodePerspectiveIconName').getString;
                myPath=obj.iconPathOn;
                title=message('SimulinkCoderApp:codeperspective:CodePerspectiveIconEnterTitle').getString;
                tooltip=message('SimulinkCoderApp:codeperspective:CodePerspectiveIconEnterTooltip').getString;
            end

            group=client.newTransformativeGroup(name,location,false);
            option=group.newOption('codeoption',myPath,title,tooltip);
            option.setSelectionCallback(@obj.onClickHandler);

