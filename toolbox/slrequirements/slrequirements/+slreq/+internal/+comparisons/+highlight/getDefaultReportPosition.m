function position=getDefaultReportPosition(screenWidthFraction)







    screen=struct('left',0,'top',0,'width',1024,'height',768);
    x=screen.left;
    y=screen.top;
    width=screen.width*screenWidthFraction;
    height=screen.height;

    position=[x,y,width,height].*GLUE2.Util.getDpiScale();

end
