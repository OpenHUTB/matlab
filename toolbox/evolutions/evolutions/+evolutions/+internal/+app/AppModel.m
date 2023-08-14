classdef AppModel<handle




    properties(SetAccess=protected)
EventHandler
CacheManager
ProjectInterface
    end

    properties(SetAccess=protected)
ProjectReferenceListManager
EvolutionTreeListManager
FileListManager
EvolutionsTreeManager
EvolutionsTreeSummaryManager
EvolutionsSummaryManager
FileSummaryManager
CommentManager
CompareManager
    end

    methods
        function this=AppModel(appController)
            this.EventHandler=appController.EventHandler;
            this.ProjectInterface=appController.ProjectInterface;
            this.CacheManager=appController.CacheManager;
            createSubModel(this);
        end

        function updateModel(this)
            updateSubModel(this);
            notify(this.EventHandler,'AppModelChanged');
        end

        function createSubModel(this)

            this.ProjectReferenceListManager=evolutions.internal.app.model.ProjectReferenceListManager(this);
            this.EvolutionTreeListManager=evolutions.internal.app.model.EvolutionTreeListManager(this);
            this.EvolutionsTreeManager=evolutions.internal.app.model.EvolutionsTreeManager(this);
            this.FileListManager=evolutions.internal.app.model.FileListManager(this);
            this.EvolutionsTreeSummaryManager=evolutions.internal.app.model.EvolutionsTreeSummaryManager(this);
            this.EvolutionsSummaryManager=evolutions.internal.app.model.EvolutionsSummaryManager(this);
            this.FileSummaryManager=evolutions.internal.app.model.FileSummaryManager(this);
            this.CompareManager=evolutions.internal.app.model.CompareManager(this);
        end

        function updateSubModel(this)

            this.EvolutionsTreeManager.update;
            this.FileListManager.update;
            this.EvolutionsTreeSummaryManager.update;
            this.EvolutionsSummaryManager.updateEvolutionSummary;
            this.FileSummaryManager.updateFileSummary;
            this.CompareManager.update;
        end

        function delete(this)
            props=["FileListManager",...
            "EvolutionsTreeManager",...
            "EvolutionsSummaryManager",...
            "FileSummaryManager",...
            "CommentManager",...
            "EvolutionTreeListManager",...
            "ProjectReferenceListManager",...
            "CompareManager"];
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function m=getSubModel(this,type)
            switch type
            case 'EvolutionsTreeManager'
                m=this.EvolutionsTreeManager;
            case 'EvolutionTreeSummary'
                m=this.EvolutionsTreeSummaryManager;
            case 'EvolutionSummary'
                m=this.EvolutionsSummaryManager;
            case 'FileSummary'
                m=this.FileSummaryManager;
            case 'CommentSummary'
                m=this.CommentManager;
            case 'Compare'
                m=this.CompareManager;
            case 'FileList'
                m=this.FileListManager;
            case 'ProjectReferenceListManager'
                m=this.ProjectReferenceListManager;
            otherwise
                assert(strcmp(type,'EvolutionTreeListManager'));
                m=this.EvolutionTreeListManager;
            end
        end

    end

end
