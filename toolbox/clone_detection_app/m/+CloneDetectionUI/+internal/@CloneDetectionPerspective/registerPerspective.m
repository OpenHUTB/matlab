function registerPerspective(obj)



    GLUE2.addDomainTransformativeGroupCreatorCallback('Simulink','CloneDetection',...
    @(callbackInfo)loc_createPerspectiveGroupCallback(obj,callbackInfo));
    GLUE2.addDomainTransformativeGroupCreatorCallback('Stateflow','CloneDetection',...
    @(callbackInfo)loc_createPerspectiveGroupCallback(obj,callbackInfo));



    GLUE2.addDomainPerspectivesGroupActiveCallback('Simulink','CloneDetection',@getPerspectiveStatus);
    GLUE2.addDomainPerspectivesGroupActiveCallback('Stateflow','CloneDetection',@getPerspectiveStatus);

    otherGroupLockedOutTooltip=message('clone_detection_app:resources:PerspectiveDisabledAsCloneDetectionActive').getString;
    clonedetectionGroupLockedOutTooltip=message('clone_detection_app:resources:CloneDetectionPerspectiveDisabledAsOtherActive').getString;
    GLUE2.setAllPerspectivesGroupsInterlock('CloneDetection',otherGroupLockedOutTooltip,clonedetectionGroupLockedOutTooltip);



    function bool=getPerspectiveStatus(~,~,~)




        src=simulinkcoder.internal.util.getSource();
        uiobj=get_param(src.modelH,'CloneDetectionUIObj');
        if isempty(uiobj)||(~isa(uiobj,'CloneDetectionUI.CloneDetectionUI'))
            bool=false;
        else
            bool=true;
        end

        function loc_createPerspectiveGroupCallback(obj,callbackInfo)

            info=callbackInfo.EventData;
            if info.getBlockHandle()==0
                client=info.getPerspectivesClient;
                loc_displayControls(obj,client);
            end

            function loc_displayControls(obj,client)

                editor=client.getEditor;

                if~CloneDetectionUI.internal.CloneDetectionPerspective.isAvailable()
                    return;
                end

                if obj.getStatus(editor)
                    location=GLUE2.getPerspectivesGroupLocation('CloneDetection');
                    name=message('clone_detection_app:resources:CloneDetectionPerspectiveIconName').getString;
                    myPath=obj.iconPathOn;
                    title=message('clone_detection_app:resources:CloneDetectionPerspectiveIconEnterTitle').getString;
                    tooltip=message('clone_detection_app:resources:CloneDetectionPerspectiveIconEnterTooltip').getString;
                else
                    location=GLUE2.getPerspectivesSystemGroupLocation();
                    name=message('clone_detection_app:resources:CloneDetectionPerspectiveIconName').getString;
                    myPath=obj.iconPathOff;
                    title=message('clone_detection_app:resources:CloneDetectionPerspectiveIconExitTitle').getString;
                    tooltip=message('clone_detection_app:resources:CloneDetectionPerspectiveIconExitTooltip').getString;
                end

                group=client.newTransformativeGroup(name,location,false);
                option=group.newOption('CloneDetectionOption',myPath,title,tooltip);
                option.setSelectionCallback(@obj.onClickHandler);

