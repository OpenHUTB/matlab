function[p,g]=createDefaultLayers()

    Lp=0.075;
    Wp=0.0375;
    p1=antenna.Rectangle('Center',[0,0],'Length',Lp,'Width',Wp,'NumPoints',[10,20,10,20]);
    p=p1;

    Lgp=0.15;
    Wgp=0.075;
    g1=antenna.Rectangle('Center',[0,0],'Length',Lgp,'Width',Wgp,'NumPoints',10);
    g=g1;
end