


classdef ReplaceManager<handle

    methods(Static,Access=public)
        function replaceManager=getReplaceManager(uri)
            import simulink.search.internal.SearchInstanceManager;
            instanceManager=SearchInstanceManager.getSearchInstanceManager(uri);
            replaceManager=[];
            if isempty(instanceManager)
                return;
            end
            replaceManager=instanceManager.getReplaceManager();
        end

        function revertUrl=getWebPageUrl(studioTag)
            appendDebugStr='';
            if find_slobj('getDebugMode')
                appendDebugStr='-debug';
            end
            pageUrl='/toolbox/simulink/search/web/replaceRevert';
            revertUrl=connector.getUrl([pageUrl,appendDebugStr,'.html?'...
            ,'studioTag=',studioTag,'&test=false']);
        end
    end

    methods(Access=public)
        function obj=ReplaceManager()
            import simulink.search.internal.model.ReplaceModel;
            import simulink.search.internal.model.ReplacedInfoManager;
            import simulink.search.internal.model.ErrorManager;
            obj.m_replaceModel=ReplaceModel();
            obj.m_revertDialog=[];
            obj.m_revertInfoManager=ReplacedInfoManager();
            obj.m_revertErrorManager=ErrorManager();
        end

        function clearSearch(this)
            this.clearSearchCache();
            this.clearRevertRecords();
            if~isempty(this.m_revertDialog)
                this.m_revertDialog.close();
                this.m_revertDialog=[];
            end
        end

        function clearSearchCache(this)
            this.m_replaceModel.clearSearchCache();
        end

        function clearRevertRecords(this)
            this.m_replaceModel.clearReplaceRecords();
        end

        function cacheSearchSetting(this,searchRegx,isCaseSensitive)
            this.m_replaceModel.cacheSearchSetting(searchRegx,isCaseSensitive);
        end

        function cacheReplaceSetting(this,replaceRegx)
            this.m_replaceModel.cacheReplaceSetting(replaceRegx);
        end

        function replaceProperties(this,isMiniView,propsToReplace,timeStamp,replacedInfo,errorManager)
            oldWarnSetting=warning('off','all');
            this.m_replaceModel.doActionAndCreateRevert(...
            @doReplaceOnce,...
            isMiniView,...
            propsToReplace,...
            timeStamp,...
            replacedInfo,...
errorManager...
            );
            warning(oldWarnSetting);
        end

        function revertRecords=removeErrorsAndGetRevertRecords(this)
            this.m_replaceModel.removeRecordWithErrors(this.m_revertErrorManager);
            this.m_revertInfoManager.reset();
            this.m_revertErrorManager.reset();
            revertRecords=this.getRevertRecords();
        end

        function revertRecords=getRevertRecords(this)
            revertRecords=this.m_replaceModel.getRevertRecords();
        end

        function[revertInfoManager,errorManager]=revertSingleMatch(...
            this,...
            timeStamp,...
            blockUri,...
propertyId...
            )
            this.m_revertInfoManager.reset();
            this.m_revertErrorManager.reset();
            oldWarnSetting=warning('off','all');
            this.m_replaceModel.doActionForSingleMatch(...
            timeStamp,...
            blockUri,...
            propertyId,...
            @doReplaceOnce,...
            this.m_revertInfoManager,...
            this.m_revertErrorManager,...
true...
            );
            warning(oldWarnSetting);
            revertInfoManager=this.m_revertInfoManager;
            errorManager=this.m_revertErrorManager;

        end

        function[revertInfoManager,errorManager]=revertRecords(...
            this,...
records...
            )
            this.m_revertInfoManager.reset();
            this.m_revertErrorManager.reset();
            oldWarnSetting=warning('off','all');
            this.m_replaceModel.doActionForRecords(...
            records,...
            @doReplaceOnce,...
            this.m_revertInfoManager,...
            this.m_revertErrorManager,...
true...
            );
            warning(oldWarnSetting);
            revertInfoManager=this.m_revertInfoManager;
            errorManager=this.m_revertErrorManager;

        end

        function[revertInfoManager,errorManager]=revertAllRecords(this)
            this.m_revertInfoManager.reset();
            this.m_revertErrorManager.reset();
            oldWarnSetting=warning('off','all');
            this.m_replaceModel.doActionForAllRecords(...
            @doReplaceOnce,...
            this.m_revertInfoManager,...
            this.m_revertErrorManager,...
true...
            );
            warning(oldWarnSetting);
            revertInfoManager=this.m_revertInfoManager;
            errorManager=this.m_revertErrorManager;

        end

        function cacheSearchData(this,searchModel)
            this.m_replaceModel.cacheSearchData(searchModel);
        end

        function openRevertDialog(this,studioTag)
            import simulink.search.internal.ReplaceManager;
            if isempty(this.m_revertDialog)||~this.m_revertDialog.isWindowValid
                connector.ensureServiceOn;
                dlgUrl=ReplaceManager.getWebPageUrl(studioTag);
                this.m_revertDialog=matlab.internal.webwindow(dlgUrl);
                if isempty(studioTag)
                    this.m_revertDialog.Title='Revert replace';
                else
                    studio=DAS.Studio.getStudio(studioTag);
                    modelName=get_param(studio.App.blockDiagramHandle,'Name');
                    this.m_revertDialog.Title=['Revert replace - ',modelName];
                end
                this.m_revertDialog.show();
            end
            this.m_revertDialog.bringToFront();
        end

        function viewModeChanged(this,viewMode)




        end

        function stopReplace(this)
            this.m_replaceModel.stopAllActions();
        end
    end

    properties(Access=protected)
        m_replaceModel=[];
        m_revertDialog=[];
        m_revertInfoManager=[];
        m_revertErrorManager=[];
    end

    methods(Access=protected)
    end

    methods(Static,Access=protected)
        function revertProperty(replaceRecord)
        end
    end
end

function[errMsg,newValue]=doReplaceOnce(blockCache,replaceData)



    import simulink.search.internal.control.DoReplaceFrontController;
    [errMsg,newValue]=DoReplaceFrontController.doReplace(blockCache,replaceData);


end
