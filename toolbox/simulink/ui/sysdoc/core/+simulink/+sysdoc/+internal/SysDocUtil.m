

classdef SysDocUtil
    methods(Static)




        function studio=getActiveStudio()
            studio=[];
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(allStudios)
                studio=allStudios(1);
            end
        end

        function sysdocObj=getSystemDocumentation(studio)
            sysdocObj=[];
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end
            modelName=SysDocUtil.getModelName(studio);
            import simulink.SystemDocumentationApplication;
            sysdocObj=SystemDocumentationApplication.getInstance().getSystemDocumentation(modelName);
        end

        function sysdocObj=getCurrentSystemDocumentation()
            import simulink.sysdoc.internal.SysDocUtil;
            studio=SysDocUtil.getActiveStudio();
            sysdocObj=SysDocUtil.getSystemDocumentation(studio);
        end


        function studioWidgetMgr=getStudioWidgetManager(studio)
            studioWidgetMgr=[];
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)||isempty(studio.App)
                return;
            end
            modelName=SysDocUtil.getModelName(studio);
            studioWidgetMgr=SysDocUtil.getModelStudioWidgetManager(studio,modelName);
        end


        function studioWidgetMgr=getModelStudioWidgetManager(studio,modelName)
            studioWidgetMgr=[];
            import simulink.sysdoc.internal.SysDocUtil;
            assert(SysDocUtil.isNotEmptyAndValid(studio)&&~isempty(studio.App));
            import simulink.SystemDocumentationApplication;
            sysdocObj=SystemDocumentationApplication.getInstance().getSystemDocumentation(modelName);
            if isempty(sysdocObj)
                return;
            end
            studioWidgetMgr=sysdocObj.getStudioWidgetManager(studio);
        end

        function studioWidgetMgr=getCurrentStudioWidgetManager()
            studioWidgetMgr=[];
            import simulink.sysdoc.internal.SysDocUtil;
            studio=SysDocUtil.getActiveStudio();
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end
            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
        end



        function subscribeModelBlockDiagramCB(modelName,serviceName,serviceID,cbFunc)
            if~bdIsLoaded(modelName)
                return;
            end

            obj=get_param(modelName,'Object');
            if~obj.hasCallback(serviceName,serviceID)
                Simulink.addBlockDiagramCallback(modelName,serviceName,serviceID,cbFunc);
            end
        end

        function unSubscribeModelBlockDiagramCB(modelName,serviceName,serviceID)
            if~bdIsLoaded(modelName)
                return;
            end

            obj=get_param(modelName,'Object');
            if obj.hasCallback(serviceName,serviceID)
                Simulink.removeBlockDiagramCallback(modelName,serviceName,serviceID);
            end
        end




        function valid=isNotEmptyAndValid(obj)
            valid=~isempty(obj)&&isvalid(obj);
        end

        function visible=isVisible(obj,studio)
            visible=~strcmp(studio.getComponentLocation(obj),'Invisible')&&obj.isVisible;
        end

        function enabled=isComponentVisible(comp,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            enabled=SysDocUtil.isNotEmptyAndValid(comp)&&SysDocUtil.isVisible(comp,studio);
        end

        function modelName=getModelName(studio)
            assert(~isempty(studio));
            assert(~isempty(studio.App));
            modelName=get_param(studio.App.blockDiagramHandle,'Name');
        end

        function modelPath=getModelPath(modelName)
            try
                modelPath=get_param(modelName,'FileName');
            catch
                modelPath='';
            end
        end


        function[filePath,success]=generateZipFilePath(modelName,extension)
            import simulink.sysdoc.internal.MixedMapRouter;
            filePath=[];
            success=MixedMapRouter.NO_DOC_FILE;
            if isempty(modelName)
                return;
            end

            import simulink.sysdoc.internal.SysDocUtil;
            modelPath=SysDocUtil.getModelPath(modelName);
            fileName=get_param(modelName,'Notes');
            if isempty(fileName)
                return;
            end
            success=MixedMapRouter.DOC_FILE_NOT_FOUND;
            smlDoc=fileparts(modelPath);

            filePath=fullfile(smlDoc,fileName);
            if~exist(filePath,'file')
                filePath=which(fileName);
            end

            if~isempty(filePath)
                success=MixedMapRouter.DOC_FILE_FOUND;
            end
        end

        function[comp]=getComponentFromStudio(studio,title,compType)
            try
                comp=studio.getComponent(compType,title);
            catch
                comp=[];
            end
        end

        function[fileIsDir,dirContents]=isDirectory(filename)


            dirContents=dir(filename);
            dirContents={dirContents.name};
            fileIsDir=numel(dirContents)>1;
            if fileIsDir
                dirContents=setdiff(dirContents,{'.','..'});
            end
        end


        function result=changeActiveEditorByFullPath(studio,fullPath)
            result=false;
            diagramInfo=SLM3I.Util.getDiagram(fullPath);
            if isempty(diagramInfo.diagram)
                root=Stateflow.Root;
                [pathstr,name,ext]=fileparts(fullPath);
                sfObj=root.find('Path',pathstr,'Name',name);

                return;
            end
            studio.App.openEditor(diagramInfo.diagram);
            result=true;
        end



        function path=getContentPath()
            path=fullfile(fileparts(mfilename('fullpath')),'content');
        end

        function asyncFuncMgr=startAsyncFuncManager(asyncFuncMgr,fcn,errFcn)
            import dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status;
            processResultStatus=asyncFuncMgr.Status;
            if processResultStatus==Status.Created
                asyncFuncMgr.start(fcn,'OnError',errFcn);
            elseif processResultStatus==Status.Paused
                asyncFuncMgr.resume();
            elseif processResultStatus==Status.Stopped||processResultStatus==Status.Errored
                asyncFuncMgr.delete();
                asyncFuncMgr=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
                processResultStatus=asyncFuncMgr.Status;
                if processResultStatus==Status.Created
                    asyncFuncMgr.start(fcn,'OnError',errFcn);
                end
            end
        end

        function pauseAsyncFunctionManager(asyncFuncMgr)
            import dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status;
            processResultStatus=asyncFuncMgr.Status;
            if processResultStatus~=Status.Running
                return;
            end
            asyncFuncMgr.pause();
        end
    end

    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})
    end
end
