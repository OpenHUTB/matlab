function systemLocation=getDefaultSystemPosition(isTop,screenWidthFraction)










    load_simulink;



    screen=gleeTestInternal.getAvailableGeometryOfScreen();


    screenVMiddle=screen.top+(screen.height/2);

    if isTop
        sysTop=screen.top;
        sysBottom=screenVMiddle;
    else
        sysTop=screenVMiddle;
        sysBottom=screen.bottom;
    end

    sysLeft=screen.left+((1-screenWidthFraction)*screen.width);
    sysRight=screen.right;


    systemLocation=[sysLeft,sysTop,sysRight,sysBottom];
end
