classdef SpectrumAnalyzerView<dsp.webscopes.view.BaseWebScopeView&...
    dsp.webscopes.view.SpectrumAnalyzerViewController







    properties
        ScopeTitle="Spectrum Analyzer";
    end

    properties(Constant)
        ScopeName="SpectrumAnalyzer";
    end

    properties(Access=protected,Constant)
        ScopeIconFile=dsp.webscopes.view.SpectrumAnalyzerView.getIconFile();
    end



    methods(Hidden)

        function updateToolstrip(this,tabs)
            updateToolstripImpl(this,tabs);
        end

        function h=getScopeMessageHandler(this)
            h=this.ScopeMessageHandler;
        end

        function h=getScopeContainer(this)
            h=getContainer(this);
        end
    end



    methods(Access=protected)

        function buildToolstrip(this)
            container=getContainer(this);

            scopeTabGroup=createTabGroup(this,"Main",false);

            container.addTabGroup(scopeTabGroup);

            analyzerTab=dsp.webscopes.toolstrip.SpectrumAnalyzerAnalyzerTab;
            this.ScopeTabs=[this.ScopeTabs,analyzerTab];

            measurementsTab=dsp.webscopes.toolstrip.SpectrumAnalyzerMeasurementsTab;
            this.ScopeTabs=[this.ScopeTabs,measurementsTab];

            estimationTab=dsp.webscopes.toolstrip.SpectrumAnalyzerEstimationTab;
            this.ScopeTabs=[this.ScopeTabs,estimationTab];

            spectrumTab=dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrumTab;
            this.ScopeTabs=[this.ScopeTabs,spectrumTab];

            spectrogramTab=dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramTab;
            this.ScopeTabs=[this.ScopeTabs,spectrogramTab];

            scopeTabGroup.add(analyzerTab);
            scopeTabGroup.add(measurementsTab);
            scopeTabGroup.add(estimationTab);



            spectrumTabGroup=createTabGroup(this,"Spectrum",true);
            container.addTabGroup(spectrumTabGroup);
            spectrumTabGroup.add(spectrumTab);

            spectrogramTabGroup=createTabGroup(this,"Spectrogram",true);
            container.addTabGroup(spectrogramTabGroup);
            spectrogramTabGroup.add(spectrogramTab);

            this.setContexts(this.getContexts());

            this.setActiveContexts(this.getActiveContexts());
        end

        function buildDocuments(this)
            container=this.getContainer();

            scopeDocumentGroup=createDocumentGroup(this,"Axes");

            container.add(scopeDocumentGroup);

            figDocument=createFigureDocument(this,"Axes");
            this.addDocument(scopeDocumentGroup.Tag,figDocument);

            gridLayout=uigridlayout(getFigure(this),[1,1],...
            'Padding',[0,0,0,0]);
            this.ScopeUIHTMLWidget=uihtml(gridLayout,'HTMLSource',this.ScopeURL);
        end
    end



    methods(Access=protected)

        function contexts=getContexts(~)

            spectrumTabContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
            spectrumTabContext.Tag="spectrum";
            spectrumTabContext.ToolstripTabGroupTags="SpectrumAnalyzerSpectrumTabGroup";

            spectrogramTabContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
            spectrogramTabContext.Tag="spectrogram";
            spectrogramTabContext.ToolstripTabGroupTags="SpectrumAnalyzerSpectrogramTabGroup";
            contexts={spectrumTabContext,spectrogramTabContext};
        end

        function contexts=getActiveContexts(this)
            contexts=[];
            hSpec=this.ScopeMessageHandler.Specification;
            if(hSpec.ShowSpectrum)
                contexts=[contexts,"spectrum"];
            end
            if(hSpec.ShowSpectrogram)
                contexts=[contexts,"spectrogram"];
            end
        end
    end



    methods(Static)


        function iconFile=getIconFile(~)
            if ispc
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.ico');
            else
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.png');
            end
        end
    end
end
