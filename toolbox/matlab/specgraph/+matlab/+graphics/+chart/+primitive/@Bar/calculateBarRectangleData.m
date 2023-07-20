function[xData,xDataLeft,xDataRight,yDataBottom,yDataTop,order]=calculateBarRectangleData(hObj,BaseValues)




    if strcmpi(hObj.Horizontal,'off')
        basevalue=BaseValues(2);
    else
        basevalue=BaseValues(1);
    end

    xData=double(hObj.XDataCache);
    yData=double(hObj.YDataCache);
    xOffset=double(hObj.XOffset);
    yOffset=double(hObj.YOffset);



    nx=numel(xData);
    if nx~=numel(yData)||nx==0
        xData=zeros(1,0);
        yData=zeros(1,0);
        yOffset=zeros(1,0);
    end



    yDataBottom=basevalue*ones(size(yData));
    yDataTop=yData;


    if numel(yOffset)==numel(yData)

        yDataTop=yOffset+yData;


        yOffset(yOffset==0)=basevalue;
        yDataBottom=yOffset;
    end


    [xData,order]=sort(xData);
    yDataTop=yDataTop(order);
    yDataBottom=yDataBottom(order);




    barWidth=abs(hObj.BarWidth*hObj.WidthScaleFactor);


    xData=xData+xOffset;
    xDataLeft=xData-barWidth/2;
    xDataRight=xData+barWidth/2;
