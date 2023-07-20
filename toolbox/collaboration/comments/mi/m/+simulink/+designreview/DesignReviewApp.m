classdef(Hidden)DesignReviewApp<handle






    methods(Static,Access=public)
        function dr=getInstance()
            persistent instance;
            if isempty(instance)
                instance=simulink.designreview.DesignReviewApp();
            end
            dr=instance;
        end

        function initDesignPerspective(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            dr.init();
            if~dr.getCommentsManager(model).isOpenModelCalled()
                dr.getCommentsManager(model).openModel();
            end
        end

        function closeDesignPerspective(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(dr.isInitialized)
                if dr.perspectiveManager.isPerspectiveEnabled(model)
                    dr.perspectiveManager.disablePerspective(model);
                end
                cm=dr.getExistingCommentsManager(model);
                if~isempty(cm)
                    cm.closeModel();
                    cm.resetOpenModel();
                    dr.clear(model);
                end
            end
        end

        function onModelNameChange(newModel,oldModel)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(dr.isInitialized)
                cm=dr.getExistingCommentsManager(oldModel);
                if~isempty(cm)
                    cm.renameModel(newModel,oldModel);
                    dr.commentsManager(newModel)=cm;
                    dr.perspectiveManager.disablePerspective(oldModel);
                    dr.clear(oldModel);
                end
            end
        end

        function onModelSave(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(dr.isInitialized)
                cm=dr.getExistingCommentsManager(model);
                if~isempty(cm)
                    cm.onModelSave();
                end
            end
        end

        function ret=isCommentsAppOpen(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            cm=dr.getExistingCommentsManager(model);
            if isempty(cm)
                ret=false;
            else
                ret=cm.isAppOpen();
            end
        end

        function openCommentsApp(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(dr.isInitialized)
                cm=dr.getExistingCommentsManager(model);
                if~isempty(cm)&&~cm.isAppOpen()
                    studio=simulink.designreview.Util.getActiveStudio();
                    simulink.designreview.ToolStripManager.showApp(studio);
                end
            end
        end
    end

    methods(Access=public)
        function setServerCommit(this)
            this.daMode='server';
        end

        function initDesignReviewApplication(this)

        end

        function ret=isInitializedCalled(this)
            ret=this.isInitialized;
        end

        function ret=isReadOnlyFolder(this,model)
            ret=this.getCommentsManager(model).isReadOnly;
        end

    end


    methods
        function delete(this)
            this.terminate();
        end
    end


    properties
        perspectiveManager;
        commentsManager;
        daMode='local';
        isInitialized;
    end

    properties(Access=private)
    end


    methods(Access=private)

        function this=DesignReviewApp()
            this.isInitialized=false;
            this.commentsManager=containers.Map;
        end

    end

    methods
        function cm=getCommentsManager(this,model)
            modelName=model;
            if(~this.commentsManager.isKey(modelName))
                cm=simulink.designreview.CommentsManager(modelName,this.daMode);
                this.commentsManager(modelName)=cm;
            end
            cm=this.commentsManager(modelName);
        end

        function cm=getExistingCommentsManager(this,model)
            if(this.commentsManager.isKey(model))
                cm=this.commentsManager(model);
            else
                cm=simulink.designreview.CommentsManager.empty();
            end
        end

        function clear(this,model)
            if this.commentsManager.isKey(model)
                this.commentsManager.remove(model);
            end
        end

        function reinit(this)
            this.terminate();
            this.init();
        end

        function init(this)
            if~this.isInitialized
                this.perspectiveManager=simulink.designreview.PerspectiveManager();
                this.commentsManager=containers.Map('KeyType','char','ValueType','any');
                this.isInitialized=true;
            end
        end

        function terminate(this)
            if this.isInitialized
                this.perspectiveManager.clear();
                keys=this.commentsManager.keys;
                for idx=1:numel(keys)
                    this.getCommentsManager(keys{idx}).clear();
                    this.commentsManager.remove(keys{idx});
                end
                this.perspectiveManager=[];
                this.commentsManager=[];
                this.isInitialized=false;
            end
        end

    end

end
