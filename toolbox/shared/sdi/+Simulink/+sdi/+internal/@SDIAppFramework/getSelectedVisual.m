function ret=getSelectedVisual(this,varargin)

    plotIdx=Simulink.sdi.getSelectedPlot(this.Engine_.sigRepository);
    [row,col]=Simulink.sdi.internal.Util.getRowColFromSubPlotIndex(plotIdx);
    ret=sdi_visuals.getVisualizationID(0,row,col);
end