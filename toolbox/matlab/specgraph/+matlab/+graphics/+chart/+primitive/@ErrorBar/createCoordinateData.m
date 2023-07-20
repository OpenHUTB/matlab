function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)











    import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
    coordinateData=CoordinateData.empty(0,1);

    if dataIndex<=0||dataIndex>numel(hObj.XData_I)
        coordinateData=CoordinateData(valueSource,NaN);
        return;
    end

    switch(valueSource)
    case 'XData'
        coordinateData=CoordinateData(valueSource,hObj.XData_I(dataIndex));
    case 'YData'
        coordinateData=CoordinateData(valueSource,hObj.YData_I(dataIndex));
    case 'X Delta'
        xDeltaVal=[];
        if~isempty(hObj.XNegativeDelta_I)||~isempty(hObj.XPositiveDelta_I)
            if~isempty(hObj.XNegativeDelta_I)

                xDeltaVal=-abs(hObj.XNegativeDelta_I(dataIndex));
            end
            if~isempty(hObj.XPositiveDelta_I)

                xDeltaVal=[xDeltaVal,abs(hObj.XPositiveDelta_I(dataIndex))];
            end

            coordinateData=CoordinateData(valueSource,xDeltaVal);
        end
    case 'Y Delta'

        yDeltaVal=[];
        if~isempty(hObj.YNegativeDelta_I)||~isempty(hObj.YPositiveDelta_I)
            if~isempty(hObj.YNegativeDelta_I)

                yDeltaVal=-abs(hObj.YNegativeDelta_I(dataIndex));
            end
            if~isempty(hObj.YPositiveDelta_I)

                yDeltaVal=[yDeltaVal,abs(hObj.YPositiveDelta_I(dataIndex))];
            end

            coordinateData=[coordinateData,CoordinateData('Y Delta',yDeltaVal)];
        end
    end