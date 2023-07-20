classdef EventHandler<handle




    events(NotifyAccess=?evolutions.internal.app.AppController,ListenAccess=public)

ModelEdited
Exception
    end

    events(NotifyAccess=?evolutions.internal.ui.tools.ToolstripApp,ListenAccess=public)

FocusChanged
    end


    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.ProjectSectionController,ListenAccess=public)

ProjectChanged
    end

    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.WorkingModelSectionController,ListenAccess=public)

WorkingModelChanged
    end

    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.ProfileSectionController,ListenAccess=public)

StereotypeChanged
    end

    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.EvolutionsSectionController,ListenAccess=public)

WebViewCreated
    end

    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.EvolutionsSectionController,ListenAccess=public)


EvolutionChanged
EvolutionCreated
    end

    events(NotifyAccess=?evolutions.internal.app.toolstrip.manage.CompareSectionController,ListenAccess=public)

ComparisonPerformed
MetricsComparisonPerformed
    end


    events(NotifyAccess=?evolutions.internal.app.model.EvolutionsTreeManager,ListenAccess=public)

TreeSelectionChanged
    end

    events(NotifyAccess=?evolutions.internal.app.model.CompareManager,ListenAccess=public)
SelectedEdgeChanged
    end

    events(NotifyAccess=?evolutions.internal.app.panel.PropertyInspector.FileListController,ListenAccess=public)

FileListSelectionChanged
FileSelectionValueChanged
    end

    events(NotifyAccess=?evolutions.internal.ui.tools.FileListener,ListenAccess=public)

FileOnDiskChange
    end


    events(NotifyAccess=?evolutions.internal.app.AppModel,ListenAccess=public)
AppModelChanged
    end

    events(NotifyAccess=?evolutions.internal.app.model.EvolutionsTreeManager,ListenAccess=public)
DataChange
    end

    events(NotifyAccess=?evolutions.internal.app.model.FileListManager,ListenAccess=public)
FileListChanged
ButtonStatesChanged
    end

    events(NotifyAccess=?evolutions.internal.app.model.ProjectReferenceListManager,ListenAccess=public)
ProjectReferenceListManagerChanged
RootProjectSelectionChanged
    end

    events(NotifyAccess=?evolutions.internal.app.model.EvolutionTreeListManager,ListenAccess=public)
EvolutionTreeListManagerChanged
EvolutionTreeSelectionChanged
    end

    events(NotifyAccess=?evolutions.internal.app.model.EvolutionsTreeManager,ListenAccess=public)
EvolutionsTreeManagerChanged
NewEvolutionCreated
    end

    events(NotifyAccess=?evolutions.internal.app.document.EvolutionTreeWebDocument.EvolutionWebPlotController,ListenAccess=public)
ActiveEvolutionChanged
NodeClicked
CanvasClicked
EdgeClicked
EdgeSelectionChanged
    end


    events(NotifyAccess=?evolutions.internal.app.panel.PropertyInspector.EvolutionInfoController,ListenAccess=public)

EvolutionNameChanged
    end

    events(NotifyAccess=?evolutions.internal.app.panel.PropertyInspector.EvolutionTreeInfoController,ListenAccess=public)

EvolutionTreeNameChanged
    end

    events(NotifyAccess=?evolutions.internal.app.document.EvolutionDocument...
        .ComparisonController,ListenAccess=public)

CompareFileSelectionChanged
    end

    events(NotifyAccess=?evolutions.internal.ui.tools.StateController,ListenAccess=public)

StateChanged
    end

    methods(Access=?evolutions.internal.app.AppController)
        function obj=EventHandler

        end
    end
end


