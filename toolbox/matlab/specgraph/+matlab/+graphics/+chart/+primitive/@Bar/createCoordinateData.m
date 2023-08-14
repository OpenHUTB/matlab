function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)



















    import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
    coordinateData=CoordinateData.empty(0,1);

    if dataIndex>0&&dataIndex<=numel(hObj.XData)
        xCoord=hObj.XData(dataIndex);
        if isnumeric(xCoord)
            xCoord=double(xCoord);
        end

        yCoord=hObj.YData(dataIndex);
        if isnumeric(yCoord)
            yCoord=double(yCoord);
        end

        yOffsetVec=hObj.YOffset;
        if isempty(yOffsetVec)
            yOffset=0;
        else
            yOffset=double(yOffsetVec(dataIndex));
        end
    else
        xCoord=NaN;
        yCoord=NaN;
        yOffset=NaN;
    end


    isBarHorizontal=strcmpi(hObj.Horizontal,'on');

    if strcmpi(hObj.BarLayout,'grouped')

        if isBarHorizontal
            if strcmpi(valueSource,'XData')
                coordinateData=CoordinateData(valueSource,yCoord);
            elseif strcmpi(valueSource,'YData')
                coordinateData=CoordinateData(valueSource,xCoord);
            end
        else
            if strcmpi(valueSource,'XData')
                coordinateData=CoordinateData(valueSource,xCoord);
            elseif strcmpi(valueSource,'YData')
                coordinateData=CoordinateData(valueSource,yCoord);
            end
        end
    else


        if~isnumeric(yCoord)
            if strcmpi(hObj.Horizontal,'on')
                [yStackedVal,~,~]=matlab.graphics.internal.makeNonNumeric(hObj,yCoord+yOffset,[],[]);
            else
                [~,yStackedVal,~]=matlab.graphics.internal.makeNonNumeric(hObj,[],yCoord+yOffset,[]);
            end
        else
            yStackedVal=yCoord+yOffset;
        end

        if isBarHorizontal
            if strcmpi(valueSource,'X (Stacked)')
                coordinateData=CoordinateData(valueSource,yStackedVal);
            elseif strcmpi(valueSource,'X (Segment)')
                coordinateData=CoordinateData(valueSource,yCoord);
            elseif strcmpi(valueSource,'YData')
                coordinateData=CoordinateData(valueSource,xCoord);
            end
        else
            if strcmpi(valueSource,'XData')
                coordinateData=CoordinateData(valueSource,xCoord);
            elseif strcmpi(valueSource,'Y (Stacked)')
                coordinateData=CoordinateData(valueSource,yStackedVal);
            elseif strcmpi(valueSource,'Y (Segment)')
                coordinateData=CoordinateData(valueSource,yCoord);
            end
        end
    end