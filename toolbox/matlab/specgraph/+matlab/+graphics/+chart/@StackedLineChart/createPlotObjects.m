function createPlotObjects(hObj)




    numAxes=hObj.getNumAxesCapped();
    if numAxes>0
        hPlots=allocatePlotObjects(hObj,numAxes);
        disableDataCursor(hPlots);
        hObj.Plots=hPlots;
        updateDataCursor(hObj);
    end
end

function hPlots=allocatePlotObjects(hObj,numAxes)
    import matlab.graphics.chart.primitive.Scatter
    import matlab.graphics.chart.primitive.Stair
    import matlab.graphics.chart.primitive.Line
    for i=numAxes:-1:1
        numPlots=hObj.NumPlotsInAxes(i);
        plotTypes=hObj.LineProperties_I(i).PlotType;
        for j=1:numPlots
            if iscell(plotTypes)
                plotType=plotTypes{j};
            else
                plotType=plotTypes;
            end
            if plotType=="scatter"
                hPlots{i}(j)=Scatter;
            elseif plotType=="stairs"
                hPlots{i}(j)=Stair;
            else
                hPlots{i}(j)=Line;
            end
        end
    end
end

function disableDataCursor(hPlots)
    for i=1:length(hPlots)
        for j=1:length(hPlots{i})
            cursor=hggetbehavior(hPlots{i}(j),'DataCursor');
            cursor.Enable=false;
            cursor.Serialize=false;
        end
    end
end

function updateDataCursor(hObj)
    if~isempty(hObj.DataCursor)
        hObj.DataCursor.updateAxes();
    end
end
