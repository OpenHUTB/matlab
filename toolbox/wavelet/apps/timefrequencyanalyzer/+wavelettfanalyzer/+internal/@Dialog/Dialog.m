classdef Dialog<handle




    properties(Access=private)
App
AnalysisController
ExportController
ImportController
NewSessionController
    end

    events
StartNewSessionConfirmed
ImportSignalsOverwriteConfirmed
ExportScalogramOverwriteConfirmed
    end

    methods(Hidden)

        function this=Dialog(app)
            this.App=app;
        end

        function showAlert(this,title,message,varargin)
            if nargin<4
                uialert(this.App,message,title,"modal",true);
            else
                uialert(varargin{1},message,title,"modal",true);
            end
        end

        function confirm=showConfirm(this,actionID,title,message,varargin)
            if nargin<5
                uiconfirm(this.App,message,title,"Icon","warning","CloseFcn",@(~,args)this.closeConfirmCallback(args,actionID));
            else
                uiconfirm(varargin{1},message,title,"Icon","warning","CloseFcn",@(~,args)this.closeConfirmCallback(args,actionID,varargin{1}));
            end
            confirm=false;
        end

        function closeConfirmCallback(this,args,actionID,varargin)
            if strcmp(args.SelectedOption,"OK")
                switch actionID
                case "startNewSession"
                    this.notify("StartNewSessionConfirmed");
                case "importSignalsOverwrite"
                    args.figure=varargin{1};
                    this.notify("ImportSignalsOverwriteConfirmed",wavelettfanalyzer.internal.EventData(args));
                case "exportScalogramOverwrite"
                    this.notify("ExportScalogramOverwriteConfirmed");
                case "closeApp"
                    this.App.close("force",true);
                end
            end
        end
    end

    methods(Static,Hidden)
        function result=setGetDialog(value)
            mlock;
            persistent WaveletTFAnalyzerDialogInstance;
            if nargin
                WaveletTFAnalyzerDialogInstance=value;
            end
            result=WaveletTFAnalyzerDialogInstance;
        end
    end

end
