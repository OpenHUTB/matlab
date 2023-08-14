function[minX,minY,maxWidth,maxHeight]=findExtents(this)








    borderWidth=10;
    set(this.fig,'Units','Pixels');
    figSize=get(this.fig,'Position');




    set(this.statLabel,'Units','Pixels');
    statLabelPos=get(this.statLabel,'Position');

    botPos=statLabelPos(2)+statLabelPos(4);
    minX=borderWidth;
    minY=botPos+borderWidth;
    maxWidth=max(figSize(3)-2*borderWidth,0);
    maxHeight=max(figSize(4)-minY-borderWidth,0);

end