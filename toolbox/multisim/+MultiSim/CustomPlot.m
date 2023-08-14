classdef(Abstract)CustomPlot<handle



















    properties(Hidden,SetAccess=?simmanager.designview.FigureManager)
PlotConfigId
    end



    properties(GetAccess=protected,...
        SetAccess=?simmanager.designview.internal.CustomPlot)
MATLABFigure
    end



    methods(Abstract)
        setup(obj,simIn)
        update(obj,simOut,runId)
    end



end