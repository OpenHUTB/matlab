function setSignalChecked(this,varargin)
    assert(length(varargin)==2);
    id=varargin{1};
    value=varargin{2};

    plotIdx=Simulink.sdi.getSelectedPlot(this.Engine_.sigRepository);
    [row,col]=Simulink.sdi.internal.Util.getRowColFromSubPlotIndex(plotIdx);
    visParams=sdi_visuals.listVisualParams(0,row,col);
    if~isempty(visParams)
        error(message('SimulinkHMI:errors:NotSupportedForVisual'));
    end
    this.Engine_.setSignalChecked(id,value);
end