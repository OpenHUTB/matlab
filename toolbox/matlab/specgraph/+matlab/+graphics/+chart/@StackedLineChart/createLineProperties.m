function createLineProperties(hObj,axesMapping,plotMapping)







    oldLineProps=hObj.LineProperties_I;
    if hObj.Presenter.ChartDataChanged
        hObj.LineProperties_I(1:end)=[];
    end


    numAxes=hObj.getNumAxesCapped();
    autoPlotType=[];
    for axesIndex=1:numAxes
        [lineProps,autoPlotType]=getLinePropertiesForAxes(hObj,oldLineProps,axesIndex,axesMapping,plotMapping,autoPlotType,numAxes);
        createOrSetLinePropertiesForAxes(hObj,axesIndex,lineProps);
    end

    updateLinePropertiesListener(hObj);
end

function[lineProps,autoPlotType]=getLinePropertiesForAxes(hObj,oldLineProps,axesIndex,axesMapping,plotMapping,autoPlotType,numAxes)



    nColumns=hObj.getNumColumnsPerVariableInAxes(axesIndex);
    nPlots=sum(nColumns);
    lineProps=initLineProperties(nPlots);


    yData=hObj.Presenter.getAxesYData(axesIndex);
    currAxesMapping=getElement(axesMapping,axesIndex);
    currPlotMapping=getElement(plotMapping,axesIndex);
    plotStartIndex=1;
    for varPos=1:length(yData)
        nCol=nColumns(varPos);
        plotIndices=plotStartIndex:(plotStartIndex+nCol-1);
        oldAxesIndex=currAxesMapping(varPos);
        varInOldAxes=0<oldAxesIndex&&oldAxesIndex<=hObj.MaxNumAxes;
        if varInOldAxes
            oldPlotIndex=currPlotMapping(varPos);
            oldPlotIndices=oldPlotIndex:(oldPlotIndex+nCol-1);
            lineProps=copyOldLinePropertiesForVariable(lineProps,oldLineProps(oldAxesIndex),plotIndices,oldPlotIndices);
        else
            [lineProps,autoPlotType]=copyTopLevelPropertiesForVariable(hObj,lineProps,axesIndex,autoPlotType,plotIndices,varPos,numAxes);
        end


        plotStartIndex=plotStartIndex+nCol;
    end


    seriesIndices=hObj.Presenter.getAxesSeriesIndices(axesIndex);
    if strcmp(lineProps.ColorMode,'auto')
        lineProps.Color=getAutoColor(hObj,lineProps.NumPlots,seriesIndices,'Color');
    end
    if strcmp(lineProps.MarkerEdgeColorMode,'auto')
        lineProps.MarkerEdgeColor=getAutoColor(hObj,lineProps.NumPlots,seriesIndices,'MarkerEdgeColor');
    end
    if strcmp(lineProps.MarkerFaceColorMode,'auto')
        lineProps.MarkerFaceColor=getAutoColor(hObj,lineProps.NumPlots,seriesIndices,'MarkerFaceColor');
    end


    if lineProps.LineStyleMode=="auto"
        lineStyles=hObj.Presenter.getAxesLineStyles(axesIndex);
        lineProps.LineStyle=hObj.LineStyleOrderInternal(rem(lineStyles-1,numel(hObj.LineStyleOrderInternal))+1);
    end

    lineProps=collapseLineProperties(hObj,lineProps);
end

function lineProps=initLineProperties(nPlots)

    lineProps.NumPlots=nPlots;
    lineProps.PlotType=cell(1,nPlots);
    lineProps.Color=zeros(nPlots,3);
    lineProps.ColorMode='auto';
    lineProps.LineStyle=cell(1,nPlots);
    lineProps.LineStyleMode='auto';
    lineProps.LineWidth=zeros(1,nPlots);
    lineProps.MarkerFaceColor=zeros(nPlots,3);
    lineProps.MarkerEdgeColor=zeros(nPlots,3);
    lineProps.MarkerEdgeColorMode='auto';
    lineProps.Marker=cell(1,nPlots);
    lineProps.MarkerSize=zeros(1,nPlots);





    lineProps.MarkerFaceColorMode='manual';
