

classdef AppState<handle

    properties(Access=private)
        signalAnalyzerClientID;
        IsShowVarOverwriteDialog=true;
        ModeName='';
    end

    properties(Constant)
        ControllerID='AppState';
    end


    methods(Static)
        function ret=getController(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                ctrlObj=signal.analyzer.controllers.AppState();
            end

            ret=ctrlObj;
        end
    end


    methods(Access=protected)

        function this=AppState()

        end
    end


    methods(Hidden)


        function setSignalAnalyzerClientID(this,val)
            this.signalAnalyzerClientID=string(val);
        end

        function clientID=getSignalAnalyzerClientID(this)
            clientID=this.signalAnalyzerClientID;
        end


        function setIsShowVarOverwriteDialog(this,flag)
            this.IsShowVarOverwriteDialog=flag;
        end

        function flag=isShowVarOverwriteDialog(this)
            flag=this.IsShowVarOverwriteDialog;
        end


        function setModeName(this,value)
            this.ModeName=value;
        end


        function flag=isPreprocessingModeSA(this)
            flag=this.ModeName=="preprocessingMode";
        end


        function setSignalAnalyzerActiveAppFlag(~,flag)
            if~signal.analyzer.WebGUI.includeLabeler()
                return;
            end
            labelerViewModel=signal.labeler.viewmodels.LabelViewModel.getViewModel();
            labelerViewModel.setSignalLabelerActiveAppFlag(~flag);




            if flag&&signal.analyzer.Instance.isSDIRunning()
                gui=signal.analyzer.Instance.gui();
                gui.updateSessionInfo();
            end
        end


        function flag=getSignalAnalyzerActiveAppFlag(~)
            if~signal.analyzer.WebGUI.includeLabeler()
                flag=true;
                return;
            end
            labelerViewModel=signal.labeler.viewmodels.LabelViewModel.getViewModel();
            flag=~labelerViewModel.getSignalLabelerActiveAppFlag();
        end
    end
end


