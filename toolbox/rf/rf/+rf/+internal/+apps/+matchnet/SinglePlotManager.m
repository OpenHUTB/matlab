classdef(Abstract)SinglePlotManager<handle&matlab.mixin.Heterogeneous





    properties(Access=public)
        Parent matlab.ui.internal.FigureDocument
        PlotID string

        PlotType(1,:)char


        PlotCircuits cell

        PlotParameterOptions cell


        PlotFormatOptions cell

myPlot




        myPlotRawData cell



        myPlotFormattedData cell

        myPlotOptionsPanel matlab.ui.container.Panel
myPlotOptionsUI

        ActiveEvalparams table

Listeners
    end

    methods(Access=public)
        function this=SinglePlotManager(parent)

            this.Parent=parent;
            this.PlotID=this.Parent.Tag;
            this.initializePlot();
        end


        function updateParameterOptions(this,newParameters)
            this.PlotParameterOptions=newParameters;
            this.updatePlot();
        end

        function updateFormatOptions(this,newFormat)
            this.PlotFormatOptions=newFormat;
            this.updatePlot();
        end

        function updateDisplayedCircuits(this,newCircuits)

            for j=1:length(newCircuits)
                if(~any(strcmp(newCircuits{j},this.myPlotRawData(:,1))))
                    error(['Plot data does not exist for circuit ',newCircuits{j}]);
                end
            end
            this.PlotCircuits=newCircuits;

            this.updatePlot();

        end


        function result=haveCircuits(this,circuitNames)
            result=true;
            for j=1:length(circuitNames)
                temp=any(strcmp(circuitNames{j},this.PlotCircuits));
                if(~temp)
                    result=false;
                end
            end
        end

        function addCircuits(this,newCircuits,newData,...
            failedPerformanceTests,nets,compvalues,centerfreq,...
            loadedq,sourceZ,loadZ)
            for j=1:length(newCircuits)
                if(~isempty(this.myPlotRawData))
                    idx=strcmp(newCircuits{j},this.myPlotRawData(:,1));
                else
                    idx=[];
                end
                if j==1
                    if(any(idx))
                        this.myPlotRawData{idx,2}=newData{j};
                        this.myPlotRawData{idx,3}=failedPerformanceTests{j};
                        this.myPlotRawData{idx,4}=nets{j};
                        this.myPlotRawData{idx,5}=compvalues{j};
                        this.myPlotRawData{idx,6}=centerfreq{j};
                        this.myPlotRawData{idx,7}=loadedq{j};
                        this.myPlotRawData{idx,8}=sourceZ{j};
                        this.myPlotRawData{idx,9}=loadZ{j};
                    else
                        this.myPlotRawData{end+1,1}=newCircuits{j};
                        this.myPlotRawData{end,2}=newData{j};
                        this.myPlotRawData{end,3}=failedPerformanceTests{j};
                        this.myPlotRawData{end,4}=nets{j};
                        this.myPlotRawData{end,5}=compvalues{j};
                        this.myPlotRawData{end,6}=centerfreq{j};
                        this.myPlotRawData{end,7}=loadedq{j};
                        this.myPlotRawData{end,8}=sourceZ{j};
                        this.myPlotRawData{end,9}=loadZ{j};
                    end
                else
                    if(any(idx))
                        this.myPlotRawData{idx,2}=newData{j};
                        this.myPlotRawData{idx,3}=failedPerformanceTests{j};
                    else
                        this.myPlotRawData{end+1,1}=newCircuits{j};
                        this.myPlotRawData{end,2}=newData{j};
                        this.myPlotRawData{end,3}=failedPerformanceTests{j};
                    end
                end
            end
        end

        function updateActiveEvalparams(this,params)
            this.ActiveEvalparams=params.ParametersTable;
            for k=1:size(this.myPlotRawData,1)
                index=strcmp(params.CircuitNames,this.myPlotRawData{k,1});
                if any(index)
                    this.myPlotRawData{k,3}=params.Performance{index};
                end
            end
            this.updatePlot();
        end

        function clearCache(this)
            this.myPlotRawData=[];
            this.myPlotFormattedData=[];
            this.PlotCircuits=[];
            this.ActiveEvalparams=table;
        end







    end

    methods(Access=protected)

        function updatePlot(this)
            this.clearAxes();
            this.calculateFormattedPlotData();

            this.drawPlot();
        end

















































































    end

    methods(Access=public,Abstract)
        ui=makePlotOptionsUI(this,parent)
        clearAxes(this)
        setDefaultSelections(this)
    end

    methods(Access=protected,Abstract)

        initializePlot(this)
        calculateFormattedPlotData(this)
        drawPlot(this)
    end


    methods(Sealed)
        function varargout=findobj(obj,varargin)
            [varargout{1:nargout}]=findobj@handle(obj,varargin{:});
        end
    end
end
