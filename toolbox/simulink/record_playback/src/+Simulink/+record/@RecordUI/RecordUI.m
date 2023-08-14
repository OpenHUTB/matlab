


classdef RecordUI<handle


    methods


        function obj=RecordUI(config)
            Simulink.sdi.internal.startConnector;
            obj.Config=config;
            obj.openGUI();
        end
    end

    methods(Static)


        function url=getURL(blockId,appId,title,domain)

            apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();

            REL_URL='toolbox/shared/sdi/web/MainView/sdi.html';

            url=getURL(apiObj,REL_URL);

            url=[url,'&blockId=',blockId];
            url=[url,'&streamout=',title];
            url=[url,'&appId=',appId];
            url=[url,'&domain=',urlencode(domain)];
            url=[url,'&enableSparklineTimeLabels=true'];
        end

        function editor=getMatchingEditor(d)
            editorHID=GLUE2.HierarchyServiceUtils.getDefaultHID(d);
            if GLUE2.StudioApp.isInInteractiveOpen
                editorHID=GLUE2.StudioApp.getHIDOfObjectBeingOpenedInteractively;
                if GLUE2.HierarchyService.isValid(editorHID)
                    if GLUE2.HierarchyService.isElement(editorHID)
                        editorHID=GLUE2.HierarchyServiceUtils.getDiagramHIDWithParent(d,editorHID);
                    end
                end
            end

            editor=GLUE2.Editor.findEditorsWithHid(editorHID);
        end
    end


    methods(Access=private)


        function openGUI(this,varargin)

            blkHandle=getSimulinkBlockHandle(this.Config.BlockPath);

            if(strcmp(get_param(bdroot(blkHandle),'Lock'),'on'))
                if(strcmp(get_param(blkHandle,'CompatibilityTag'),'XY'))
                    errordlg(getString(message('record_playback:errors:OpenXYUIInLockedSystem')));
                else
                    errordlg(getString(message('record_playback:errors:OpenUIInLockedSystem')));
                end
                return;
            end

            dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
            Simulink.record.internal.RecordBlockExportDialog.getRecordBlockExportDialogInstance(dispatcherObj);

            url=this.getURL(this.Config.BlockId,...
            this.Config.AppId,this.Config.Title,...
            this.Config.Domain);

            studioApp=[];
            if GLUE2.StudioApp.isInInteractiveOpen

                studioApp=GLUE2.StudioApp.getStudioAppForInteractiveOpen();
                openType=studioApp.getEditorOpenType();
            else

                openType=this.Config.OpenType;

                studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(blkHandle));
            end

            if~isempty(studioApp)



                d=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle(blkHandle);
                matchingEditor=this.getMatchingEditor(d);
                if~isempty(matchingEditor)
                    studio=matchingEditor.getStudio();
                    tabIndex=studio.getTabByComponent(matchingEditor);
                    studio.show();
                    studio.focusTab(tabIndex);
                    return;
                end
            end

            this.OpenType=openType;

            if slsvTestingHook('DisableRecordUILoad')
                if isempty(studioApp)
                    open_system(bdroot(blkHandle));
                    studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(blkHandle));
                end
                d=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle(blkHandle);
                editor=studioApp.openEditor(d);
            else
                editor=SLStudio.StudioAdapter.StudioAdapterOpenFcn(blkHandle,url,openType);
            end
            editor.DestroyOnHide=true;
        end


        function matchingOpenType=getOpenTypeForEditor(this,editor)
            matchingOpenType='';
            path=Simulink.BlockPath(GLUE2.HierarchyService.getPaths(editor.getCurrentHierarchyId));
            instanceInfo=get_param(this.Config.BlockPath,'InstanceInfo');
            structLen=length(instanceInfo);
            for index=1:structLen
                sfullBlockPath=Simulink.BlockPath(instanceInfo(index).fullBlockPath);
                if sfullBlockPath.isequal(path)
                    matchingOpenType=instanceInfo(index).openType;
                    break;
                end
            end
        end

    end


    properties
        OpenType='';
    end



    properties(Hidden)
Config
    end


    properties(Hidden,Constant)
        DEBUG_URL='toolbox/shared/sdi/web/MainView/sdi-debug.html';
    end

end
