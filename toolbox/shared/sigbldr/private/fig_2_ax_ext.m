function Ext=fig_2_ax_ext(Fext,axesH)




    axPos=get(axesH,'Position');
    xLim=get(axesH,'XLim');
    yLim=get(axesH,'YLim');
    conv2points=[axPos(3)/diff(xLim),axPos(4)/diff(yLim)];

    Ext=Fext./conv2points;