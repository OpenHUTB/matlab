classdef ApplicationTree<handle






    properties
App
        Tree matlab.ui.container.Tree
        GridLayout matlab.ui.container.GridLayout
    end


    methods
        function this=ApplicationTree(hApp)
            this.App=hApp;


            this.GridLayout=uigridlayout(this.App.ApplicationTreePanel.Figure);
            this.GridLayout.ColumnWidth={'1x'};
            this.GridLayout.RowHeight={'1x'};

            this.Tree=uitree(this.GridLayout);
            this.Tree.Layout.Row=1;
            this.Tree.Layout.Column=1;
            this.Tree.SelectionChangedFcn=@this.ApplicationTreeSelectionChanged;

        end

        function disable(this)
            if~isempty(this.Tree.Children)
                this.Tree.Children(1).Parent=[];
            end
            this.Tree.Enable='off';

        end

    end

    methods(Access=private)



        function ApplicationTreeSelectionChanged(this,Tree,event)
            this.App.UpdateApp.ForTargetApplicationFilterButton();
            this.App.UpdateApp.ForTargetApplicationSignalsFilterContents();
            this.App.UpdateApp.ForTargetApplicationParametersFilterContents();
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            this.App.UpdateApp.ForTargetApplicationSignals(selectedTargetName);
            this.App.UpdateApp.ForTargetApplicationParameters(selectedTargetName);
        end
    end

end
