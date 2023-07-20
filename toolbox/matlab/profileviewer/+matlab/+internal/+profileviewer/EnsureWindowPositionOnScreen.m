function position=EnsureWindowPositionOnScreen(position)







    if usejava('mwt')
        point=java.awt.Point(position(1),position(2));
        dimension=java.awt.Dimension(position(3),position(4));
        pointToBeUsed=com.mathworks.mwswing.WindowUtils.ensureOnScreen(point,dimension,0);
        position=[pointToBeUsed.x,pointToBeUsed.y,position(3),position(4)];
    else
        displayRect=convertToDisplayRect(position);

        primaryScreenId=pf.display.getPrimaryScreen();
        primaryScreenConfig=pf.display.getConfig(primaryScreenId);
        screenBounds=primaryScreenConfig.availableScreenSize;

        isAlreadyOnScreen=displayRect.x>=screenBounds.x&&displayRect.x+displayRect.width<=screenBounds.x+screenBounds.width...
        &&displayRect.y>=screenBounds.y&&displayRect.y+displayRect.height<=screenBounds.y+screenBounds.height;

        if~isAlreadyOnScreen
            updatedDisplayRect=pf.display.onScreenRect(displayRect,screenBounds,1);
            position=convertFromDisplayRect(updatedDisplayRect);
        end
    end
end

function rect=convertToDisplayRect(position)
    rect=pf.display.DisplayRect;
    rect.x=position(1);
    rect.y=position(2);
    rect.width=position(3);
    rect.height=position(4);
end

function position=convertFromDisplayRect(rect)
    position=[rect.x,rect.y,rect.width,rect.height];
end