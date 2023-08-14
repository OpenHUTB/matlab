





classdef(Abstract)ScatterPlotLayer<handle
    properties
ScatterObject
    end

    properties(Access=protected)
MATLABFigureAxes
        SizeData=36
    end

    events
DatatipRequest
    end

    methods(Abstract)



        updateXData(obj,data,runId);



        updateYData(obj,data,runId);


        replaceXData(obj,data);


        replaceYData(obj,data);
    end

    methods(Abstract,Access=protected)

        scatterClick(obj,scatterPlot,evt);
    end
end
