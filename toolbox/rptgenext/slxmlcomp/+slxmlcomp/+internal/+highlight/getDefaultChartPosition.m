function chartPosition=getDefaultChartPosition(isTop,screenWidthFraction)










    load_simulink;



    screen=gleeTestInternal.getAvailableGeometryOfScreen();


    screenVMiddle=screen.top+(screen.height/2);

    if isTop
        chartTop=screen.top;
    else
        chartTop=screenVMiddle;
    end

    chartLeft=screen.left+((1-screenWidthFraction)*screen.width);
    chartWidth=screen.width/2;
    chartHeight=screen.height/2;


    chartPosition=[chartLeft,chartTop,chartWidth,chartHeight];
end
