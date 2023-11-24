classdef SurfPlot<simmanager.designview.FigureObject
    properties(Dependent)
XLabel
YLabel
ZLabel
XLim
YLim
ZLim
XLimMode
YLimMode
ZLimMode
XGrid
YGrid
ZGrid
XData
YData
ZData
Colormap
Colorbar
    end

    properties(Access=private)
SurfObject
XDataActual
YDataActual
ZDataActual
ColormapActual
    end

    properties(Access=private,Transient=true)
DataListeners
    end

    properties(Transient=true)
FigureProperties
    end

    events
RunSelected
RunDeselected
HoverInactive
    end

    methods(Access=?simmanager.designview.FigureManager)
        function obj=SurfPlot(selectedRuns,figureData,MATLABFig,figPropertiesDataModel)
            if nargin<3
                MATLABFig=[];
                figPropertiesDataModel=[];
            end
            obj=obj@simmanager.designview.FigureObject(MATLABFig,figPropertiesDataModel);
            obj.DataSourceLabels=figureData.DataSourceLabels;
            endFunc=@(x)x(end);

            if isempty(figPropertiesDataModel)
                obj.XDataActual=struct('Id','','PostProcess',endFunc);
                obj.YDataActual=struct('Id','','PostProcess',endFunc);
                obj.ZDataActual=struct('Id','','PostProcess',endFunc);
                obj.Colormap='parula';
            else
                obj.XDataActual=struct('Id',obj.FigureProperties.XData.Id,'PostProcess',obj.FigureProperties.XData.ProcessingType);
                obj.YDataActual=struct('Id',obj.FigureProperties.YData.Id,'PostProcess',obj.FigureProperties.YData.ProcessingType);
                obj.ZDataActual=struct('Id',obj.FigureProperties.ZData.Id,'PostProcess',obj.FigureProperties.ZData.ProcessingType);
            end

            obj.DataFormatter=simmanager.designview.internal.ScatterDataFormatter(figureData);

            if isempty(MATLABFig)
                obj.createSurface(selectedRuns);
            else
                obj.SurfObject=MATLABFig.CurrentAxes.Children;
            end

            obj.setupDataListeners();

            if isempty(figPropertiesDataModel)
                obj.setFigureProperties();
            end

            notify(obj,'FigureCreated');
            obj.setupFigurePropertyListeners();

            if isempty(figPropertiesDataModel)
                [xAxis,yAxis,cAxis]=getDefaultAxes(figureData.DataSourceNames);
                xDataSpec=slsim.design.FigureDataSpec(obj.DataModel,...
                struct('Id',xAxis,'ProcessingType',slsim.design.DataProcessingType.End));
                obj.FigureProperties.XData=xDataSpec;
                yDataSpec=slsim.design.FigureDataSpec(obj.DataModel,...
                struct('Id',yAxis,'ProcessingType',slsim.design.DataProcessingType.End));
                obj.FigureProperties.YData=yDataSpec;
                cDataSpec=slsim.design.FigureDataSpec(obj.DataModel,...
                struct('Id',cAxis,'ProcessingType',slsim.design.DataProcessingType.End));
                obj.FigureProperties.ZData=cDataSpec;

                obj.changeAllDataIds(xAxis,yAxis,cAxis);
            end
        end
    end

    methods
        function out=get.XLabel(obj)
            out=obj.MATLABFigureAxes.XLabel.String;
        end

        function set.XLabel(obj,newLabel)
            obj.updateFigureLabel('XLabel',newLabel);
        end

        function out=get.YLabel(obj)
            out=obj.MATLABFigureAxes.YLabel.String;
        end

        function set.YLabel(obj,newLabel)
            obj.updateFigureLabel('YLabel',newLabel);
        end

        function out=get.ZLabel(obj)
            out=obj.MATLABFigureAxes.ZLabel.String;
        end

        function set.ZLabel(obj,newLabel)
            obj.updateFigureLabel('ZLabel',newLabel);
        end

        function out=get.XLim(obj)
            out=obj.MATLABFigureAxes.XLim;
        end

        function set.XLim(obj,newLimits)
            obj.MATLABFigureAxes.XLim=newLimits;
        end

        function out=get.YLim(obj)
            out=obj.MATLABFigureAxes.YLim;
        end

        function set.YLim(obj,newLimits)
            obj.MATLABFigureAxes.YLim=newLimits;
        end

        function out=get.ZLim(obj)
            out=obj.MATLABFigureAxes.ZLim;
        end

        function set.ZLim(obj,newLimits)
            obj.MATLABFigureAxes.ZLim=newLimits;
        end

        function out=get.XLimMode(obj)
            out=obj.MATLABFigureAxes.XLimMode;
        end

        function set.XLimMode(obj,newLimMode)
            if islogical(newLimMode)
                if newLimMode
                    newLimMode='auto';
                else
                    newLimMode='manual';
                end
            end
            obj.MATLABFigureAxes.XLimMode=newLimMode;
        end

        function out=get.YLimMode(obj)
            out=obj.MATLABFigureAxes.YLimMode;
        end

        function set.YLimMode(obj,newLimMode)
            if islogical(newLimMode)
                if newLimMode
                    newLimMode='auto';
                else
                    newLimMode='manual';
                end
            end
            obj.MATLABFigureAxes.YLimMode=newLimMode;
        end

        function out=get.ZLimMode(obj)
            out=obj.MATLABFigureAxes.ZLimMode;
        end

        function set.ZLimMode(obj,newLimMode)
            if islogical(newLimMode)
                if newLimMode
                    newLimMode='auto';
                else
                    newLimMode='manual';
                end
            end
            obj.MATLABFigureAxes.ZLimMode=newLimMode;
        end

        function out=get.XGrid(obj)
            out=obj.MATLABFigureAxes.XGrid;
        end

        function set.XGrid(obj,val)
            obj.MATLABFigureAxes.XGrid=val;
        end

        function out=get.YGrid(obj)
            out=obj.MATLABFigureAxes.YGrid;
        end

        function set.YGrid(obj,val)
            obj.MATLABFigureAxes.YGrid=val;
        end

        function out=get.ZGrid(obj)
            out=obj.MATLABFigureAxes.ZGrid;
        end

        function set.ZGrid(obj,val)
            obj.MATLABFigureAxes.ZGrid=val;
        end




        function set.XData(obj,newData)
            if isstruct(newData)
                obj.XDataActual=newData;
            else
                obj.XDataActual.Id=newData;
            end
            obj.FigureProperties.XData.Id=obj.XDataActual.Id;
            dataLabel=obj.getLabelFromId(obj.XDataActual.Id);
            xlabel(obj.MATLABFigureAxes,dataLabel);

            obj.updateSurfPlot();
        end

        function xData=get.XData(obj)
            xData=obj.XDataActual;
        end




        function set.YData(obj,newData)
            if isstruct(newData)
                obj.YDataActual=newData;
            else
                obj.YDataActual.Id=newData;
            end

            obj.FigureProperties.YData.Id=obj.YDataActual.Id;
            dataLabel=obj.getLabelFromId(obj.YDataActual.Id);
            ylabel(obj.MATLABFigureAxes,dataLabel);

            obj.updateSurfPlot();
        end

        function yData=get.YData(obj)
            yData=obj.YDataActual;
        end



        function set.ZData(obj,newData)
            if isstruct(newData)
                obj.ZDataActual=newData;
            else
                obj.ZDataActual.Id=newData;
            end
            obj.FigureProperties.ZData.Id=obj.ZDataActual.Id;
            dataLabel=obj.getLabelFromId(obj.ZDataActual.Id);
            zlabel(obj.MATLABFigureAxes,dataLabel);

            obj.updateSurfPlot();
        end

        function cData=get.ZData(obj)
            cData=obj.ZDataActual;
        end

        function set.Colormap(obj,newColormap)
            colormap(obj.MATLABFigure,newColormap);
            obj.FigureProperties.ColorMap=newColormap;
        end

        function colorMap=get.Colormap(obj)
            colorMap=obj.ColormapActual;
        end

        function set.Colorbar(obj,showColorbar)
            obj.FigureProperties.Colorbar=showColorbar;
            if(showColorbar)
                colorbar(obj.MATLABFigureAxes);
            else
                colorbar(obj.MATLABFigureAxes,'off');
            end
        end

        function val=get.Colorbar(obj)
            val=obj.FigureProperties.Colorbar;
        end



        function changeAllDataIds(obj,xData,yData,cData)
            obj.XData=xData;
            obj.YData=yData;
            obj.ZData=cData;
        end

        function delete(obj)
            delete@simmanager.designview.FigureObject(obj);
            delete(obj.DataListeners);
        end




        function selectRuns(obj,runIds,append)
        end


        function deselectRuns(obj,runIds)
        end



        function createConnector(obj)
            obj.FigureObjectConnector=simmanager.designview.internal.SurfPlotConnector(obj);
        end

        function commandHandler(obj,report)
            command=report.Created;
            obj.updateFigureProperties(command.name,command.value);
        end

        function reset(obj)
            obj.updateSurfPlot();
            obj.updateFigureXLimits();
            obj.updateFigureYLimits();
            obj.updateFigureZLimits();
        end

        function addDataSources(obj,dataSources)
            simStatusId=simmanager.designview.internal.FigureData.SimStatusParameter.Id;
            txn=obj.DataModel.beginTransaction();
            for i=1:numel(dataSources)

                if~strcmp(dataSources(i).value,simStatusId)
                    obj.FigureProperties.XDataSources.add(...
                    copyDataSource(dataSources(i),obj.DataModel));

                    obj.FigureProperties.YDataSources.add(...
                    copyDataSource(dataSources(i),obj.DataModel));

                    obj.FigureProperties.ZDataSources.add(...
                    copyDataSource(dataSources(i),obj.DataModel));
                end
            end
            txn.commit();
        end
    end

    methods(Access=private)
        function createSurface(obj,~)
            xData=obj.DataFormatter.formatXData(obj.XDataActual);
            yData=obj.DataFormatter.formatYData(obj.YDataActual);
            zData=obj.DataFormatter.formatYData(obj.ZDataActual);

            [X,Y,Z]=simmanager.designview.internal.getSurfDataFromScatteredData(xData,yData,zData);
            obj.SurfObject=surf(obj.MATLABFigureAxes,X,Y,Z);
        end

        function updateSurfPlot(obj)
            xData=obj.DataFormatter.formatXData(obj.XDataActual);
            yData=obj.DataFormatter.formatYData(obj.YDataActual);
            zData=obj.DataFormatter.formatYData(obj.ZDataActual);
            [X,Y,Z]=simmanager.designview.internal.getSurfDataFromScatteredData(xData,yData,zData);
            obj.SurfObject.XData=X;
            obj.SurfObject.YData=Y;
            obj.SurfObject.ZData=Z;
        end

        function updateFigureXLimits(obj)
            xLimits=obj.XLim;
            obj.FigureProperties.XMin=xLimits(1);
            obj.FigureProperties.XMax=xLimits(2);
        end

        function updateFigureYLimits(obj)
            yLimits=obj.YLim;
            obj.FigureProperties.YMin=yLimits(1);
            obj.FigureProperties.YMax=yLimits(2);
        end

        function updateFigureZLimits(obj)
            zLimits=obj.ZLim;
            obj.FigureProperties.ZMin=zLimits(1);
            obj.FigureProperties.ZMax=zLimits(2);
        end

        function updateColorbar(obj)
            obj.FigureProperties.Colorbar=~isempty(obj.MATLABFigureAxes.Colorbar);
        end


        function plotClick(obj,~,evt)
            if evt.Button==0
                notify(obj,'HoverInactive');

            else
                notify(obj,'FigureClicked');
            end
        end


        function borderClick(obj,~,~)
            notify(obj,'AxesClicked');
        end



        function regatherAllDataForRunId(obj,runId)
            obj.updateSurfPlot();
        end



        function regatherSimStatusForRunId(obj,runIds)

        end



        function sendSelect(obj,evtData)
            notify(obj,'RunSelected',evtData);
        end



        function sendDeselect(obj,evtData)
            notify(obj,'RunDeselected',evtData);
        end

        function setFigureProperties(obj)
            obj.FigureProperties=slsim.design.SurfPlotProperties(obj.DataModel);

            obj.FigureProperties.Title=obj.Title;
            obj.FigureProperties.XLabel=obj.XLabel;
            xLimits=obj.XLim;
            obj.FigureProperties.XMin=xLimits(1);
            obj.FigureProperties.XMax=xLimits(2);

            obj.FigureProperties.YLabel=obj.YLabel;
            yLimits=obj.YLim;
            obj.FigureProperties.YMin=yLimits(1);
            obj.FigureProperties.YMax=yLimits(2);

            zLimits=obj.ZLim;
            obj.FigureProperties.ZMin=zLimits(1);
            obj.FigureProperties.ZMax=zLimits(2);

            obj.FigureProperties.XGrid=obj.getBooleanGridState(obj.XGrid);
            obj.FigureProperties.YGrid=obj.getBooleanGridState(obj.YGrid);
            obj.FigureProperties.ZGrid=obj.getBooleanGridState(obj.ZGrid);
        end

        function updateFigureProperties(obj,propName,propValue)
            switch propName
            case{'XMin'}
                xLim=obj.XLim;
                newMin=propValue;
                obj.XLim=[newMin,xLim(2)];
                obj.FigureProperties.XMin=newMin;

            case{'XMax'}
                xLim=obj.XLim;
                newMax=propValue;
                obj.XLim=[xLim(1),newMax];
                obj.FigureProperties.XMax=newMax;

            case{'YMin'}
                yLim=obj.YLim;
                newMin=propValue;
                obj.YLim=[newMin,yLim(2)];
                obj.FigureProperties.YMin=newMin;

            case{'YMax'}
                yLim=obj.YLim;
                newMax=propValue;
                obj.YLim=[yLim(1),newMax];
                obj.FigureProperties.YMax=newMax;

            case{'ZMin'}
                zLim=obj.ZLim;
                newMin=propValue;
                obj.ZLim=[newMin,zLim(2)];
                obj.FigureProperties.ZMin=newMin;

            case{'ZMax'}
                zLim=obj.ZLim;
                newMax=propValue;
                obj.ZLim=[zLim(1),newMax];
                obj.FigureProperties.ZMax=newMax;

            case{'XLimMode'}
                obj.XLimMode=propValue;
                xLim=obj.XLim;
                obj.FigureProperties.XMin=xLim(1);
                obj.FigureProperties.XMax=xLim(2);

            case{'YLimMode'}
                obj.YLimMode=propValue;
                yLim=obj.YLim;
                obj.FigureProperties.YMin=yLim(1);
                obj.FigureProperties.YMax=yLim(2);

            case{'ZLimMode'}
                obj.ZLimMode=propValue;
                zLim=obj.ZLim;
                obj.FigureProperties.ZMin=zLim(1);
                obj.FigureProperties.ZMax=zLim(2);

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

            otherwise
                obj.(propName)=propValue;
            end
        end

        function updateFigureLabel(obj,axisProp,newLabel)
            obj.MATLABFigureAxes.(axisProp).String=newLabel;
        end

        function setupDataListeners(obj)
            obj.DataListeners=addlistener(obj.DataFormatter,"SimStatusUpdated",...
            @(~,evtData)obj.regatherSimStatusForRunId(evtData.Data));

            obj.DataListeners(2)=addlistener(obj.DataFormatter,"AllDataUpdated",...
            @(~,evtData)obj.regatherAllDataForRunId(evtData.Data));
        end

        function setupFigurePropertyListeners(obj)
            addlistener(obj.MATLABFigureAxes,'XLim','PostSet',@obj.limitsChangeHandler);
            addlistener(obj.MATLABFigureAxes,'XLabel','PostSet',@obj.labelChangeHandler);
            addlistener(obj.MATLABFigureAxes.XLabel,'String','PostSet',@(~,propEvent)obj.labelChangeHandler('XLabel',propEvent));
            addlistener(obj.MATLABFigureAxes.YLabel,'String','PostSet',@(~,propEvent)obj.labelChangeHandler('YLabel',propEvent));
            addlistener(obj.MATLABFigureAxes.ZLabel,'String','PostSet',@(~,propEvent)obj.labelChangeHandler('ZLabel',propEvent));
            addlistener(obj.MATLABFigureAxes,'XLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('XLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'YLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('YLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'ZLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('ZLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'XGrid','PostSet',@(~,propEvent)obj.gridChangeHandler('XGrid',propEvent));
            addlistener(obj.MATLABFigureAxes,'YGrid','PostSet',@(~,propEvent)obj.gridChangeHandler('YGrid',propEvent));
            addlistener(obj.MATLABFigureAxes,'ZGrid','PostSet',@(~,propEvent)obj.gridChangeHandler('ZGrid',propEvent));

        end

        function limitsChangeHandler(obj,varargin)

        end

        function newLabelHandler(obj,varargin)
        end

        function labelChangeHandler(obj,labelId,propEvent)
            obj.FigureProperties.(labelId)=propEvent.AffectedObject.String;
        end

        function limModeChangeHandler(obj,limModeId,propEvent)
            newLimMode=propEvent.AffectedObject.(limModeId);
            switch(newLimMode)
            case 'auto'
                obj.FigureProperties.(limModeId)=true;

            case 'manual'
                obj.FigureProperties.(limModeId)=false;
            end
        end

        function gridChangeHandler(obj,gridAxis,propEvent)
            gridState=propEvent.AffectedObject.(gridAxis);
            switch(gridState)
            case 'on'
                obj.FigureProperties.(gridAxis)=true;

            case 'off'
                obj.FigureProperties.(gridAxis)=false;
            end
        end

        function TF=getBooleanGridState(obj,gridState)
            switch(gridState)
            case 'on'
                TF=true;

            case 'off'
                TF=false;
            end
        end
    end

    methods(Access=protected)
        function markedCleanCB(obj,~,~)



            obj.updateFigureXLimits();
            obj.updateFigureYLimits();
            obj.updateFigureZLimits();
            obj.updateColorbar();
        end
    end
end



function validParamNames=pickFirstValidParam(paramNames,invalidParamNames)
    for i=1:numel(paramNames)
        curParamName=paramNames{i};
        if~any(strcmp(curParamName,invalidParamNames))
            validParamNames=curParamName;
            return;
        end
    end
end

function new=copyDataSource(old,model)
    new=slsim.design.FigureDataSource(model,...
    struct('value',old.value,...
    'label',old.label,...
    'type',old.type));
end


function[xAxis,yAxis,cAxis]=getDefaultAxes(paramNames)
    xAxis='RunId';
    yAxis='RunId';
    cAxis='RunId';
    if isempty(paramNames)
        return;
    end

    switch numel(paramNames)
    case 2
    case 3
        firstField=pickFirstValidParam(paramNames,...
        {'RunId','Simulation Status'});
        xAxis=firstField;
        yAxis=firstField;
    otherwise
        firstField=pickFirstValidParam(paramNames,...
        {'RunId','Simulation Status'});
        secondField=pickFirstValidParam(paramNames,...
        {'RunId','Simulation Status',firstField});
        xAxis=firstField;
        yAxis=secondField;
    end
end
