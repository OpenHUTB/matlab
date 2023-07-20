function[xData,yData,lineStripData,xBarData,yBarData,...
    vBarIndices,hBarIndices]=createErrorBarVertices(hObj,hDataSpace)





    yData=double(hObj.YDataCache);
    xData=double(hObj.XDataCache);


    numPoints=numel(yData);
    if numel(xData)~=numPoints

        error(message('MATLAB:errorbar:XDataSizeMismatch'));
    end


    deltaProperties={'XNegativeDelta','XPositiveDelta','YNegativeDelta','YPositiveDelta'};
    for p=1:numel(deltaProperties)
        propName=[deltaProperties{p},'_I'];
        if~isempty(hObj.(propName))&&numel(hObj.(propName))~=numPoints
            error(message('MATLAB:errorbar:DeltaSizeMismatch',deltaProperties{p}));
        end
    end



    if isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')

        invalidX=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.XScale,hDataSpace.XLim,xData);
        invalidY=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.YScale,hDataSpace.YLim,yData);

        invalidData=invalidX|invalidY;
        xData(invalidData)=NaN;
        yData(invalidData)=NaN;
    end


    validLine=isfinite(xData)&isfinite(yData);
    if all(validLine)
        lineStripData=uint32([1,numPoints+1]);
    else
        xData=xData(validLine);
        yData=yData(validLine);
        numPoints=numel(yData);







        lineSegmentStart=[true,~validLine(1:end-1)];
        lineSegmentStart=[lineSegmentStart(validLine),true];
        lineStripData=uint32(find(lineSegmentStart));
    end


    xNeg=abs(double(hObj.XNegativeDeltaCache));
    xPos=abs(double(hObj.XPositiveDeltaCache));
    yNeg=abs(double(hObj.YNegativeDeltaCache));
    yPos=abs(double(hObj.YPositiveDeltaCache));


    if isempty(xNeg)
        xBarData=zeros(1,0);
        yBarData=zeros(1,0);
        stripData=zeros(1,0);
        horzData=true(1,0);
    else
        xBarData=xData-xNeg(validLine);
        yBarData=yData;
        stripData=1:numPoints;
        horzData=true(1,numPoints);
    end

    if~isempty(xPos)
        xBarData=[xBarData,xData+xPos(validLine)];
        yBarData=[yBarData,yData];
        stripData=[stripData,1:numPoints];
        horzData=[horzData,true(1,numPoints)];
    end

    if~isempty(yNeg)
        xBarData=[xBarData,xData];
        yBarData=[yBarData,yData-yNeg(validLine)];
        stripData=[stripData,1:numPoints];
        horzData=[horzData,false(1,numPoints)];
    end

    if~isempty(yPos)
        xBarData=[xBarData,xData];
        yBarData=[yBarData,yData+yPos(validLine)];
        stripData=[stripData,1:numPoints];
        horzData=[horzData,false(1,numPoints)];
    end



    if isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')

        invalidXBar=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.XScale,hDataSpace.XLim,xBarData);
        invalidYBar=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.YScale,hDataSpace.YLim,yBarData);

        invalidBarData=invalidXBar|invalidYBar;
        xBarData(:,invalidBarData)=NaN;
        yBarData(:,invalidBarData)=NaN;
    end


    validData=isfinite(xBarData)&isfinite(yBarData);
    xBarData=xBarData(validData);
    yBarData=yBarData(validData);
    stripData=stripData(validData);
    horzData=horzData(validData);




    xBarData=[xData,xBarData];
    yBarData=[yData,yBarData];


    if any(horzData)
        hBarIndices=uint32([stripData(horzData);numPoints+find(horzData)]);
    else
        hBarIndices=zeros(2,0,'uint32');
    end


    if any(~horzData)
        vBarIndices=uint32([stripData(~horzData);numPoints+find(~horzData)]);
    else
        vBarIndices=zeros(2,0,'uint32');
    end

end
