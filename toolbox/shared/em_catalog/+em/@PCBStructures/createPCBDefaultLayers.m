function[m,d,g]=createPCBDefaultLayers()

    Lm=20e-3;
    Wm=5e-3;
    m=traceRectangular('Length',Lm,'Width',Wm,'Center',[0,0]);
    m.PointDistribution=[10,2,10,2];


    d=dielectric('Teflon');
    d.Thickness=1.6e-3;

    Lgp=Lm;
    Wgp=6*Wm;
    g=traceRectangular('Length',Lgp,'Width',Wgp,'Center',[0,0]);

end