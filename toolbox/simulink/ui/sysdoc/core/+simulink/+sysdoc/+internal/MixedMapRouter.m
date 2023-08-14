

classdef MixedMapRouter<handle
    properties(Constant,Hidden)

        BINDING_TYPE_INVALID=-1;
        BINDING_TYPE_RTC=1;
        BINDING_TYPE_HTTP=2;
        BINDING_TYPE_INHERIT=3;
        BINDING_TYPE_NONE=4;
        BINDING_TYPE_NODOC=5;
        BINDING_TYPE_MODELREUSE=6;

        DOC_FILE_FOUND=0;
        DOC_FILE_NOT_FOUND=-1;
        NO_DOC_FILE=-2;

        BINDING_STR_TYPE_RTC=num2str(simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_RTC);
    end

    properties(Access=protected)
        m_modelName=[];
        m_opcIOProxy=[];


        m_linkToWrongFile=false;


        m_bindingMap=[];
        m_lastHttpBindingMap=[];


        m_zipFilePath=[];
        m_zipFileStatus=[];
    end

    methods(Access=public)
        function obj=MixedMapRouter(modelName)
            obj.m_modelName=modelName;
            obj.m_bindingMap=[];
            obj.m_linkToWrongFile=false;


            import simulink.sysdoc.internal.SysDocUtil;
            import simulink.sysdoc.internal.OPCIOProxy;
            [obj.m_zipFilePath,obj.m_zipFileStatus]=SysDocUtil.generateZipFilePath(obj.m_modelName,OPCIOProxy.DOC_EXTENSION);

            obj.m_opcIOProxy=OPCIOProxy(obj.m_zipFilePath);

            obj.reloadAll();
        end




        function enabled=isEnabled(this)
            enabled=isa(this.m_bindingMap,'containers.Map')||isempty(this.m_zipFilePath);
        end

        function status=getZipFileStatus(this)
            status=this.m_zipFileStatus;
        end

        function setModelName(this,modelName)
            this.m_modelName=modelName;
        end





        function[type,uri,content]=getURLAndContent(this,sysDocID,checkParentIfBoundNotExist)
            assert(isscalar(sysDocID))
            assert(isa(sysDocID,'simulink.sysdoc.internal.SysDocID'));

            assert(isscalar(checkParentIfBoundNotExist));
            assert(islogical(checkParentIfBoundNotExist));

            if isempty(this.m_zipFilePath)
                type=MixedMapRouter.BINDING_TYPE_NODOC;
                uri='';
                content='';
                return;
            end
            content=[];
            [type,uri]=this.getURL(sysDocID,checkParentIfBoundNotExist);
            import simulink.sysdoc.internal.MixedMapRouter;
            if type~=MixedMapRouter.BINDING_TYPE_RTC
                return;
            end
            content=this.loadJSONContent(uri);
        end












        function[type,uri]=getURL(this,sysDocID,checkParentIfBoundNotExist)
            assert(isscalar(sysDocID));
            assert(isa(sysDocID,'simulink.sysdoc.internal.SysDocID'));

            assert(isscalar(checkParentIfBoundNotExist));
            assert(islogical(checkParentIfBoundNotExist));

            [type,uri]=this.getUri(sysDocID,checkParentIfBoundNotExist);
        end


        function rootSysDocID=getDocRoot(this,sysDocID)
            assert(isscalar(sysDocID));
            assert(isa(sysDocID,'simulink.sysdoc.internal.SysDocID'));

            [~,~,rootSysDocID]=this.getDocRecursively(sysDocID);
        end

        function lastUrl=getLastBindingUrl(this,sysDocID)
            assert(isscalar(sysDocID));
            assert(isa(sysDocID,'simulink.sysdoc.internal.SysDocID'));

            sysDocIDString=sysDocID.SysDocIDString;

            lastUrl='';
            if~this.m_lastHttpBindingMap.isKey(sysDocIDString)
                return;
            end
            value=this.m_lastHttpBindingMap(sysDocIDString);
            [~,lastUrl]=value{:};
        end






        function success=new(this,fileName)
            this.m_bindingMap=[];


            if~this.m_opcIOProxy.new(fileName)

                error(['SystemDocumentation::new - '...
                ,message('simulink_ui:sysdoc:resources:FailedToCreateDoc',obj.m_zipFilePath).getString()]);
            end
            this.m_zipFilePath=fileName;
            this.m_bindingMap=containers.Map;
            this.m_lastHttpBindingMap=containers.Map;
            this.m_opcIOProxy.setModelName(this.m_modelName);
            this.exportAllBindings();

            success=true;
        end



        function success=open(this,path,funcCloseNotesCB)
            success=false;
            import simulink.sysdoc.internal.OPCIOProxy;
            newOPCIOProxy=OPCIOProxy(path);
            import simulink.sysdoc.internal.SysDocUtil;
            [success,needUpdateVersion]=this.openFileWithOPCIOProxy(newOPCIOProxy,...
            @continueWithUnmatchedNotesFileCB);
            if~success
                return;
            end
            funcCloseNotesCB();

            this.m_opcIOProxy.reset();
            this.m_opcIOProxy=newOPCIOProxy;
            this.m_zipFilePath=path;
            if needUpdateVersion
                this.setLinkToWrongFile(true);
            end
            this.m_bindingMap=[];
            this.populateAllBindings();
            success=true;
        end

        function success=export(this,path)
            success=true;
            this.m_opcIOProxy.writeToZipFile(path);
        end



        function isErrorLink=linkToWrongFile(this)
            isErrorLink=this.m_linkToWrongFile;
        end

        function fixErrorModelLink(this)
            if this.m_linkToWrongFile
                this.m_opcIOProxy.setModelName(this.m_modelName);
                this.saveAll();
            end
        end

        function[messageID,unicodeMsg]=getLinkToWrongFileWarnMessage(this)
            messageID='simulink_ui:sysdoc:resources:needToUpdateModelLink';
            unicodeMsg=message(messageID,...
            this.m_opcIOProxy.getModelName(),...
            this.m_modelName).getString();
        end





        function widget=createContentWidget(this,studio,editMode)
            import simulink.sysdoc.internal.MixedContentWidget;
            widget=MixedContentWidget(studio,this,editMode,false);
        end




        function changed=addRTCBinding(this,sysDocIDString)
            import simulink.sysdoc.internal.MixedMapRouter;
            changed=this.changeBinding(sysDocIDString,MixedMapRouter.BINDING_TYPE_RTC,'');
        end





        function changed=changeBinding(this,sysDocIDString,type,url)
            import simulink.sysdoc.internal.MixedMapRouter;
            changed=false;


            oldUrl='';
            oldType=MixedMapRouter.BINDING_TYPE_INVALID;
            if this.m_bindingMap.isKey(sysDocIDString)
                value=this.m_bindingMap(sysDocIDString);
                [oldType,oldUrl]=value{:};
            end

            if type~=MixedMapRouter.BINDING_TYPE_HTTP
                if type==oldType
                    return;
                end

                url=oldUrl;
            else
                if type==oldType&&strcmp(oldUrl,url)
                    return;
                end
                if isempty(url)
                    url=oldUrl;
                end
            end


            this.m_bindingMap(sysDocIDString)={type,url};
            this.exportAllBindings();
            changed=true;
        end



        function updateHttpBinding(this,sysDocID,newUrl)
            sysDocIDString=sysDocID.SysDocIDString;

            assert(this.m_bindingMap.isKey(sysDocIDString));
            value=this.m_bindingMap(sysDocIDString);
            [type,url]=value{:};
            if strcmp(url,newUrl)
                return;
            end
            import simulink.sysdoc.internal.MixedMapRouter;
            this.m_lastHttpBindingMap(sysDocIDString)={MixedMapRouter.BINDING_TYPE_HTTP,url};
            this.m_bindingMap(sysDocIDString)={type,newUrl};
            this.exportAllBindings();
        end




        function createContent(this,uri)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            this.saveJSONContent(uri,JSClientRTCProxy.RTC_EMPTY_CONTENT);
        end

        function removeContent(this,uri)
            this.m_opcIOProxy.deleteRTCFile(uri);
            this.saveAll();
        end

        function saveJSONContent(this,uri,msg)
            this.m_opcIOProxy.writeToRTCFile(uri,msg);
            this.saveAll();
        end

        function msg=loadJSONContent(this,uri)
            msg=this.m_opcIOProxy.readFromRTCFile(uri);
        end

        function saveAll(this)
            this.m_opcIOProxy.save();
        end

        function exists=fileExists(this,uri)
            exists=this.m_opcIOProxy.fileExists(uri);
        end

        function resetAll(this)
            this.m_opcIOProxy.reset();
            this.m_bindingMap=[];
            this.m_zipFilePath='';
        end

        function reloadAll(this)
            import simulink.sysdoc.internal.SysDocUtil;
            [success,needUpdateVersion]=this.openFileWithOPCIOProxy(this.m_opcIOProxy,...
            @continueWithUnmatchedNotesFileCB);
            if~success
                this.resetAll();
                return;
            end
            if needUpdateVersion
                this.setLinkToWrongFile(true);
            end
            this.populateAllBindings();
        end

        function zipFilePath=getZipFilePath(this)
            zipFilePath=this.m_zipFilePath;
        end
    end

    methods(Access=protected)



        function populateAllBindings(this)
            this.m_bindingMap=this.m_opcIOProxy.populateCurrentBindings();
            this.m_lastHttpBindingMap=this.m_opcIOProxy.populateLastBindings();
            if~isa(this.m_lastHttpBindingMap,'containers.Map')
                this.m_lastHttpBindingMap=containers.Map;
            end
        end

        function exportAllBindings(this)
            this.m_opcIOProxy.exportCurrentBindings(this.m_bindingMap);
            this.m_opcIOProxy.exportLastBindings(this.m_lastHttpBindingMap);
            this.saveAll();
        end




        function[type,uri]=getUri(this,sysDocID,checkParentIfBoundNotExist)

            import simulink.sysdoc.internal.MixedMapRouter;
            if checkParentIfBoundNotExist
                [type,uri]=this.getDocRecursively(sysDocID);
            else
                [type,uri]=this.getCurrentRoute(sysDocID);
            end

            if isempty(uri)||type~=MixedMapRouter.BINDING_TYPE_HTTP
                return;
            end


            if strncmp(uri,'http://',7)||...
                strncmp(uri,'https://',8)
                return;
            end

            if~isempty(uri)&&(uri(1)=='/'||uri(1)=='\')
                uri=uri(2:end);
            end












            if~strcmp(uri,"about:blank")&~strncmp(uri,'file://',7)
                uri=['https://',uri];
            end




        end

        function[type,route]=getCurrentRoute(this,sysDocID)
            import simulink.sysdoc.internal.MixedMapRouter;

            sysDocIdString=sysDocID.SysDocIDString;

            if~this.m_bindingMap.isKey(sysDocIdString)
                type=MixedMapRouter.BINDING_TYPE_INHERIT;
            else
                value=this.m_bindingMap(sysDocIdString);
                [type,route]=value{:};
            end
            if type~=MixedMapRouter.BINDING_TYPE_HTTP
                route=sysDocIdString;
            end
        end



        function[type,route,sysDocID]=getDocRecursively(this,sysDocID)
            import simulink.sysdoc.internal.MixedMapRouter;
            while true
                [type,route]=this.getCurrentRoute(sysDocID);
                if type~=MixedMapRouter.BINDING_TYPE_INHERIT
                    return;
                end

                parentID=sysDocID.Parent;

                if isempty(parentID)
                    return;
                end
                sysDocID=parentID;
            end
        end



        function[success,needUpdateVersion]=openFileWithOPCIOProxy(this,opcIOProxy,funcUnmatchedCB)
            success=false;
            needUpdateVersion=false;
            if~opcIOProxy.open()
                sysDocApp=simulink.SystemDocumentationApplication.getInstance();

                if~isempty(opcIOProxy.getZipFilePath())
                    [~,fileName,ext]=fileparts(opcIOProxy.getZipFilePath());

                    dlgHandle=errordlg(message('simulink_ui:sysdoc:resources:WrongNotesFile',message('simulink_ui:sysdoc:resources:SysDocOPCType').getString()).getString(),...
                    message('simulink_ui:sysdoc:resources:WrongNotesFileTitle',[fileName,ext]).getString());
                    if sysDocApp.isTestMode()
                        uiwait(dlgHandle);
                    end
                end
                return;
            end

            import simulink.sysdoc.internal.SysDocUtil;
            [continueOpen,needUpdateVersion]=this.validateZipFileVersion(opcIOProxy,funcUnmatchedCB);
            if~continueOpen
                return;
            end
            success=true;
        end



        function[continueOpen,needUpdateVersion]=validateZipFileVersion(this,opcIOProxy,funcUnmatchedCB)
            opcIOProxy.readModelInfo();
            continueOpen=false;
            needUpdateVersion=false;
            if~opcIOProxy.isModelAndVersionMatch(this.m_modelName)
                assert(bdIsLoaded(this.m_modelName));
                versionStr=get_param(this.m_modelName,'ModelVersion');
                [~,fileName,ext]=fileparts(opcIOProxy.getZipFilePath());

                if~funcUnmatchedCB([fileName,ext],this.m_modelName,versionStr,opcIOProxy.getModelName(),opcIOProxy.getModelVersion())
                    return;
                end
                needUpdateVersion=true;
            end
            continueOpen=true;
        end


        function setLinkToWrongFile(this,linkToWrongFile)
            this.m_linkToWrongFile=linkToWrongFile;
        end


    end

    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})
        function opcIOProxy=getOPCIOProxy(this)
            opcIOProxy=this.m_opcIOProxy;
        end
    end

end


function continueOpen=continueWithUnmatchedNotesFileCB(~,~,~,~,~)
    continueOpen=true;
end
