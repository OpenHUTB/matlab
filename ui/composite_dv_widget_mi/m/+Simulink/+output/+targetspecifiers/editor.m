function spec=editor(context)


    handleType=get_param(context,'type');
    switch handleType
    case 'block'
        [topLeft,bottomRight]=getBlockCorners(context);
    case 'line'
        [topLeft,bottomRight]=getPointerLocation();
    end

    spec=Simulink.output.PositionSpecification;
    spec.setPreferredSide(Simulink.output.utils.PreferredSide.RIGHT);
    spec.setTopLeftAndBottomRightCorners(topLeft,bottomRight);
end

function[topLeft,bottomRight]=getBlockCorners(handle)
    parentHandle=get_param(get_param(handle,'parent'),'handle');
    blockGeom=SLM3I.Util.getBlockScreenCoordinates(parentHandle,handle);
    topLeft=blockGeom(1:2);
    width=blockGeom(3);
    height=blockGeom(4);
    bottomRight=[topLeft(1)+width,topLeft(2)+height];

    topLeft=topLeft-5;
    bottomRight=bottomRight+5;
end

function[topLeft,bottomRight]=getPointerLocation()

    mouseLoc=get(0,'PointerLocation');
    screenCoordinates=get(0,'ScreenSize');
    mouseX=mouseLoc(1);
    pos(1)=mouseX;
    mouseY=screenCoordinates(4)-mouseLoc(2);
    pos(2)=mouseY;
    topLeft=pos;
    bottomRight=topLeft;
end


