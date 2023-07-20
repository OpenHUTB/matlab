classdef(ConstructOnLoad,AllowedSubclasses={?matlab.graphics.shape.internal.PointTipLocator,...
    ?matlab.graphics.chart.internal.heatmap.Highlight,...
    ?matlab.graphics.chart.internal.parallelplot.Highlight})...
    TipLocator<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Selectable















    properties(Abstract)

        Position matlab.internal.datatype.matlab.graphics.datatype.Point3


        Size matlab.internal.datatype.matlab.graphics.datatype.Positive


        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle


        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor
    end
end
