function dd=doGetDataDescriptors(hObj,index,~)







    yData=hObj.YData_I;
    xData=hObj.XData_I;
    yNeg=hObj.YNegativeDelta_I;
    yPos=hObj.YPositiveDelta_I;
    xNeg=hObj.XNegativeDelta_I;
    xPos=hObj.XPositiveDelta_I;


    numPoints=numel(xData);
    if index>0&&index<=numPoints
        x=xData(index);
        y=yData(index);
    else
        x=NaN;
        y=NaN;
    end


    xVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',x);
    yVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',y);

    dd=[xVal,yVal];

    if index<=0||index>numPoints
        return
    end


    dd=[dd,makeDataDescriptor('X Delta',xNeg,xPos,index)];
    dd=[dd,makeDataDescriptor('Y Delta',yNeg,yPos,index)];

end

function dd=makeDataDescriptor(str,neg,pos,index)


    if~isempty(neg)||~isempty(pos)


        val=[];
        if~isempty(neg)
            val=-abs(neg(index));
        end
        if~isempty(pos)
            val=[val,abs(pos(index))];
        end
        dd=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(str,val);
    else

        dd=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
    end

end
