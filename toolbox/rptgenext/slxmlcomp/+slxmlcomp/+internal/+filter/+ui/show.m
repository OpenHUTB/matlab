function show(url,debugPort)



    ww=matlab.internal.webwindow(url,debugPort,getUIGeometry());
    ww.bringToFront();
    slxmlcomp.internal.filter.ui.Dialogs.put(url,ww);

end

function geometry=getUIGeometry()
    width=800;
    height=500;


    ss=get(0,'ScreenSize');
    screen.Width=ss(3);
    screen.Height=ss(4);



    fudgeFactor=50;
    width=min(screen.Width-fudgeFactor,width);
    height=min(screen.Height-fudgeFactor,height);

    x=(screen.Width-width)/2;
    y=(screen.Height-height)/2;

    geometry=[x,y,width,height];
end

