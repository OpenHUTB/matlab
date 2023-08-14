classdef SpectrumAnalyzerContainerView<matlabshared.scopes.container.SystemObjectScopeComponent&...
    dsp.webscopes.view.SpectrumAnalyzerViewController











    methods

        function this=SpectrumAnalyzerContainerView(app,scope,varargin)
            this@matlabshared.scopes.container.SystemObjectScopeComponent(app,scope,varargin{:});
        end
    end



    methods(Hidden)




        function processSectionEvent(this,ev)


            import matlab.ui.container.internal.appcontainer.*;
            container=getScopeContainer(this);
            if container.State~=AppState.RUNNING
                return;
            end
            processSectionEventImpl(this,ev);
        end

        function updateToolstrip(this,tabs)
            import matlab.ui.container.internal.appcontainer.*;
            msg=getScopeMessageHandler(this);
            if isempty(msg)



                return;
            end


            container=getScopeContainer(this);
            if container.State~=AppState.RUNNING
                return;
            end
            updateToolstripImpl(this,tabs);
        end

        function tabs=getDynamicTabs(this)
            tabs=[];
            if this.MessageHandler.Specification.HasToolstrip
                names={'dsp.webscopes.toolstrip.SpectrumAnalyzerAnalyzerTab',...
                'dsp.webscopes.toolstrip.SpectrumAnalyzerEstimationTab',...
                'dsp.webscopes.toolstrip.SpectrumAnalyzerMeasurementsTab'};
                spec=this.MessageHandler.Specification;
                if spec.ShowSpectrum
                    names=[names,{'dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrumTab'}];
                end
                if spec.ShowSpectrogram
                    names=[names,{'dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramTab'}];
                end
                tabs=this.Application.getTab(names{:});
            end
        end

        function h=getScopeMessageHandler(this)
            h=this.MessageHandler;
        end

        function h=getScopeContainer(this)
            h=this.Application.Window.AppContainer;
        end

        function tag=getDocumentGroupTag(~)
            tag='Scopes';
        end
    end



    methods(Access=protected)
        function f=createFigure(this,varargin)
            f=[];
            module=getSharedDSPWebScopesModule;
            entryPoint='mlSpectrumAnalyzer';
            spec=getScopeMessageHandler(this).Specification;
            jsDocument=matlabshared.scopes.container.ScopeDocument(this,module,entryPoint,...
            struct('hasToolstrip',spec.HasToolstrip,...
            'hasStatusbar',spec.HasStatusbar,...
            'showScreenMessages',spec.ShowScreenMessages));
            this.Document=jsDocument;
            this.Application.addDocument(jsDocument);
        end
    end
end
