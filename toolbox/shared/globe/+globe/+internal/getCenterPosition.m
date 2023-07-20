function pos=getCenterPosition(windowSize)







    originalUnits=get(0,'units');
    set(0,'units','pixels');


    screenSize=get(0,'ScreenSize');
    posX=(screenSize(3)-windowSize(1))/2;
    posY=(screenSize(4)-windowSize(2))/2;
    pos=[posX,posY,windowSize];


    set(0,'units',originalUnits);
end