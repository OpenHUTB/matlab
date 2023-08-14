function truthTablePosition=getDefaultUIPosition(isTop,screenWidthFraction)




    screen=gleeTestInternal.getAvailableGeometryOfScreen();


    frameVMiddle=screen.top+((1-screenWidthFraction)*screen.height);

    if isTop
        frameY=screen.top;
    else
        frameY=frameVMiddle;
    end

    frameX=screen.left+(screen.width/2);
    frameWidth=screen.width/2;
    frameHeight=screen.height/2;

    truthTablePosition=double([frameX,frameY,frameWidth,frameHeight]);

end