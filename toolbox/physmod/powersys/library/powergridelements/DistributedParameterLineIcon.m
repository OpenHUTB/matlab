function DistributedParameterLineIcon(block)





    nphase=max(1,getSPSmaskvalues(block,{'Phases'}));

    if nphase==1
        set_param(block,'MaskIconFrame','off')
        PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+20,0,0,100,40);color(''red'');port_label(''Lconn'',1,''+'')';
    end

    if nphase==2
        set_param(block,'MaskIconFrame','off')
        PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+90,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+30,0,0,100,120);color(''red'');port_label(''Lconn'',1,''+'')';
    end

    if nphase==3
        set_param(block,'MaskIconFrame','off')
        PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+100,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+60,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+20,0,0,100,120);color(''red'');port_label(''Lconn'',1,''+'')';
    end
    if nphase>3
        set_param(block,'MaskIconFrame','on')
        PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],([0 0 5 5 0 0 0 -5 -5 0]+50),-10,0,110,100);color(''red'');port_label(''Lconn'',1,''+'')';
    end
    set_param(block,'Maskdisplay',PlotIcon);