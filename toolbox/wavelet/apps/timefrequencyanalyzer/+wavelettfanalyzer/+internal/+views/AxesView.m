classdef AxesView<handle




    properties(Access=private)
AnalysisController
ImportController
NewSessionController
TableController
Document
GridLayout
PlotInfo
CurrentSignalName
    end

    methods(Hidden)

        function this=AxesView(app,controllers)
            this.AnalysisController=controllers.analysisController;
            this.ImportController=controllers.importController;
            this.NewSessionController=controllers.newSessionController;
            this.TableController=controllers.tableController;
            this.addAxes(app);
            this.subscribeToControllerEvents();
            this.PlotInfo=containers.Map;
        end
    end

    methods(Access=private)
        function subscribeToControllerEvents(this)
            addlistener(this.AnalysisController,"UpdateBoundaryLine",@(~,args)this.cb_UpdateBoundaryLine(args));
            addlistener(this.AnalysisController,"UpdateShadeRegion",@(~,args)this.cb_UpdateShadeRegion(args));
            addlistener(this.AnalysisController,"UpdatePlot",@(~,args)this.cb_UpdatePlot(args));
            addlistener(this.AnalysisController,"CalculateAxes",@(~,args)this.cb_CalculateAxes(args));
            addlistener(this.AnalysisController,"CalculateAxesAndUpdatePlot",@(~,args)this.cb_CalculateAxesAndUpdatePlot(args));
            addlistener(this.AnalysisController,"RenameAxes",@(~,args)this.cb_RenameAxes(args));
            addlistener(this.AnalysisController,"DuplicateAxes",@(~,args)this.cb_DuplicateAxes(args));
            addlistener(this.ImportController,"CalculateAxes",@(~,args)this.cb_CalculateAxes(args));
            addlistener(this.ImportController,"UpdatePlot",@(~,args)this.cb_UpdatePlot(args));
            addlistener(this.NewSessionController,"ClearAxes",@(~,~)this.cb_ClearAxes());
            addlistener(this.TableController,"UpdatePlot",@(~,args)this.cb_UpdatePlot(args));
            addlistener(this.TableController,"ClearAxes",@(~,args)this.cb_ClearAxes());
            addlistener(this.TableController,"CalculateAxesAndUpdatePlot",@(~,args)this.cb_CalculateAxesAndUpdatePlot(args));
        end


        function cb_ClearAxes(this)
            this.deparentAxes();
            this.PlotInfo=containers.Map;
            this.CurrentSignalName=[];
            this.Document.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:plotLabel")));
        end

        function cb_CalculateAxes(this,args)
            this.deparentAxes();
            this.calculateAxes(args.Data);
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
        end

        function cb_UpdateBoundaryLine(this,args)
            info=this.PlotInfo(this.CurrentSignalName);
            info.oneplot.boundaryLine.Visible=args.Data.value;
            if isfield(info,"separate")
                info.separate.boundaryLine(1).Visible=args.Data.value;
                info.separate.boundaryLine(2).Visible=args.Data.value;
            end
        end

        function cb_UpdateShadeRegion(this,args)
            info=this.PlotInfo(this.CurrentSignalName);
            info.oneplot.region.Visible=args.Data.value;
            if isfield(info,"separate")
                info.separate.region(1).Visible=args.Data.value;
                info.separate.region(2).Visible=args.Data.value;
            end
        end

        function cb_UpdatePlot(this,args)
            this.deparentAxes();
            this.updatePlot(args.Data);
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
        end

        function cb_CalculateAxesAndUpdatePlot(this,args)
            this.deparentAxes();
            this.calculateAxes(args.Data.calculateAxesData);
            this.updatePlot(args.Data.updatePlotData);
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
        end

        function cb_RenameAxes(this,args)
            oldName=args.Data.oldName;
            newName=args.Data.newName;
            info=this.PlotInfo(oldName);
            this.PlotInfo.remove(oldName);
            this.PlotInfo(newName)=info;
            this.CurrentSignalName=newName;
            this.Document.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:scalogramLabel")))+"-"+newName;
        end

        function cb_DuplicateAxes(this,args)
            info=this.PlotInfo(args.Data.originalName);
            this.PlotInfo(args.Data.duplicateName)=info;
        end


        function deparentAxes(this)
            if~isempty(this.CurrentSignalName)
                info=this.PlotInfo(this.CurrentSignalName);

                if isfield(info,"separate")
                    for idx=1:length(info.separate.axis)
                        info.separate.axis(idx).Visible=false;
                        info.separate.axis(idx).Parent=[];
                    end
                end

                info.oneplot.axis.Visible=false;
                info.oneplot.axis.Parent=[];
            end
        end

        function calculateAxes(this,args)
            name=args.name;
            scalogram=args.scalogram;
            frequency=args.adjustedFrequency;
            time=args.time;
            isNormFreq=args.isNormFreq;
            sampleRate=args.sampleRate;
            isComplex=args.isComplex;
            waveletName=args.waveletName;
            morseParams=args.morseParams;

            if isNormFreq
                sampleRate=[];
            end

            if isComplex

                [axis,surface,line,area]=wavelet.internal.cwt.plotScalogram(scalogram,frequency,time,...
                "normfreqflag",isNormFreq,"SampleRate",sampleRate,"ComplexPlot","separate","wavelet",waveletName,"ga",morseParams(1),"be",morseParams(2)/morseParams(1));
                for idx=1:length(axis)
                    axtoolbar(axis(idx),{'export','pan','datacursor','zoomin','zoomout','restoreview'});
                end
                this.addColorbar(axis);
                this.addDatetick(axis,time);
                separate.axis=axis;
                separate.surface=surface;
                separate.boundaryLine=line;
                separate.region=area;
                info.separate=separate;


                [axis,surface]=wavelet.internal.cwt.plotScalogram(scalogram,frequency,time,...
                "normfreqflag",isNormFreq,"SampleRate",sampleRate,"ComplexPlot","oneplot","wavelet",waveletName,"ga",morseParams(1),"be",morseParams(2)/morseParams(1));
                axis.YScale="linear";
                axtoolbar(axis,{'export','pan','datacursor','zoomin','zoomout','restoreview'});
                this.addColorbar(axis);
                this.addDatetick(axis,time);
                oneplot.axis=axis;
                oneplot.surface=surface;
                info.oneplot=oneplot;
                this.PlotInfo(name)=info;
            else

                [axis,surface,line,area]=wavelet.internal.cwt.plotScalogram(scalogram,frequency,time,...
                "normfreqflag",isNormFreq,"SampleRate",sampleRate,"wavelet",waveletName,"ga",morseParams(1),"be",morseParams(2)/morseParams(1));
                axtoolbar(axis,{'export','pan','datacursor','zoomin','zoomout','restoreview'});
                this.addColorbar(axis);
                this.addDatetick(axis,time);
                oneplot.axis=axis;
                oneplot.surface=surface;
                oneplot.boundaryLine=line;
                oneplot.region=area;
                info.oneplot=oneplot;
                this.PlotInfo(name)=info;
            end
        end

        function addColorbar(this,axis)
            for idx=1:length(axis)
                axis(idx).Parent=this.Document.Figure;
                cb=colorbar("peer",axis(idx));
                cb.ContextMenu=[];
                cb.Label.String=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:colorbarLabel")));
                axis(idx).Parent=[];
            end
        end

        function addDatetick(this,axis,time)
            for idx=1:length(axis)
                axis(idx).Parent=this.Document.Figure;
                if isdatetime(time)
                    datetick(axis(idx),'x','keeplimits');
                end
                axis(idx).Parent=[];
            end
        end

        function updatePlot(this,args)
            name=args.name;
            isComplex=args.isComplex;
            separatePlots=args.separatePlots;
            boundaryLine=args.boundaryLine;
            shadeRegion=args.shadeRegion;

            this.CurrentSignalName=name;
            this.Document.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:scalogramLabel")))+"-"+name;

            info=this.PlotInfo(name);
            if separatePlots&&isComplex
                type="separate";
            else
                type="oneplot";
            end

            if length(info.(type).axis)==2
                this.GridLayout.RowHeight={'1x','1x'};
            else
                this.GridLayout.RowHeight={'1x'};
            end

            for idx=1:length(info.(type).axis)

                if(isComplex&&separatePlots)||~isComplex
                    info.(type).boundaryLine(idx).Visible=boundaryLine;
                    info.(type).region(idx).Visible=shadeRegion;
                    info.(type).axis(idx).YScale="log";
                end

                info.(type).axis(idx).Parent=this.GridLayout;
                info.(type).axis(idx).Visible=true;
            end
        end

        function addAxes(this,app)

            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;


            group=FigureDocumentGroup();
            group.Title="Figures";
            app.add(group);


            figOptions.DocumentGroupTag=group.Tag;
            this.Document=FigureDocument(figOptions,"Closable",false);
            app.add(this.Document);
            this.Document.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:plotLabel")));
            this.Document.Tag="document";


            this.GridLayout=uigridlayout([1,1],"Parent",this.Document.Figure);
        end
    end

end