end


function v=getElement(C,i)
    if iscell(C)
        v=C{i};
    else
        v=C(i);
    end
end

function lineProps=copyOldLinePropertiesForVariable(lineProps,oldLineProps,plotIndices,oldPlotIndices)



    if strcmp(oldLineProps.LineStyleMode,'manual')
        lineProps.LineStyleMode='manual';
    end


    lineProps.PlotType(plotIndices)=getOldPropertyForPlot(oldLineProps.PlotType_I,oldPlotIndices);
    lineProps.LineStyle(plotIndices)=getOldPropertyForPlot(oldLineProps.LineStyle_I,oldPlotIndices);
    lineProps.Marker(plotIndices)=getOldPropertyForPlot(oldLineProps.Marker_I,oldPlotIndices);
    lineProps.LineWidth(plotIndices)=getOldPropertyForPlot(oldLineProps.LineWidth_I,oldPlotIndices);
    lineProps.MarkerSize(plotIndices)=getOldPropertyForPlot(oldLineProps.MarkerSize_I,oldPlotIndices);


    if strcmp(oldLineProps.ColorMode,'manual')
        lineProps.ColorMode='manual';
    end
    if strcmp(oldLineProps.MarkerEdgeColorMode,'manual')
        lineProps.MarkerEdgeColorMode='manual';
    end
    if strcmp(oldLineProps.MarkerFaceColorMode,'auto')
        lineProps.MarkerFaceColorMode='auto';
    end


    lineProps=copyOldColor(lineProps,oldLineProps,plotIndices,oldPlotIndices,'Color');
    lineProps=copyOldColor(lineProps,oldLineProps,plotIndices,oldPlotIndices,'MarkerFaceColor');
    lineProps=copyOldColor(lineProps,oldLineProps,plotIndices,oldPlotIndices,'MarkerEdgeColor');
end

function prop=getOldPropertyForPlot(oldProp,oldPlotIndices,matrixFlag)

    if nargin>2&&matrixFlag
        if~isrow(oldProp)
            prop=oldProp(oldPlotIndices,:);
        else
            prop=repmat(oldProp,length(oldPlotIndices),1);
        end
    elseif isnumeric(oldProp)
        if~isscalar(oldProp)
            prop=oldProp(oldPlotIndices);
        else
            prop=oldProp;
        end
    elseif iscell(oldProp)
        prop=oldProp(oldPlotIndices);
    else
        prop={oldProp};
    end
end

function lineProps=copyOldColor(lineProps,oldLineProps,plotIndices,oldPlotIndices,colorPropName)








    oldcolor=oldLineProps.([colorPropName,'_I']);
    if strcmp(lineProps.(colorPropName),'none')||strcmp(oldcolor,'none')
        lineProps.(colorPropName)='none';
    else
        lineProps.(colorPropName)(plotIndices,:)=getOldPropertyForPlot(oldcolor,oldPlotIndices,true);
    end
end

function[lineProps,autoPlotType]=copyTopLevelPropertiesForVariable(hObj,lineProps,axesIndex,autoPlotType,plotIndices,varPos,numAxes)



    lineProps.LineStyle(plotIndices)={hObj.LineStyle};
    lineProps.LineWidth(plotIndices)=hObj.LineWidth;
    lineProps.MarkerSize(plotIndices)=hObj.MarkerSize;
    lineProps.LineStyleMode=hObj.LineStyleMode;


    if isempty(autoPlotType)
        autoPlotType=getAutoPlotType(hObj,numAxes);
    end
    plotType=cellstr(autoPlotType{axesIndex});
    if isscalar(plotType)

        lineProps.PlotType(plotIndices)=plotType;
    else


        lineProps.PlotType(plotIndices)=plotType(varPos);
    end


    lineProps=copyTopLevelColor(hObj,lineProps,plotIndices,'Color');
    lineProps=copyTopLevelColor(hObj,lineProps,plotIndices,'MarkerFaceColor');
    lineProps=copyTopLevelColor(hObj,lineProps,plotIndices,'MarkerEdgeColor');
    lineProps.ColorMode=hObj.ColorMode;
    lineProps.MarkerFaceColorMode=hObj.MarkerFaceColorMode;
    lineProps.MarkerEdgeColorMode=hObj.MarkerEdgeColorMode;



    for i=1:length(plotIndices)
        if lineProps.PlotType{plotIndices(i)}=="scatter"
            lineProps.Marker{plotIndices(i)}='o';
        else
            lineProps.Marker{plotIndices(i)}=hObj.Marker;
        end
    end
