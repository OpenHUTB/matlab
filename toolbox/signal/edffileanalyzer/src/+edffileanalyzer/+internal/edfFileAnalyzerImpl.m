

classdef edfFileAnalyzerImpl<handle



    properties(Access=private)
Dispatcher
MainModel
MainViewModel
MainController
WebscopesStreamingSource
WebGUI
ClientID
    end

    methods
        function this=edfFileAnalyzerImpl(varargin)

            inputSignal={};
            isDebug=false;
            isOpenInBrowser=false;
            if nargin&&~isfield(varargin{end},"isDebug")&&~isfield(varargin{end},"isOpenInBrowser")

                narginchk(0,1);
                nargoutchk(0,1);
                [~,~,extension]=fileparts(varargin{1});
                if~strcmpi(extension,".edf")
                    error(message("signal_edffileanalyzer:edffileanalyzer:invalidExtension"));
                end
                if exist(varargin{1},"file")~=2
                    error(message("signal_edffileanalyzer:edffileanalyzer:invalidFileName"));
                end
                inputSignal=varargin{1};
            elseif nargin==2

                inputSignal=varargin{1};
                [~,~,extension]=fileparts(varargin{1});
                if~strcmpi(extension,".edf")
                    error(message("signal_edffileanalyzer:edffileanalyzer:invalidExtension"));
                end
                if exist(varargin{1},"file")~=2
                    error(message("signal_edffileanalyzer:edffileanalyzer:invalidFileName"));
                end
            end

            if nargin

                if isfield(varargin{end},"isDebug")&&islogical(varargin{end}.isDebug)
                    narginchk(0,2);
                    nargoutchk(0,2);
                    isDebug=varargin{end}.isDebug;
                end


                if isfield(varargin{end},"isOpenInBrowser")&&islogical(varargin{end}.isOpenInBrowser)
                    narginchk(0,2);
                    nargoutchk(0,2);
                    isOpenInBrowser=varargin{end}.isOpenInBrowser;
                end
            end

            this.WebscopesStreamingSource=sigwebappsutils.internal.webscopes.WebscopesStreamingSource();
            signalPlotter=sigwebappsutils.internal.SignalPlotter(this.WebscopesStreamingSource);
            signalMgr=sigwebappsutils.internal.SignalMgr(this.WebscopesStreamingSource);

            this.MainModel=edffileanalyzer.internal.models.MainModel(signalMgr,inputSignal);

            this.ClientID=this.WebscopesStreamingSource.getClientID();
            channel=this.getChannel(this.ClientID);
            this.Dispatcher=sigwebappsutils.internal.Dispatcher(channel);

            this.MainController=edffileanalyzer.internal.controllers.MainController(this.MainModel,this.Dispatcher);

            this.MainViewModel=edffileanalyzer.internal.viewModels.MainViewModel(this.MainController,this.Dispatcher,signalPlotter);

            webPageHTML='toolbox/signal/edffileanalyzer/edfFileAnalyzer';
            this.WebGUI=sigwebappsutils.internal.WebGUI(webPageHTML,isDebug,isOpenInBrowser,this.ClientID);
            if~isempty(this.WebGUI.AppContainer)

                addlistener(this.WebGUI.AppContainer,'StateChanged',@(src,data)handleAppStateChange(this));
            end
            this.WebGUI.open();



            this.WebGUI.AppContainer.Title=...
            string(getString(message('signal_edffileanalyzer:edffileanalyzer:appTitle')));
        end
    end

    methods(Hidden)
        function channel=getChannel(~,clientID)
            channel="/edffileanalyzer/"+clientID;
        end

        function handleAppStateChange(this)

            import matlab.ui.container.internal.appcontainer.AppState;

            if this.WebGUI.AppContainer.State==AppState.TERMINATED
                this.deleteThis();
            end
        end

        function deleteThis(this)

            delete(this.Dispatcher);
            delete(this.MainModel);
            delete(this.MainViewModel);
            delete(this.MainController);
            delete(this.WebscopesStreamingSource);
            delete(this.WebGUI);
        end
    end
end