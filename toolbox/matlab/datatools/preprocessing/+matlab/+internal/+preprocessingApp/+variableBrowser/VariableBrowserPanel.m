classdef VariableBrowserPanel<matlab.internal.preprocessingApp.base.PreprocessingPanel





    properties
VariablePanelSelectionChangedFcn
VariablePanelUserInteractionCallFcn
    end

    properties(Access={?matlab.uitest.TestCase,?matlab.unittest.TestCase})
        VariableBrowserComponent matlab.internal.preprocessingApp.variableBrowser.VariableBrowserComponent;
        Grid matlab.ui.container.GridLayout
DisableLabel
    end

    properties(Dependent)
SelectedVariables
Interactive
    end

    methods
        function this=VariableBrowserPanel(varargin)
            this@matlab.internal.preprocessingApp.base.PreprocessingPanel(varargin{:});
            this.setup();
        end

        function setup(this)
            this.Grid=uigridlayout(this.Figure,[2,1],'ColumnWidth',{'1x'},'RowHeight',{'1x'});
            this.Grid.RowHeight={0,'1x'};
            this.VariableBrowserComponent=matlab.internal.preprocessingApp.variableBrowser.VariableBrowserComponent(this.Grid);
            this.VariableBrowserComponent.Layout.Row=2;
            this.VariableBrowserComponent.Layout.Column=1;
            this.Grid.Padding=[0,0,0,0];
            this.DisableLabel=uilabel(this.Grid);
            this.DisableLabel.Text=...
            getString(message('MATLAB:datatools:preprocessing:variableBrowser:variableBrowser:DISABLE_TEXT'));
            this.DisableLabel.WordWrap='on';
            this.DisableLabel.BackgroundColor='#E6F6FE';
            this.DisableLabel.Layout.Row=1;
            this.DisableLabel.Layout.Column=1;
            this.addListeners();
        end

        function addListeners(this)
            this.VariableBrowserComponent.VariableSelectionChangedFcn=@(srcObject,eventData)this.selectionChanged(srcObject,eventData);
            this.VariableBrowserComponent.UserInteractionCallFcn=@(codeObj)this.notifyAppOfInteraction(codeObj);

        end

        function addData(this,data,varName)
            this.VariableBrowserComponent.addData(data,varName);
        end

        function showDisableLabel(this)
            this.Grid.RowHeight{1}=40;
            this.Interactive=0;
        end

        function hideDisableLabel(this)
            this.Grid.RowHeight{1}=0;
            this.Interactive=1;
        end

        function removeData(this,varName)
            this.VariableBrowserComponent.removeData(varName);
        end

        function setSelection(this,selection)
            this.VariableBrowserComponent.SelectedVariables=selection;
        end

        function selectedVariables=getSelection(this)
            selectedVariables=this.VariableBrowserComponent.SelectedVariables;
        end

        function selectionChanged(this,~,eventData)
            if~isempty(this.VariablePanelSelectionChangedFcn)
                try
                    this.VariablePanelSelectionChangedFcn(this,eventData);
                catch e
                    disp(e);
                end
            end
        end

        function tableName=getTableName(this)
            tableName=this.VariableBrowserComponent.getTableName();
        end

        function notifyAppOfInteraction(this,codeObj)
            if~isempty(this.VariablePanelUserInteractionCallFcn)
                try
                    this.VariablePanelUserInteractionCallFcn(codeObj);
                catch e
                    disp(e);
                end
            end
        end

        function value=get.SelectedVariables(this)
            value=this.VariableBrowserComponent.SelectedVariables;
        end

        function value=get.Interactive(this)
            value=this.VariableBrowserComponent.Interactive;
        end

        function set.Interactive(this,val)
            this.VariableBrowserComponent.Interactive=val;
        end

        function enableUpdateInteractions()
        end

        function disableUpdateInteractions()
        end
    end
end

