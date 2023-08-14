function desc=doGetDataDescriptors(hObj,index,~)










    numPoints=numel(hObj.XData);
    if index>0&&index<=numPoints


        xData=hObj.XData(index);
        if isnumeric(xData)
            xData=double(xData);
        end

        yData=hObj.YData(index);
        if isnumeric(yData)
            yData=double(yData);
        end

        yOffsetVec=hObj.YOffset;
        if isempty(yOffsetVec)
            yOffset=0;
        else
            yOffset=double(yOffsetVec(index));
        end
    else
        xData=NaN;
        yData=NaN;
        yOffset=NaN;
    end

    if strcmpi(hObj.Horizontal,'on')
        if strcmpi(hObj.BarLayout,'grouped')
            xVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',yData);
            yVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',xData);
        else
            xsegVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X (Segment)',yData);


            if~isnumeric(yData)
                yData=double(hObj.YDataCache(index));
                [xVal,~,~]=matlab.graphics.internal.makeNonNumeric(hObj,yData+yOffset,xData,0);
            else
                xVal=yData+yOffset;
            end

            xVals=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X (Stacked)',xVal)...
            ,xsegVals];

            yVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',xData);
        end
    else
        if strcmpi(hObj.BarLayout,'grouped')
            xVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',xData);
            yVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',yData);
        else
            xVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',xData);
            ySegVals=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y (Segment)',yData);



            if~isnumeric(yData)
                yData=double(hObj.YDataCache(index));
                [~,yVal,~]=matlab.graphics.internal.makeNonNumeric(hObj,xData,yData+yOffset,0);
            else
                yVal=yData+yOffset;
            end

            yVals=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y (Stacked)',yVal)...
            ,ySegVals];

        end
    end

    desc=[xVals,yVals];
end


