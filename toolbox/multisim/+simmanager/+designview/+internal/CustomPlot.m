classdef CustomPlot<simmanager.designview.FigureObject







    properties
        PlotInput="Simulation Output"
    end



    properties(Transient=true)
FigureProperties
    end



    properties(Access=private)
SelectedRuns
FigureData
CustomPlotObj
RunsReportedToUpdateFcn
    end



    properties(Access=private,Transient=true)
Listeners
FigureManager

        SimulationOutputs=struct('runId',{},'Output',{});
    end



    events
RunSelected
RunDeselected
HoverInactive
    end



    methods(Access={?simmanager.designview.FigureManager,...
        ?matlab.mock.classes.CustomPlotMock})

        function obj=CustomPlot(figureManager,customPlotObject,...
            MATLABFig,figurePropsDataModel)

            if nargin<3
                MATLABFig=[];
                figurePropsDataModel=[];
            end

            obj=obj@simmanager.designview.FigureObject(MATLABFig,...
            figurePropsDataModel);

            obj.setProperties(figureManager,customPlotObject);
            obj.initializeFigure(MATLABFig);
            obj.setupListeners();
            obj.setFigureProperties(figurePropsDataModel);

            notify(obj,'FigureCreated');
        end

    end



    methods

        function createConnector(obj)
            import simmanager.designview.internal.CustomPlotConnector;
            obj.FigureObjectConnector=CustomPlotConnector(obj);
        end


        function commandHandler(obj,report)
            command=report.Created;
            obj.updateFigureProperties(command.name,command.value);
        end


        function reset(obj)
            delete(obj.Listeners);
            obj.setupListeners();

            cla(obj.MATLABFigureAxes)

            numSims=obj.FigureData.getNumSims();

            obj.RunsReportedToUpdateFcn=false(numSims,1);

            obj.SimulationOutputs=struct('runId',{},'Output',{});

            obj.SimulationOutputs(numSims)=...
            struct('runId',numSims,'Output',[]);

            obj.callSetupFcn(obj.SelectedRuns);
        end


        function delete(obj)
            delete@simmanager.designview.FigureObject(obj);
            delete(obj.Listeners);
        end


        function selectRuns(~,~);end
        function deselectRuns(~,~);end
        function addDataSources(~,~);end

    end



    methods(Hidden)

        function simOuts=getSimulationOutputs(obj)
            if all(obj.RunsReportedToUpdateFcn)
                simOuts=obj.SimulationOutputs;
                return;
            end

            numIds=obj.FigureData.getNumSims();
            simMgr=obj.FigureManager.MultiSimJob.SimulationManager;

            for runId=1:numIds
                if isempty(fieldnames(simMgr.SimulationData{runId}))
                    continue;
                end

                simOut=Simulink.SimulationOutput(...
                simMgr.SimulationData{runId},...
                simMgr.SimulationMetadata{runId}...
                );

                simOutStruct=struct('runId',runId,'Output',simOut);
                obj.SimulationOutputs(runId)=simOutStruct;
                obj.RunsReportedToUpdateFcn(runId)=true;
                simOuts=obj.SimulationOutputs;
            end
        end


        function simIns=getSimulationInputs(obj)
            simMgr=obj.FigureManager.MultiSimJob.SimulationManager;
            simIns=simMgr.getOriginalSimulationInputs();
        end


        function setProperties(obj,figureManager,customPlotObject)
            import simmanager.designview.internal.CustomPlotDataFormatter

            obj.CustomPlotObj=customPlotObject;
            obj.CustomPlotObj.MATLABFigure=obj.MATLABFigure;

            obj.FigureManager=figureManager;
            obj.SelectedRuns=obj.FigureManager.SelectedRuns;
            obj.FigureData=obj.FigureManager.getFigureData();

            numSims=obj.FigureData.getNumSims();

            obj.RunsReportedToUpdateFcn=false(numSims,1);

            obj.SimulationOutputs(numSims)=...
            struct('runId',numSims,'Output',[]);

            obj.DataSourceLabels=obj.FigureData.DataSourceLabels;
            obj.DataFormatter=CustomPlotDataFormatter(obj.FigureData);
        end


        function initializeFigure(obj,MATLABFig)
            if isempty(MATLABFig)
                obj.callSetupFcn(obj.SelectedRuns);
            end

            if~obj.FigureManager.MultiSimJob.IsRunning
                simOuts=obj.getSimulationOutputs();

                for simOutStruct=simOuts
                    obj.CustomPlotObj.update(...
                    simOutStruct.Output,...
                    simOutStruct.runId...
                    );
                end
            end
        end


        function callSetupFcn(obj,~)
            simIns=obj.getSimulationInputs();
            obj.CustomPlotObj.setup(simIns);
        end


        function callUpdateFcn(obj,finishedEventData)

            runId=finishedEventData.RunId;
            simOut=finishedEventData.SimulationOutput;

            obj.RunsReportedToUpdateFcn(runId)=true;

            simOutStruct=struct('runId',runId,'Output',simOut);
            obj.SimulationOutputs(runId)=simOutStruct;

            obj.CustomPlotObj.update(simOut,runId);
        end


        function setFigureProperties(obj,figurePropsDataModel)
            if~isempty(figurePropsDataModel)
                return;
            end

            obj.FigureProperties=...
            slsim.design.CustomPlotProperties(obj.DataModel);

            obj.FigureProperties.Title=obj.Title;
            obj.FigureProperties.PlotInput=obj.PlotInput;

            obj.FigureProperties.PlotConfigId=...
            obj.CustomPlotObj.PlotConfigId;
        end


        function updateFigureProperties(obj,propName,propValue)
            switch propName
            case{'Title','PlotInput'}
                obj.(propName)=propValue;

            case{'FigureWidth'}
                fh=obj.MATLABFigure;
                currentPos=fh.Position;
                currentPos(3)=propValue;
                fh.Position=currentPos;

            case{'FigureHeight'}
                fh=obj.MATLABFigure;
                currentPos=fh.Position;
                currentPos(4)=propValue;
                fh.Position=currentPos;
            end
        end


        function setupListeners(obj)
            simMgr=obj.FigureManager.MultiSimJob.SimulationManager;

            obj.Listeners=addlistener(simMgr,"SimulationFinished",...
            @(~,eventData)obj.callUpdateFcn(eventData));

            obj.Listeners(2)=...
            addlistener(simMgr,"JobStarted",@(~,~)obj.reset);
        end


        function formatter=getDataFormatter(obj)
            formatter=obj.DataFormatter;
        end

    end



end

