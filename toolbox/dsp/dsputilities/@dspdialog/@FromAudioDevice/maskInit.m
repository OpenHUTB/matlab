function icon=maskInit()





    xrbase=[.65,.65,.575,.525,.525,.65,.725,.8,.875...
    ,.9,.9,.975,.975,.84,.84,.83,.8,.725,.65,.525];
    xlbase=1-fliplr(xrbase);
    yrbase=[.02,.17,.245,.245,.47,.49,.525,.59,.695...
    ,.845,.995,.995,1.35,1.35,.995,.845,.695,.61,.56,.54];
    ylbase=fliplr(yrbase);
    xrmic=[.575,.65,.725,.75,.785,.785,.75,.725,.65,.575];
    xlmic=1-fliplr(xrmic);
    yrmic=[.59,.62,.695,.77,.845,[1.445,1.52,1.595,1.67,1.7]+.25]+.06;
    ylmic=fliplr(yrmic);
    xrbar=[.785,.785];
    xlbar=[1-.785,1-.785];
    yrbar=[.995,1.2];
    ylbar=[1.2,.995];

    icon.x=[xrmic,xlmic];
    icon.y=[yrmic,ylmic];
    icon.x1=[xrbase,xlbase];
    icon.y1=[yrbase,ylbase];
    icon.x2=[xrbar,xlbar];
    icon.y2=[yrbar,ylbar]+.1;
    icon.x3=1.6;
    icon.y3=(max(yrbar)-min(yrbar))/2;

end