end

function autoPlotType=getAutoPlotType(hObj,numAxes)

    autoPlotType=cell(1,numAxes);
    for i=1:numAxes
        autoPlotType{i}=hObj.Presenter.getAxesPlotType(i);
    end
end

function lineProps=copyTopLevelColor(hObj,lineProps,plotIndices,colorPropName)








    if strcmp(lineProps.(colorPropName),'none')||strcmp(hObj.(colorPropName+"_I"),'none')
        lineProps.(colorPropName)='none';
    else
        lineProps.(colorPropName)(plotIndices,:)=repmat(hObj.(colorPropName+"_I"),length(plotIndices),1);
    end
end

function lineProps=collapseLineProperties(hObj,lineProps)



    isMatrix=true;
    if size(hObj.ColorOrderInternal,1)~=1||lineProps.ColorMode=="manual"
        lineProps.Color=collapseLineProperty(lineProps.Color,isMatrix);
    end
    if size(hObj.ColorOrderInternal,1)~=1||lineProps.MarkerFaceColorMode=="manual"
        lineProps.MarkerFaceColor=collapseLineProperty(lineProps.MarkerFaceColor,isMatrix);
    end
    if size(hObj.ColorOrderInternal,1)~=1||lineProps.MarkerEdgeColorMode=="manual"
        lineProps.MarkerEdgeColor=collapseLineProperty(lineProps.MarkerEdgeColor,isMatrix);
    end
    lineProps.LineStyle=collapseLineProperty(lineProps.LineStyle);
    lineProps.LineWidth=collapseLineProperty(lineProps.LineWidth);
    lineProps.Marker=collapseLineProperty(lineProps.Marker);
    lineProps.MarkerSize=collapseLineProperty(lineProps.MarkerSize);
    lineProps.PlotType=collapseLineProperty(lineProps.PlotType);
end



function p=collapseLineProperty(p,matrixFlag)
    if iscell(p)
        if isscalar(unique(p))
            p=p{1};
        end
    elseif nargin>1&&matrixFlag
        if isrow(unique(p,'rows'))
            p=p(1,:);
        end
    else
        if isscalar(unique(p))
            p=p(1);
        end
    end
end

function createOrSetLinePropertiesForAxes(hObj,axesIndex,lineProps)
    props={...
    'AxesIndex',axesIndex,...
    'NumPlots',lineProps.NumPlots,...
    'PlotType_I',lineProps.PlotType,...
    'Color_I',lineProps.Color,...
    'ColorMode',lineProps.ColorMode,...
    'LineStyle_I',lineProps.LineStyle,...
    'LineStyleMode',lineProps.LineStyleMode,...
    'LineWidth_I',lineProps.LineWidth,...
    'MarkerFaceColor_I',lineProps.MarkerFaceColor,...
    'MarkerEdgeColor_I',lineProps.MarkerEdgeColor,...
    'MarkerEdgeColorMode',lineProps.MarkerEdgeColorMode,...
    'MarkerFaceColorMode',lineProps.MarkerFaceColorMode,...
    'Marker_I',lineProps.Marker,...
    'MarkerSize_I',lineProps.MarkerSize...
    };
    if hObj.Presenter.ChartDataChanged
        hObj.LineProperties_I(axesIndex)=matlab.graphics.chart.stackedplot.StackedLineProperties(props{:});
    else
        set(hObj.LineProperties_I(axesIndex),props{:});
    end
end

function updateLinePropertiesListener(hObj)

    if~isempty(hObj.LinePropertiesListener)
        delete(hObj.LinePropertiesListener);
    end
    hObj.LinePropertiesListener=event.listener(hObj.LineProperties_I,...
    'PropertiesChanged',@(~,eventdata)reactToLinePropertiesChanges(hObj,eventdata));
end
