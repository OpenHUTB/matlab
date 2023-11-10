classdef(Hidden)CommentsManager<handle

    properties
modelName
modelUid
comments
uiComp
url
notificationTimer
deleteTimer
daMode
        modelOpened=false
        isReadOnly=false
        appInit=false;
        appOpen=false;
        commentListOpen=true;
        showResolved=true;
        modelPath;
        compCloseListener;
        filterComment=false;
    end

    methods(Static)
        function cm=get(model)
            cm=simulink.designreview.DesignReviewApp.getInstance().getCommentsManager(model);
        end
    end

    methods
        function this=CommentsManager(model,daMode)
            this.daMode=daMode;
            this.modelName=model;
            this.isReadOnly=false;
            this.comments=containers.Map('KeyType','char','ValueType','any');
            this.modelUid=designReviewClientStart(this.modelName,this.daMode);
            this.url=sprintf('/toolbox/collaboration/comments/web/index.html?clientId=%s',this.modelUid);
            initSimulinkCommentsClient(this.modelName);
            designReviewClientSetTargetURIProvider(this.modelName,@simulink.designreview.add_comment_cb);
            designReviewClientSetBlockSelectionProvider(this.modelName,@simulink.designreview.check_block_selection_cb);
            designReviewClientSetTargetSelectionHandler(this.modelName,@simulink.designreview.comment_selection_cb);

        end
    end

    methods

        function renameModel(this,newModel,oldModel)
            this.modelName=newModel;
            designReviewClientNameChange(newModel,oldModel);
            initSimulinkCommentsClient(this.modelName);
            designReviewClientSetTargetURIProvider(this.modelName,@simulink.designreview.add_comment_cb);
            designReviewClientSetBlockSelectionProvider(this.modelName,@simulink.designreview.check_block_selection_cb);
            designReviewClientSetTargetSelectionHandler(this.modelName,@simulink.designreview.comment_selection_cb);
            designReviewClientAppReadyStatus(this.modelName,this.appOpen,this.isReadOnly);
            if(this.appOpen&&slfeature('DesignReview_Stateflow')>0)
                builtin('_updateCommentsStateflowListenersOnModelNameChange',newModel,oldModel);
            end
        end

        function openModel(this)
            designReviewClientSwitchScope(this.modelName,this.modelName);
            this.setModelPath();
            preferences=builtin('_designReviewGetCommentsPreferences',this.modelName);
            if~strcmp(preferences.commentsCount,'0')
                designReviewRefreshBadges(this.modelName);
            end
            this.modelOpened=true;
        end

        function closeModel(this)
            if(this.appOpen&&slfeature('DesignReview_Stateflow')>0)
                builtin('_removeCommentsStateflowEventListeners',this.modelName);
            end
            builtin('_removeCommentsSLGLIMEventListeners',this.modelName);
            designReviewClientCloseModel(this.modelName);
        end

        function onModelSave(this)
            this.setModelPath();
            if this.appOpen&&this.isReadOnly
                this.checkReadOnly();
                designReviewClientAppReadyStatus(this.modelName,this.appOpen,this.isReadOnly);
                builtin('_designReviewInitCommentList',this.modelName);
            end
        end

        function chartPath=getChartPath(this)
            chartPath=[];
            modelHandle=get_param(this.modelName,'handle');
            if Simulink.BlockDiagramAssociatedData.isRegistered(modelHandle,'SFXFilePath')
                chartPath=Simulink.BlockDiagramAssociatedData.get(modelHandle,'SFXFilePath');
            end
        end

        function setModelPath(this)
            path=get_param(this.modelName,'filename');
            if isempty(path)
                path=this.getChartPath();
            end
            if~isempty(path)
                [filepath,name,~]=fileparts(path);
                this.modelPath=fullfile(filepath,[name,'.dat']);
                designReviewClientSetModelPath(this.modelName,this.modelPath);
            end
        end

        function modelUid=getModelUid(this)
            modelUid=this.modelUid;
        end

        function resetOpenModel(this)
            this.modelOpened=false;
        end

        function ret=isOpenModelCalled(this)
            ret=this.modelOpened;
        end

        function ret=isAppInit(this)
            ret=this.appInit;
        end


        function highlightBlock(~,blk)
            model=bdroot(blk);


            set_param(model,'HiliteAncestors','none');
            selected_blocks=find_system(model,'LookUnderMasks','all','FollowLinks','on','Selected','on');
            cellfun(@(b)(set_param(b,'Selected','off')),selected_blocks);


            set_param(blk,'Selected','on');

            parents=get_param(blk,'Parent');
            open_system(parents,'force');

            Simulink.scrollToVisible(blk,'ensureFit','off','panMode','minimal');

            studio=simulink.designreview.Util.getActiveStudio();
            studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blk));


            parent=get_param(blk,'Parent');
            if~isempty(parent)
                try
                    set_param(0,'CurrentSystem',parent);
                    set_param(parent,'CurrentBlock',get_param(blk,'Handle'));
                catch
                end
            end
        end

        function showUI(this,studio)
            this.appInit=true;
            this.commentListOpen=true;
            comp=studio.getComponent('GLUE2:DDG Component','COMMENTS');
            if isempty(comp)
                dlg=DAStudio.WebDDG;
                dlg.DisableContextMenu=true;
                dlg.Debug=false;
                dlg.Url=connector.getUrl(this.url);
                comp=GLUE2.DDGComponent(studio,'COMMENTS',dlg);
                comp.AllowMinimize=false;
                this.compCloseListener=addlistener(comp,"Closed",@(~,~)simulink.designreview.ToolStripManager.executeCommentListAction(false));
                studio.registerComponent(comp);
                studio.moveComponentToDock(comp,DAStudio.message('designreview_comments:Command:CommentsTitle'),'Right','Stacked');
            else
                studio.showComponent(comp);
            end
        end

        function hideUI(this,studio)
            this.commentListOpen=false;

            comp=studio.getComponent('GLUE2:DDG Component','COMMENTS');
            if~isempty(comp)&&comp.isVisible
                studio.hideComponent(comp);
            end

            if~isempty(this.deleteTimer)
                this.deleteTimer.stop;
            end
        end

        function clear(this)
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for idx=1:numel(studios)
                studio=studios(idx);
                model=get_param(studio.App.blockDiagramHandle,'Name');
                if strcmp(model,this.modelName)
                    this.hideUI(studio);
                end
            end
        end

        function checkReadOnly(this)


            if~isempty(this.modelPath)
                filePath=extractBefore(this.modelPath,".dat");
                filePath=append(filePath,'temp.dat');
                this.isReadOnly=false;
                [fid,errmsg]=fopen(filePath,'w');
                if~isempty(errmsg)
                    this.isReadOnly=true;
                end
                if exist(filePath,'file')
                    fclose(fid);
                    delete(filePath);
                end
            end
        end

        function handleAppOpen(this,studio)
            if isempty(this.modelPath)
                this.setModelPath();
            end
            this.checkReadOnly();
            if(slfeature('DesignReview_Stateflow')>0)
                builtin('_initStateflowCommentsClient',this.modelName);
            end
            builtin('_addCommentsSLGLIMEventListeners',this.modelName);
            designReviewClientAppReadyStatus(this.modelName,true,this.isReadOnly);
            if this.isAppInit()
                designReviewShowBadges(this.modelName,true);
            end
            this.showUI(studio);
            this.appOpen=true;
        end



        function handleAppClose(this,studio)
            if(this.appOpen&&slfeature('DesignReview_Stateflow')>0)
                builtin('_removeCommentsStateflowEventListeners',this.modelName);
            end
            this.appOpen=false;
            builtin('_removeCommentsSLGLIMEventListeners',this.modelName);
            designReviewClientAppReadyStatus(this.modelName,false,this.isReadOnly);
            if this.isAppInit()
                designReviewShowBadges(this.modelName,false);
            end
            this.hideUI(studio);
        end

        function ret=isAppOpen(this)
            ret=this.appOpen;
        end

        function setCommentListOpen(this,val)
            this.commentListOpen=val;
        end

        function ret=isCommentListOpen(this)
            ret=this.commentListOpen;
        end

        function setRemoveResolvedComments(this,val)
            this.showResolved=val;
        end

        function ret=isRemoveResolvedComments(this)
            ret=this.showResolved;
        end

        function setFilterComments(this,val)
            this.filterComment=val;
        end

        function ret=isFilterComments(this)
            ret=this.filterComment;
        end
    end
end

