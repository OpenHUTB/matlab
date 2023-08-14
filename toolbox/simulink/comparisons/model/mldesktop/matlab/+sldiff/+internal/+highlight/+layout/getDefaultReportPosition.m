function position=getDefaultReportPosition(screenWidthFraction)





    load_simulink;
    screen=gleeTestInternal.getAvailableGeometryOfScreen();
    x=screen.left;
    y=screen.top;
    width=screen.width*screenWidthFraction;
    height=screen.height;

    position=[x,y,width,height].*GLUE2.Util.getDpiScale();

end
