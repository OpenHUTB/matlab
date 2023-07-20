function systemLocation=getDefaultSystemPosition(isTop,screenWidthFraction)








    screen=struct('left',0,'top',0,'width',1024,'height',768);


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
