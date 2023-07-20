function algLoop=highlightNoneGraphicalLoop(algLoop,index,totalLoops)

    import Simulink.Structure.Utils.*

    f=figure('visible','off');
    cmap=colormap(f);
    close(f);

    if nargin<2
        index=algLoop.Id(2);
        totalLoops=index+1;
    end

    lcolor=getColorFromColorMap(cmap,index,0,totalLoops);

    tag=strcat(int2str(algLoop.Id(1)),'#',int2str(algLoop.Id(2)));


    options={'blockFillColor',lcolor,'tag',tag};
    style=highlightObjs([],algLoop.BlockHandles',options{:});
    algLoop.hstyle=[algLoop.hstyle;style];
end