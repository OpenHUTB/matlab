

classdef SystemDocumentation<handle

    properties(Constant)

        MAP_ROUTER_CANCEL=-1;
        MAP_ROUTER_CREATE=0;
        MAP_ROUTER_IMPORT=1;
    end

    properties(Access=protected)
        m_modelName=[];


        m_router=[];


        m_studioWidgetMgrMap=[];

        m_PrintCallback=[];
    end

    methods(Static)




        function onNewSysDoc(sysdocObj)
            import simulink.sysdoc.internal.SysDocUtil;

            if nargin==0
                sysdocObj=SysDocUtil.getCurrentSystemDocumentation();
            end

            assert(SysDocUtil.isNotEmptyAndValid(sysdocObj));

            dialogTitle=message('simulink_ui:sysdoc:resources:NewNotesFileTitle').getString();
            filterSpec={'*.mldatx','Notes (*.mldatx)';...
            '*.*','All Files (*.*)'};

            defaultPath=sysdocObj.getDefaultNotesFilePath();

            [filename,pathName,filterIndex]=uiputfile(filterSpec,dialogTitle,defaultPath);
            if filterIndex==0
                return;
            end
            if filterIndex<=0
                filename='';
            end
            sysdocObj.newSysDoc(pathName,filename);
        end

        function onOpenSysDoc(sysdocObj)
            import simulink.sysdoc.internal.SysDocUtil;

            if nargin==0
                sysdocObj=SysDocUtil.getCurrentSystemDocumentation();
            end
            assert(SysDocUtil.isNotEmptyAndValid(sysdocObj));


            filterSpec={'*.mldatx','Notes (*.mldatx)';...
            '*.*','All Files (*.*)'};

            modelDir=sysdocObj.getModelDir();

            [filename,pathname,filterIndex]=uigetfile(filterSpec,...
            message('simulink_ui:sysdoc:resources:OpenNotesFileTitle').getString(),modelDir);
            if filterIndex==0
                return;
            end
            sysdocObj.openSysDoc(pathname,filename);
        end
    end

    methods(Access=public)
        function obj=SystemDocumentation(modelName)
            obj.m_modelName=modelName;
            obj.m_studioWidgetMgrMap=containers.Map;


            import simulink.sysdoc.internal.MixedMapRouter;
            obj.m_router=MixedMapRouter(obj.m_modelName);

            try
                get_param(modelName,'NotesPlugin');
            catch
                pluginMgr=Simulink.PluginMgr;
                modelHandle=get_param(modelName,'Handle');
                pluginMgr.attach(modelHandle,'NotesPlugin');
            end
        end

        function delete(obj)





            keySet=keys(obj.m_studioWidgetMgrMap);
            for key=keySet
                studioTag=key{1};
                studioWidgetMgr=obj.m_studioWidgetMgrMap(studioTag);
                if isvalid(studioWidgetMgr)
                    studioWidgetMgr.unRegisterHandler();
                end
            end
        end




        function enabled=isEnabled(this)
            enabled=true;
            return;
            enabled=this.m_router.isEnabled();
        end




        function name=getModelName(this)
            name=this.m_modelName;
        end

        function router=getRouter(this)
            router=this.m_router;
        end

        function modelDir=getModelDir(this)
            fullModelPath=which(this.getModelName);
            modelDir=fileparts(fullModelPath);
        end

        function defaultNotesFileName=getDefaultNotesFileName(this)
            defaultNotesFileName=[this.getModelName,'_notes.mldatx'];
        end

        function defaultNotesFilePath=getDefaultNotesFilePath(this)
            defaultNotesFilePath=fullfile(this.getModelDir(),this.getDefaultNotesFileName());
        end

        function setPrintCallback(this,cb)
            this.m_PrintCallback=cb;
        end

        function printContents(this,htmlContents,model,sid)
            if~isempty(this.m_PrintCallback)
                this.m_PrintCallback(htmlContents,model,sid);
            end
        end





        function success=new(this,fileName)
            success=this.m_router.new(fileName);
            this.resetStudioWidgetManagers();
            import simulink.sysdoc.internal.SysDocUtil;
            studio=SysDocUtil.getActiveStudio();
            studioWidgetMgr=this.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end
            studioWidgetMgr.actionToggleEditMode();
            import simulink.sysdoc.internal.MixedMapRouter;
            studioWidgetMgr.actionChangeBinding(MixedMapRouter.BINDING_TYPE_RTC);
        end

        function newSysDoc(this,filePath,fileName)
            if isempty(fileName)
                this.new('');
                set_param(this.m_modelName,'Notes','');
                return
            end
            this.new(fullfile(filePath,fileName));
            set_param(this.m_modelName,'Notes',fileName);
        end

        function success=open(this,path)
            success=false;
            import simulink.sysdoc.internal.SysDocUtil;
            if~this.m_router.open(path,@()this.preCloseForAllStudios())
                return;
            end
            this.resetStudioWidgetManagers();
            success=true;
        end

        function openSysDoc(this,pathName,fileName)
            if~this.open(fullfile(pathName,fileName))
                return;
            end

            set_param(this.m_modelName,'Notes',fileName);
        end

        function success=export(this,path)
            success=this.m_router.export(path);
        end




        function preCloseForAllStudios(this)
            import simulink.sysdoc.internal.SysDocUtil;
            keySet=keys(this.m_studioWidgetMgrMap);
            for key=keySet

                studioTag=key{1};
                studio=DAS.Studio.getStudio(studioTag);
                studioWidgetMgr=this.m_studioWidgetMgrMap(studioTag);

                if SysDocUtil.isNotEmptyAndValid(studio)&&SysDocUtil.isNotEmptyAndValid(studioWidgetMgr)
                    studioWidgetMgr.handlePreClose();
                else

                    this.m_studioWidgetMgrMap.remove(studioTag);
                end
            end
        end


        function resetStudioWidgetManagers(this)
            import simulink.sysdoc.internal.SysDocUtil;
            keySet=keys(this.m_studioWidgetMgrMap);
            for key=keySet

                studioTag=key{1};
                studio=DAS.Studio.getStudio(studioTag);
                studioWidgetMgr=this.m_studioWidgetMgrMap(studioTag);

                if SysDocUtil.isNotEmptyAndValid(studio)&&SysDocUtil.isNotEmptyAndValid(studioWidgetMgr)

                    if studioWidgetMgr.isVisible()&&~this.m_router.isEnabled()
                        studioWidgetMgr.hide();
                    else
                        studioWidgetMgr.resetWidgets();
                    end
                else

                    this.m_studioWidgetMgrMap.remove(studioTag);
                end
            end
        end







        function studioWidgetMgr=getStudioWidgetManager(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=[];
            if~this.isEnabled()||~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end

            studioTag=studio.getStudioTag();
            if~this.m_studioWidgetMgrMap.isKey(studioTag)
                return;
            end

            studioWidgetMgr=this.m_studioWidgetMgrMap(studioTag);
        end


        function studioWidgetMgr=createStudioWidgetManager(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=[];

            if~this.isEnabled()||~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end
            assert(~this.m_studioWidgetMgrMap.isKey(studio.getStudioTag()),'StudioWidgetManager::createStudioWidgetManager - StudioWidgetManager should not be created repeatedly.');




            import simulink.sysdoc.internal.StudioWidgetManager;
            studioWidgetMgr=StudioWidgetManager(studio,this.m_router);
            this.m_studioWidgetMgrMap(studio.getStudioTag())=studioWidgetMgr;
            assert(~isempty(studioWidgetMgr),'sysdoc.internal.StudioWidgetManager::createStudioWidgetManager - Unable to create sysdoc StudioWidgetManager.');
            this.subscribeBlockDiagramCallBacks(studio);
        end


        function subscribeBlockDiagramCallBacks(this,studio)
            subscribeBlockDiagramCB(studio,...
            'PreClose',...
            @()this.handlePreClose(studio));

            subscribeBlockDiagramCB(studio,...
            'PostNameChange',...
            @()this.handlePostNameChanged(studio));

        end

        function handlePreCloseModelLevel(this,studio)
            this.m_router.resetAll();



        end

        function handlePreClose(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)

                return;
            end

            studioTag=studio.getStudioTag();
            if~this.m_studioWidgetMgrMap.isKey(studioTag)

                return;
            end
            studioWidgetMgr=this.m_studioWidgetMgrMap(studioTag);
            if isempty(studioWidgetMgr)

                return;
            end

            studioWidgetMgr.handlePreClose();
            this.handlePreCloseModelLevel();
        end

        function handlePostNameChanged(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end


            newModelName=SysDocUtil.getModelName(studio);
            newModelPath=SysDocUtil.getModelPath(newModelName);
            oldModelPath=this.m_router.getZipFilePath();
            if strcmp(oldModelPath,newModelPath)

                return;
            end


            studioTag=studio.getStudioTag();
            studioWidgetMgr=this.m_studioWidgetMgrMap(studioTag);
            if isempty(studioWidgetMgr)
                return;
            end
            studioWidgetMgr.saveDirtyForModel(this.m_modelName);


            import simulink.SystemDocumentationApplication;
            import simulink.sysdoc.internal.OPCIOProxy;


            sysdocApp=SystemDocumentationApplication.getInstance();
            import simulink.sysdoc.internal.SysDocUtil;
            newSysdocObj=sysdocApp.getSystemDocumentation(newModelName);
            this.unsubscribeAll(studio);
            if isempty(newSysdocObj)
                newSysdocObj=sysdocApp.createSystemDocumentation(newModelName);
                assert(~isempty(newSysdocObj));
            end


            newSysdocObj.subscribeBlockDiagramCallBacks(studio);


            import simulink.sysdoc.internal.SysDocUtil;
            SysDocUtil.unSubscribeModelBlockDiagramCB(newModelName,'PreClose','SystemDocumentation');
            SysDocUtil.subscribeModelBlockDiagramCB(newModelName,...
            'PreClose',...
            'SystemDocumentation',...
            @()(simulink.SystemDocumentationApplication.close(newModelName)));


            newSysdocObj.m_studioWidgetMgrMap(studioTag)=studioWidgetMgr;
            this.m_studioWidgetMgrMap.remove(studioTag);
            studioWidgetMgr.setRouter(newSysdocObj.m_router);

            sysdocApp.removeSystemDocumentationForModel(this.m_modelName);
        end
    end

    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})
    end

    methods(Access=protected)
        function unsubscribeAll(this,studio)
            studioTag=studio.getStudioTag();
            assert(this.m_studioWidgetMgrMap.isKey(studioTag));
            unSubscribeBlockDiagramCB(studio,'PreClose');
            unSubscribeBlockDiagramCB(studio,'PostNameChange');
        end
    end
end




function subscribeBlockDiagramCB(studio,serviceName,cbFunc)
    import simulink.sysdoc.internal.SysDocUtil;
    if~SysDocUtil.isNotEmptyAndValid(studio)
        return;
    end

    handle=studio.App.blockDiagramHandle;
    obj=get_param(handle,'Object');
    callbackID=getStudioId(studio);
    if~obj.hasCallback(serviceName,callbackID)
        Simulink.addBlockDiagramCallback(handle,serviceName,callbackID,cbFunc);
    end
end

function unSubscribeBlockDiagramCB(studio,serviceName)
    import simulink.sysdoc.internal.SysDocUtil;
    if~SysDocUtil.isNotEmptyAndValid(studio)
        return;
    end

    handle=studio.App.blockDiagramHandle;
    obj=get_param(handle,'Object');
    callbackID=getStudioId(studio);
    if obj.hasCallback(serviceName,callbackID)
        Simulink.removeBlockDiagramCallback(handle,serviceName,callbackID);
    end
end

function id=getStudioId(studio)
    id=[studio.getStudioTag,'_SysDoc'];
end
