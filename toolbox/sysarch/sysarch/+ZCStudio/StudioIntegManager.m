classdef StudioIntegManager<handle


    methods(Static=true)

        function openSpotlightInStudio(studioTag,url,spotlightObj)
            activeStudio=DAS.Studio.getStudio(studioTag);
            if(~isempty(activeStudio))

                sourceCompList=spotlightObj.getSelectedComponent();
                sources=arrayfun(@(comp)systemcomposer.utils.getSimulinkPeer(comp),sourceCompList,'UniformOutput',false);
                sources=[sources{:}];

                relatedCompList=spotlightObj.getComponentsInSpotlight();
                relatedElems=arrayfun(@(comp)systemcomposer.utils.getSimulinkPeer(comp),relatedCompList,'UniformOutput',false);

                relatedElems=[relatedElems{:}];

                if(~isempty(sourceCompList))


                    ZCStudio.StudioIntegManager.closeInvalidNotifInStudio(activeStudio);


                    ZCStudio.StudioIntegManager.closeLightViewFinder(studioTag);



                    ZCStudio.StudioIntegManager.resetPropertyInspectorToModel(activeStudio);

                    activeStudio.App.embedSpolightView(connector.getUrl(url),sources,relatedElems);
                end
            else
                url=connector.getUrl(studioTag);
                web(url,'-browser');
            end
        end

        function zoomIn(studioTag)
            activeStudio=DAS.Studio.getStudio(studioTag);
            app=systemcomposer.internal.arch.load(get_param(activeStudio.App.blockDiagramHandle,'Name'));
            if~isempty(app)
                app.spotlightZoomIn(studioTag);
            end
        end

        function fitToView(studioTag)
            activeStudio=DAS.Studio.getStudio(studioTag);
            app=systemcomposer.internal.arch.load(get_param(activeStudio.App.blockDiagramHandle,'Name'));
            if~isempty(app)
                app.spotlightFitToView(studioTag);
            end
        end

        function matchedStudios=getAllStudiosWithRelatedSpotlights(appName)
            matchedStudios=[];
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for i=1:length(studios)
                studio=studios(i);
                editor=studio.App.getActiveEditor();
                name=editor.getName();




                modelName=strtok(name,'/');

                if strcmp(modelName,appName)&&studio.App.hasSpotlightView()
                    matchedStudios=[matchedStudios,studio];
                end

            end

        end

        function studio=getMostRecentlyActiveStudio(appName)
            studio=[];
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(appName)
                for i=1:length(studios)
                    st=studios(i);
                    editor=st.App.getActiveEditor();
                    name=editor.getName();

                    try
                        modelName=bdroot(name);
                    catch



                        modelName=strtok(name,'/');
                    end

                    if(strcmp(modelName,appName))
                        studio=st;
                        break;
                    end
                end
            end

        end

        function closeInvalidNotifInStudio(studio)
            editor=studio.App.getActiveEditor();


            topLevelDiagram=studio.App.topLevelDiagram;
            modelHandle=topLevelDiagram.handle;
            modelName=get_param(modelHandle,'Name');

            messageId=strcat(modelName,'SpotlightInvalidNotification');
            editor.closeNotificationByMsgID(messageId);

            nonExistElemMessageId=strcat(modelName,'SpotlightNonExistElement');
            editor.closeNotificationByMsgID(nonExistElemMessageId);
        end

        function invalidateSpotlights(appHandle)
            appName=get_param(appHandle,'Name');
            studios=ZCStudio.StudioIntegManager.getAllStudiosWithRelatedSpotlights(appName);
            for i=1:length(studios)
                studio=studios(i);
                editor=studio.App.getActiveEditor();


                topLevelDiagram=studio.App.topLevelDiagram;
                modelHandle=topLevelDiagram.handle;
                modelName=get_param(modelHandle,'Name');

                messageId=strcat(modelName,'SpotlightInvalidNotification');
                message=DAStudio.message('Simulink:studio:SpotlightInvalidNotification',appName);
                editor.deliverInfoNotification(messageId,message);
            end
        end

        function refreshSpotlights(appName)
            systemcomposer.internal.arch.internal.refreshSpotlights(appName);


            selections={};
            sysarch.highlightRequirement(selections);
        end

        function closeSpotlights(appName)
            studios=ZCStudio.StudioIntegManager.getAllStudiosWithRelatedSpotlights(appName);
            for i=1:length(studios)
                studio=studios(i);
                ZCStudio.closeSpotlightInStudio(studio.getStudioTag());
            end
        end


        function closeLightViewFinder(studioTag)
            viewMode=find_slobj('GetProperty',studioTag,'viewMode');
            if(~isempty(viewMode)&&strcmp(viewMode,'lightView'))
                find_slobj('CloseFinder',studioTag);
            end
        end

        function createSpotlightFromSpotlight(studioTag,selectedSemanticElemUUID,modelName)
            semElem=systemcomposer.internal.getArchitectureElementFromDiagram(modelName,selectedSemanticElemUUID);
            if~isempty(studioTag)&&~isempty(semElem)
                selectedBlk.handle=systemcomposer.utils.getSimulinkPeer(semElem);
                openFromSpotlight=true;
                ZCStudio.ArchitectureMenu('createSpotlight',selectedBlk,studioTag,openFromSpotlight);
            end
        end

        function showInComposition(appName,compToShowUUID,studioTag)
            ZCStudio.closeSpotlightInStudio(studioTag);
            systemcomposer.internal.arch.internal.showInComposition(appName,compToShowUUID);
        end

        function updateZoomFactorInStudio(studioTag,zoomFactor)
            studio=DAS.Studio.getStudio(studioTag);
            if(~isempty(studio))
                studio.App.setZoomValueInStatusBarComponent(zoomFactor);
            end
        end

        function resetPropertyInspectorToModel(studio)
            propInspector=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');


            if~isempty(propInspector)
                topLevelDiagram=studio.App.topLevelDiagram;
                modelHandle=topLevelDiagram.handle;
                obj=get_param(modelHandle,'Object');
                objType=get_param(modelHandle,'Type');

                propInspector.updateSource(objType,obj);
            end
        end

        function highlightRequirement(modelName,diagramUuids)

            selections={};
            for i=1:length(diagramUuids)
                semElem=systemcomposer.internal.getArchitectureElementFromDiagram(modelName,diagramUuids{i});
                if~isempty(semElem)&&isa(semElem,'systemcomposer.architecture.model.design.Component')
                    selection=get_param(systemcomposer.utils.getSimulinkPeer(semElem),'Object');
                    selections{end+1}=selection;
                end
            end

            sysarch.highlightRequirement(selections);
        end


    end
end

