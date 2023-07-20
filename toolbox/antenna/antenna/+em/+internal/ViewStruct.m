classdef ViewStruct<handle



    properties
        AppContainer=[]
        Title='Demo App'
        Tag='demoApp'
        SelectedTab='designerTab'
        DocumentOptions=struct()
        FrequencyRangeEditField=[]
        PlotFrequencyEditField=[]
        FrequencyRangeUnitDropdown=[]
        PlotFrequencyUnitDropdown=[]
        TabGroup=[]
        DesignerTab=[]
        UseAppContainer=true;
        PropertyPanel=[]
        StatusBar=[]
        StatusLabel=[]
        ProgressBar=[]
OptimizerView
CanBeClosed
        DocumentGroupTag=[];
AppHandle
    end

    methods
        function obj=ViewStruct()


        end

        function setStatusBarMsg(obj,message)


            obj.StatusLabel.Text=message;
        end

        function initStatusBar(obj)

            obj.StatusBar=matlab.ui.internal.statusbar.StatusBar();
            obj.StatusBar.Tag="statusBar";
            obj.StatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            obj.StatusLabel.Tag="statusLabel";
            obj.StatusLabel.Text="";
            obj.StatusLabel.Description=getString(message("antenna:antennadesigner:StatusBarDescription"));
            obj.ProgressBar=matlab.ui.internal.statusbar.StatusProgressBar();
            obj.ProgressBar.Tag='progressBar';
            obj.ProgressBar.Region='right';


            ProgressBarContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
            ProgressBarContext.Tag='progressBarContext';
            ProgressBarContext.StatusComponentTags='progressBar';
            obj.AppContainer.Contexts={ProgressBarContext};
            obj.AppContainer.add(obj.ProgressBar);
            obj.StatusBar.add(obj.StatusLabel);
            obj.AppContainer.add(obj.StatusBar);
        end

        function updateDocuments(self,args)
            if strcmpi(args,'DesignerTab')
                removeDocumentsForOptimization(self);
                resetView(self);
            end

        end

        function resetView(self)
            self.AppHandle.resetView();
        end

        function updateModel(self)
            updateModel(self.AppHandle);
        end

        function removeDocumentsForOptimization(self)

            self.TabGroup.remove(self.OptimizerView.OptimizerTab);
            self.AppHandle.App.removePanel("OptimizationDesignVariables")
            self.AppHandle.App.removePanel("Constraints")
            close(self.OptimizerView.ResultsPlots.Figure);
        end

    end
end

