classdef TreeViewSectionController<evolutions.internal.ui.tools.ToolstripSectionController




    properties(Hidden,SetAccess=immutable)

AppModel
AppController

TreeViewSectionView
TreePlotView

EventHandler

StateController
    end

    properties(SetAccess=protected)
    end

    properties(SetAccess=protected)

ChangeLayoutButtonClickListener
StateListener
    end

    methods
        function this=TreeViewSectionController(appController,view)

            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.TreeViewSectionView=getSubView(appController,view);
            treeDocument=getSubView(appController,'EvolutionTreeDocument');
            this.TreePlotView=treeDocument.EvolutionPlotView;
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;


            updateWidgetStates(this);
        end

        function updateWidgetStates(this)
            view=this.TreeViewSectionView;
            state=this.StateController;
            enableWidget(view,state.TreeViewButton,'Fit');
            enableWidget(view,state.TreeViewButton,'FullFit');
            enableWidget(view,state.TreeViewButton,'ZoomIn');
            enableWidget(view,state.TreeViewButton,'ZoomOut');
        end

        function delete(this)
            deleteListeners(this);
        end
    end


    methods(Access=protected)
        function deleteListeners(this)
            listeners="StateListener";
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function updateView(~)

        end

        function installModelListeners(~)
        end

        function installViewListeners(this)

            view=this.TreeViewSectionView;

            view.FitButton.ButtonPushedFcn=@this.fitButtonClick;
            view.FullFitButton.ButtonPushedFcn=@this.fullFitButtonClick;
            view.ZoomInButton.ButtonPushedFcn=@this.zoomInButtonClick;
            view.ZoomOutButton.ButtonPushedFcn=@this.zoomOutButtonClick;
            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);
        end
    end


    methods(Hidden,Access=protected)
        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end

        function fitButtonClick(this,~,~)
            this.logButtonClickEvent("Fit");
            this.TreePlotView.Editor.getCanvas().fitToView();
        end

        function fullFitButtonClick(this,~,~)
            this.logButtonClickEvent("FullFit");
            this.TreePlotView.Editor.getCanvas()...
            .scrollToView({this.TreePlotView.Syntax.root.entities.uuid});
        end

        function zoomInButtonClick(this,~,~)
            this.logButtonClickEvent("ZoomIn");
            this.TreePlotView.Editor.getCanvas().zoomIn();
        end

        function zoomOutButtonClick(this,~,~)
            this.logButtonClickEvent("ZoomOut");
            this.TreePlotView.Editor.getCanvas().zoomOut();
        end
    end

end


