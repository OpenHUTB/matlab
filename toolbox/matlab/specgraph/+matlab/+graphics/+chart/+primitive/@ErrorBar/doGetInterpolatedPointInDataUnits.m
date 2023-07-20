function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)






    interp=0;

    yData=double(hObj.YDataCache);
    xData=double(hObj.XDataCache);
    xNeg=abs(double(hObj.XNegativeDeltaCache));
    xPos=abs(double(hObj.XPositiveDeltaCache));
    yNeg=abs(double(hObj.YNegativeDeltaCache));
    yPos=abs(double(hObj.YPositiveDeltaCache));


    numPoints=numel(yData);
    if numel(xData)~=numPoints||...
        (~isempty(xNeg)&&numel(xNeg)~=numPoints)||...
        (~isempty(xPos)&&numel(xPos)~=numPoints)||...
        (~isempty(yNeg)&&numel(yNeg)~=numPoints)||...
        (~isempty(yPos)&&numel(yPos)~=numPoints)


        index=1;
        return
    end






    if strcmpi(hObj.LineStyle,'none')
        xd=zeros(0,1);
        yd=zeros(0,1);
        map=zeros(0,1);
    else
        xd=[xData';NaN];
        yd=[yData';NaN];
        map=[(1:numPoints)';NaN];
    end


    [xd,yd,map]=addSegments(xd,yd,map,xData,yData,xNeg,-1,0);
    [xd,yd,map]=addSegments(xd,yd,map,xData,yData,xPos,1,0);
    [xd,yd,map]=addSegments(xd,yd,map,xData,yData,yNeg,0,-1);
    [xd,yd,map]=addSegments(xd,yd,map,xData,yData,yPos,0,1);


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    [index1,index2,t]=utils.nearestSegment(hObj,position,false,xd,yd);


    if t<=0.5
        index=index1;
    else
        index=index2;
    end

    if isempty(index)
        index=1;
    end


    index=map(index);

end

function[xd,yd,map]=addSegments(xd,yd,map,xData,yData,delta,xsign,ysign)




    if~isempty(delta)
        numPoints=numel(xData);
        x=[xData;xData+xsign*delta;NaN(1,numPoints)];
        y=[yData;yData+ysign*delta;NaN(1,numPoints)];
        m=[1:numPoints;1:numPoints;NaN(1,numPoints)];

        xd=[xd;x(:)];
        yd=[yd;y(:)];
        map=[map;m(:)];
    end
end
