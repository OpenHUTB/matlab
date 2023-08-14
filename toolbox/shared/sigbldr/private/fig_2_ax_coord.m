function P=fig_2_ax_coord(Pfig,axesH)





    axPos=get(axesH,'Position');
    xLim=get(axesH,'XLim');
    yLim=get(axesH,'YLim');
    conv2points=[axPos(3)/diff(xLim),axPos(4)/diff(yLim)];

    P=[xLim(1),yLim(1)]+(Pfig-axPos(1:2))./conv2points;