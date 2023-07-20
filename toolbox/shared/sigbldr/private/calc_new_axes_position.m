function position=calc_new_axes_position(axesExtent,geomConst,numAxes,index)







    xvalue=axesExtent(1)+geomConst.axesOffset(1);
    startY=axesExtent(2)+geomConst.axesOffset(2);
    width=axesExtent(3)-geomConst.axesOffset(1);
    totalY=axesExtent(4);

    pureAxesY=totalY-geomConst.axesOffset(2)-...
    (numAxes-1)*geomConst.axesVdelta;

    allProportions=ones(1,numAxes)*(1/numAxes);

    height=allProportions(index)*pureAxesY;
    startY=startY+sum(allProportions(1:(index-1)))*pureAxesY+...
    (index-1)*geomConst.axesVdelta;

    position=[xvalue,startY,width,height];
