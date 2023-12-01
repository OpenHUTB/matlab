classdef ScatterPlot<simmanager.designview.FigureObject
    properties(Dependent)
XLabel
YLabel
CLabel
XLim
YLim
CLim
XLimMode
YLimMode
CLimMode
XGrid
YGrid
ZGrid
XData
YData
CData
Colormap
Colorbar
    end

    properties(Access=private)
XDataActual
YDataActual
CDataActual
MainScatterLayer
SelectedScatterLayer
BlackScatterLayer
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
        function obj=ScatterPlot(selectedRuns,figureData,MATLABFig,figPropertiesDataModel)
            if nargin<3
                MATLABFig=[];
                figPropertiesDataModel=[];
            end
            obj=obj@simmanager.designview.FigureObject(MATLABFig,figPropertiesDataModel);
            obj.DataSourceLabels=figureData.DataSourceLabels;
            endFunc=@(x)x(end);
            obj.DataFormatter=simmanager.designview.internal.ScatterDataFormatter(figureData);

            if isempty(figPropertiesDataModel)
                obj.XDataActual=struct('Id','','PostProcess',endFunc);
                obj.YDataActual=struct('Id','','PostProcess',endFunc);
                obj.CDataActual=struct('Id','','PostProcess',endFunc);
                obj.Colormap='parula';
            else
                obj.XDataActual=struct('Id',obj.FigureProperties.XData.Id,'PostProcess',obj.FigureProperties.XData.ProcessingType);
                obj.YDataActual=struct('Id',obj.FigureProperties.YData.Id,'PostProcess',obj.FigureProperties.YData.ProcessingType);
                obj.CDataActual=struct('Id',obj.FigureProperties.CData.Id,'PostProcess',obj.FigureProperties.CData.ProcessingType);
            end

            if isempty(MATLABFig)
                obj.createScatters(selectedRuns);
            else
                obj.addScatterLayers(selectedRuns,MATLABFig.CurrentAxes);
            end

            obj.setupDataListeners();

            obj.applyScatterListeners();

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
                obj.FigureProperties.CData=cDataSpec;

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

        function out=get.CLabel(obj)
            out=obj.FigureProperties.CLabel;
        end

        function set.CLabel(obj,newLabel)
            cb=obj.MATLABFigureAxes.Colorbar;
            if isempty(cb)
                obj.Colorbar=true;
            end
            obj.MATLABFigureAxes.Colorbar.Label.String=newLabel;
            obj.FigureProperties.CLabel=newLabel;
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

        function out=get.CLim(obj)
            out=obj.MATLABFigureAxes.CLim;
        end

        function set.CLim(obj,newLimits)
            obj.MATLABFigureAxes.CLim=newLimits;
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

        function out=get.CLimMode(obj)
            out=obj.MATLABFigureAxes.CLimMode;
        end

        function set.CLimMode(obj,newLimMode)
            if islogical(newLimMode)
                if newLimMode
                    newLimMode='auto';
                else
                    newLimMode='manual';
                end
            end
            obj.MATLABFigureAxes.CLimMode=newLimMode;
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




        function set.XData(obj,newData)
            if isstruct(newData)
                obj.XDataActual=newData;
            else
                obj.XDataActual.Id=newData;
            end
            obj.FigureProperties.XData.Id=obj.XDataActual.Id;
            dataLabel=obj.getLabelFromId(obj.XDataActual.Id);
            xlabel(obj.MATLABFigureAxes,dataLabel);

            obj.updateFigureXData();
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

            obj.updateFigureYData();
        end

        function yData=get.YData(obj)
            yData=obj.YDataActual;
        end




        function set.CData(obj,newData)
            if isstruct(newData)
                obj.CDataActual=newData;
            else
                obj.CDataActual.Id=newData;
            end
            obj.FigureProperties.CData.Id=obj.CDataActual.Id;

            obj.updateFigureCData();

            if obj.FigureProperties.Colorbar
                cb=colorbar(obj.MATLABFigureAxes);
                cb.Label.String=obj.CLabel;
            end
        end

        function cData=get.CData(obj)
            cData=obj.CDataActual;
        end



        function set.Colormap(obj,newColormap)
            colormap(obj.MATLABFigure,newColormap);
            obj.FigureProperties.ColorMap=newColormap;
        end

        function colorMap=get.Colormap(obj)
            colorMap=obj.FigureProperties.ColorMap;
        end

        function set.Colorbar(obj,showColorbar)
            obj.FigureProperties.Colorbar=showColorbar;
            if(showColorbar)
                cb=colorbar(obj.MATLABFigureAxes);
                cb.Label.String=obj.CLabel;
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
            obj.CData=cData;
        end

        function delete(obj)
            delete@simmanager.designview.FigureObject(obj);
            delete(obj.MainScatterLayer);
            delete(obj.SelectedScatterLayer);
            delete(obj.BlackScatterLayer);
            delete(obj.DataListeners);
        end





        function selectRuns(obj,runIds,append)
            if~append
                obj.SelectedScatterLayer.clearScatter();
            end

            xArray=obj.DataFormatter.formatXData(obj.XData);
            yArray=obj.DataFormatter.formatYData(obj.YData);

            arrayfun(@(x)obj.SelectedScatterLayer.addScatterPoint(...
            xArray(x),yArray(x),x),runIds);
        end


        function deselectRuns(obj,runIds)
            arrayfun(@(x)obj.SelectedScatterLayer.removeScatterPoint(x),runIds);
        end



        function createConnector(obj)
            obj.FigureObjectConnector=simmanager.designview.internal.ScatterPlotConnector(obj);
        end

        function commandHandler(obj,report)
            command=report.Created;
            obj.updateFigureProperties(command.name,command.value);
        end

        function reset(obj)
            obj.updateFigureXData();
            obj.updateFigureYData();
            obj.updateFigureCData();
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
                end

                obj.FigureProperties.CDataSources.add(...
                copyDataSource(dataSources(i),obj.DataModel));
            end
            txn.commit();
        end
    end

    methods(Access=private)



        function createScatters(obj,selectedRuns)
            xData=obj.DataFormatter.formatXData(obj.XDataActual);
            yData=obj.DataFormatter.formatYData(obj.YDataActual);
            cData=obj.DataFormatter.formatCData(obj.CDataActual);

            obj.MainScatterLayer=simmanager.designview.internal.ScatterPlotMainLayer(...
            xData,yData,cData,obj.MATLABFigureAxes,[]);
            obj.BlackScatterLayer=simmanager.designview.internal.ScatterPlotBlackLayer(...
            xData,yData,[],obj.MATLABFigureAxes,[]);
            obj.SelectedScatterLayer=simmanager.designview.internal.ScatterPlotSelectedLayer(...
            xData,yData,selectedRuns,obj.MATLABFigureAxes,[]);
        end

        function addScatterLayers(obj,selectedRuns,figAxes)
            xData=obj.DataFormatter.formatXData(obj.XDataActual);
            yData=obj.DataFormatter.formatYData(obj.YDataActual);
            cData=obj.DataFormatter.formatCData(obj.CDataActual);

            obj.MainScatterLayer=simmanager.designview.internal.ScatterPlotMainLayer(...
            xData,yData,cData,obj.MATLABFigureAxes,figAxes.Children(3));
            obj.BlackScatterLayer=simmanager.designview.internal.ScatterPlotBlackLayer(...
            xData,yData,[],obj.MATLABFigureAxes,figAxes.Children(2));
            obj.SelectedScatterLayer=simmanager.designview.internal.ScatterPlotSelectedLayer(...
            xData,yData,selectedRuns,obj.MATLABFigureAxes,figAxes.Children(1));
        end

        function updateAxesLimits(obj)

            xLimits=obj.XLim;
            obj.FigureProperties.XMin=xLimits(1);
            obj.FigureProperties.XMax=xLimits(2);

            yLimits=obj.YLim;
            obj.FigureProperties.YMin=yLimits(1);
            obj.FigureProperties.YMax=yLimits(2);
        end

        function updateColorbar(obj)
            colorbarEnabledOld=obj.FigureProperties.Colorbar;
            colorbarEnabledNew=~isempty(obj.MATLABFigureAxes.Colorbar);


            obj.FigureProperties.Colorbar=colorbarEnabledNew;


            if~colorbarEnabledOld&&colorbarEnabledNew
                cb=obj.MATLABFigureAxes.Colorbar;
                addlistener(cb.Label,'String','PostSet',...
                @(~,propEvent)obj.setFigureProperty('CLabel',propEvent.AffectedObject.String));
            end
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
            xData=obj.DataFormatter.getSingleParamVal(obj.XData,runId);
            yData=obj.DataFormatter.getSingleParamVal(obj.YData,runId);
            cData=obj.DataFormatter.getSingleParamVal(obj.CData,runId);

            obj.MainScatterLayer.updateScatterData(xData,yData,cData,runId);
            obj.SelectedScatterLayer.updateScatterData(xData,yData,runId);

            if any(isnan(cData))
                obj.BlackScatterLayer.addScatterPoint(xData,yData,runId);
            else
                obj.BlackScatterLayer.removeScatterPoint(runId);
            end
        end



        function regatherSimStatusForRunId(obj,runIds)
            simStatusParam=simmanager.designview.internal.FigureData.SimStatusParameter;
            updateNeeded=strcmp(obj.CDataActual.Id,simStatusParam.Id);
            for i=1:numel(runIds)
                runId=runIds(i);
                simStatusData=obj.DataFormatter.getSingleParamVal(simStatusParam,runId);
                if updateNeeded
                    obj.MainScatterLayer.updateCData(simStatusData,runId);
                end
            end
        end



        function sendSelect(obj,evtData)
            notify(obj,'RunSelected',evtData);
        end



        function sendDeselect(obj,evtData)
            notify(obj,'RunDeselected',evtData);
        end




        function applyScatterListeners(obj)
            addlistener(obj.MainScatterLayer,"RunSelected",...
            @(~,evtData)obj.sendSelect(evtData));

            addlistener(obj.BlackScatterLayer,"RunSelected",...
            @(~,evtData)obj.sendSelect(evtData));

            addlistener(obj.SelectedScatterLayer,"RunDeselected",...
            @(~,evtData)obj.sendDeselect(evtData));

            addlistener(obj.MainScatterLayer,"DatatipRequest",...
            @(~,evtData)obj.DatatipManager.createDatatip(evtData.XVal,...
            evtData.YVal,evtData.RunId));

            addlistener(obj.BlackScatterLayer,"DatatipRequest",...
            @(~,evtData)obj.DatatipManager.createDatatip(evtData.XVal,...
            evtData.YVal,evtData.RunId));

            addlistener(obj.SelectedScatterLayer,"DatatipRequest",...
            @(~,evtData)obj.DatatipManager.createDatatip(evtData.XVal,...
            evtData.YVal,evtData.RunId));
        end

        function setFigureProperties(obj)
            obj.FigureProperties=slsim.design.ScatterPlotProperties(obj.DataModel);

            obj.FigureProperties.Title=obj.Title;
            obj.FigureProperties.XLabel=obj.XLabel;
            xLimits=obj.XLim;
            obj.FigureProperties.XMin=xLimits(1);
            obj.FigureProperties.XMax=xLimits(2);

            obj.FigureProperties.YLabel=obj.YLabel;
            yLimits=obj.YLim;
            obj.FigureProperties.YMin=yLimits(1);
            obj.FigureProperties.YMax=yLimits(2);

            cLimits=obj.CLim;
            obj.FigureProperties.CMin=cLimits(1);
            obj.FigureProperties.CMax=cLimits(2);

            obj.FigureProperties.XGrid=obj.getGridState('XGrid');
            obj.FigureProperties.YGrid=obj.getGridState('YGrid');
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

            case{'CMin'}
                cLim=obj.CLim;
                newMin=propValue;
                obj.CLim=[newMin,cLim(2)];
                obj.FigureProperties.CMin=newMin;

            case{'CMax'}
                cLim=obj.CLim;
                newMax=propValue;
                obj.CLim=[cLim(1),newMax];
                obj.FigureProperties.CMax=newMax;

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

            case{'CLimMode'}
                obj.CLimMode=propValue;
                cLim=obj.CLim;
                obj.FigureProperties.CMin=cLim(1);
                obj.FigureProperties.CMax=cLim(2);

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
            addlistener(obj.MATLABFigureAxes,'XLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('XLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'YLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('YLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'CLimMode','PostSet',@(~,propEvent)obj.limModeChangeHandler('CLimMode',propEvent));
            addlistener(obj.MATLABFigureAxes,'XGrid','PostSet',@(~,propEvent)obj.gridChangeHandler('XGrid',propEvent));
            addlistener(obj.MATLABFigureAxes,'YGrid','PostSet',@(~,propEvent)obj.gridChangeHandler('YGrid',propEvent));
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

        function TF=getGridState(obj,gridAxis)
            gridState=obj.(gridAxis);
            switch(gridState)
            case 'on'
                TF=true;

            case 'off'
                TF=false;
            end
        end

        function updateFigureXData(obj)
            newXData=obj.DataFormatter.formatXData(obj.XDataActual);
            obj.MainScatterLayer.replaceXData(newXData);
            obj.SelectedScatterLayer.replaceXData(newXData);
            obj.BlackScatterLayer.replaceXData(newXData);
        end

        function updateFigureYData(obj)
            newYData=obj.DataFormatter.formatYData(obj.YDataActual);
            obj.MainScatterLayer.replaceYData(newYData);
            obj.SelectedScatterLayer.replaceYData(newYData);
            obj.BlackScatterLayer.replaceYData(newYData);
        end

        function updateFigureCData(obj)
            [newCData,BlackLocs]=obj.DataFormatter.formatCData(obj.CDataActual);

            obj.MainScatterLayer.replaceCData(newCData);

            curXData=obj.DataFormatter.formatXData(obj.XDataActual);
            curYData=obj.DataFormatter.formatYData(obj.YDataActual);

            obj.BlackScatterLayer.replaceScatterData(curXData,curYData,BlackLocs);


            cLimits=obj.CLim;
            obj.FigureProperties.CMin=cLimits(1);
            obj.FigureProperties.CMax=cLimits(2);
        end
    end

    methods(Access=protected)
        function markedCleanCB(obj,~,~)



            obj.updateAxesLimits();
            obj.updateColorbar();
        end

        function setFigureProperty(obj,propertyName,propertyValue)
            obj.FigureProperties.(propertyName)=propertyValue;
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
    cAxis='Simulation Status';
    if isempty(paramNames)
        return;
    end

    switch numel(paramNames)
    case 2
    case 3
        firstField=pickFirstValidParam(paramNames,...
        {'Simulation Status','RunId'});
        xAxis=firstField;
        yAxis=firstField;
    otherwise
        firstField=pickFirstValidParam(paramNames,...
        {'Simulation Status','RunId'});
        secondField=pickFirstValidParam(paramNames,...
        {'Simulation Status','RunId',firstField});
        xAxis=firstField;
        yAxis=secondField;
    end
end