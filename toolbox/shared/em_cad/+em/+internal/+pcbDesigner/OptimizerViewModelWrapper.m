classdef OptimizerViewModelWrapper<handle
    properties
        ViewStruct em.internal.ViewStruct;
        ModelStruct=struct('SelectorObject',[],...
        'MainObject',dipole);
ProgressBar
StatusBar
StatusLabel

    end

    methods
        function viewstruct=generateViewStruct(self,appHandle,appContainerHandle,tabGroupHandle,plotFrequencyEditField,...
            frequencyRangeEditField,plotFrequencyDropDown,...
            frequencyRangeDropDown,propertyPanelHandle)

            self.ViewStruct=em.internal.ViewStruct;
            self.ViewStruct.AppContainer=appContainerHandle;
            self.ViewStruct.TabGroup=tabGroupHandle;
            self.ViewStruct.PlotFrequencyEditField=plotFrequencyEditField;
            self.ViewStruct.FrequencyRangeEditField=frequencyRangeEditField;
            self.ViewStruct.PlotFrequencyUnitDropdown=plotFrequencyDropDown;
            self.ViewStruct.FrequencyRangeUnitDropdown=frequencyRangeDropDown;
            self.ViewStruct.PropertyPanel=propertyPanelHandle;
            self.ViewStruct.DocumentGroupTag="CanvasGroup";
            self.ViewStruct.AppHandle=appHandle;
            self.ViewStruct.ProgressBar=self.ProgressBar;
            viewstruct=self.ViewStruct;
        end

        function modelStruct=generateModelStruct(self,antennaObject)

            self.ModelStruct=em.internal.ModelStruct(em.internal.SelectorObject,antennaObject);
            modelStruct=self.ModelStruct;
        end

        function openOptimizer(self)
            em.internal.optimizationTab.Optimizer(self.ViewStruct,self.ModelStruct);
        end

        function addProgressBar(self,appHandle)
            import matlab.ui.internal.toolstrip.*
            self.StatusBar=matlab.ui.internal.statusbar.StatusBar();
            self.StatusBar.Tag="statusBar";
            self.StatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            self.StatusLabel.Tag="statusLabel";
            self.StatusLabel.Text="";
            self.StatusLabel.Description=getString(message("antenna:antennadesigner:StatusBarDescription"));
            self.ProgressBar=matlab.ui.internal.statusbar.StatusProgressBar();
            self.ProgressBar.Tag='progressBar';
            self.ProgressBar.Region='right';
            appHandle.add(self.ProgressBar);
            self.StatusBar.add(self.StatusLabel);
            appHandle.add(self.StatusBar);


            ProgressBarContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
            ProgressBarContext.Tag='progressBarContext';
            ProgressBarContext.StatusComponentTags='progressBar';
            appHandle.Contexts={ProgressBarContext};












        end
    end

    methods(Hidden)
        function rtn=qeOptimizerModel(self)
            rtn=self.ViewStruct.OptimizerView.Model;
        end

        function rtn=qeMainObject(self)
            rtn=self.ModelStruct.MainObject;
        end

        function rtn=qeOptimizerView(self)
            rtn=self.ViewStruct.OptimizerView;
        end
    end
end