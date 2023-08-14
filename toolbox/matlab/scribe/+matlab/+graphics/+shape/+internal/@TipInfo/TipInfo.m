classdef(ConstructOnLoad,AllowedSubclasses={?matlab.graphics.shape.internal.GraphicsTip,?matlab.graphics.shape.internal.PanelTip})...
    TipInfo<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Selectable
















    properties(Abstract)

        BackgroundAlpha(1,1)double


        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle


        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName


        FontUnits matlab.internal.datatype.matlab.graphics.datatype.FontUnits


        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive


        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight


        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter


        Position matlab.internal.datatype.matlab.graphics.datatype.Point3


String


        TargetType matlab.internal.datatype.unicodeString


        LocatorSize matlab.internal.datatype.matlab.graphics.datatype.Positive


        Orientation matlab.internal.datatype.matlab.graphics.chart.datatype.TipOrientationType


        CurrentTip matlab.internal.datatype.matlab.graphics.datatype.on_off
    end
end
