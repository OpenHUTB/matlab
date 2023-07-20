

classdef signalMultiresolutionAnalyzerImpl<handle



    properties(Access=private)
Dispatcher
MainModel
MainViewModel
MainController
WebscopesStreamingSource
ClientID
WebGUI
    end

    methods(Hidden)
        function this=signalMultiresolutionAnalyzerImpl(varargin)

            inputSignal={};
            isDebug=false;
            isOpenInBrowser=false;
            if nargin>=2&&~isfield(varargin{end},"isDebug")&&~isfield(varargin{end},"isOpenInBrowser")

                narginchk(0,2);
                nargoutchk(0,2);
                validateattributes(varargin{end},...
                {'double','single'},{'real','nonnan','finite','vector'},...
                'signalMultiresolutionAnalyzer','signal');


                if(numel(varargin{end})<2)
                    error(message('Wavelet:modwt:LenTwo'));
                end

                inputSignal=flip(varargin);
            elseif nargin==3

                inputSignal=flip(varargin(1:2));
            end

            if nargin

                if isfield(varargin{end},"isDebug")&&islogical(varargin{end}.isDebug)
                    narginchk(0,3);
                    nargoutchk(0,3);
                    isDebug=varargin{end}.isDebug;
                end


                if isfield(varargin{end},"isOpenInBrowser")&&islogical(varargin{end}.isOpenInBrowser)
                    narginchk(0,3);
                    nargoutchk(0,3);
                    isOpenInBrowser=varargin{end}.isOpenInBrowser;
                end
            end

            this.WebscopesStreamingSource=sigwebappsutils.internal.webscopes.WebscopesStreamingSource();

            signalMgr=sigwebappsutils.internal.SignalMgr(this.WebscopesStreamingSource);
            signalPlotter=mra.internal.SignalPlotter(this.WebscopesStreamingSource);

            this.MainModel=mra.internal.models.MainModel(signalMgr,inputSignal);

            this.ClientID=this.WebscopesStreamingSource.getClientID();
            channel=this.getChannel(this.ClientID);
            this.Dispatcher=sigwebappsutils.internal.Dispatcher(channel);

            this.MainController=mra.internal.controllers.MainController(this.MainModel,this.Dispatcher);

            this.MainViewModel=mra.internal.viewModels.MainViewModel(this.MainController,this.Dispatcher,signalPlotter);

            webPageHTML='toolbox/wavelet/apps/mra/signalMultiresolutionAnalyzer';
            this.WebGUI=sigwebappsutils.internal.WebGUI(webPageHTML,isDebug,isOpenInBrowser,this.ClientID);
            if~isempty(this.WebGUI.AppContainer)

                addlistener(this.WebGUI.AppContainer,'StateChanged',@(src,data)handleAppStateChange(this));
            end
            this.WebGUI.open();
            this.WebGUI.AppContainer.Title=...
            string(getString(message('wavelet_mraapp:mra:appTitle')));
        end

        function channel=getChannel(~,clientID)
            channel="/mra/"+clientID;
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