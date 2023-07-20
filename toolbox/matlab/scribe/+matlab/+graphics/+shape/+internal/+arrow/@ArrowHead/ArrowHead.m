
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed,Hidden=true)ArrowHead<matlab.graphics.primitive.world.Group





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Angle(1,1)double=0;
    end

    methods
        function valueToCaller=get.Angle(hObj)


            valueToCaller=hObj.Angle_I;

        end

        function set.Angle(hObj,newValue)



            hObj.AngleMode='manual';


            hObj.Angle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AngleMode(hObj)
            storedValue=hObj.AngleMode;
        end

        function set.AngleMode(hObj,newValue)

            oldValue=hObj.AngleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AngleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Angle_I(1,1)double=0;
    end

    methods
        function storedValue=get.Angle_I(hObj)
            storedValue=hObj.Angle_I;
        end

        function set.Angle_I(hObj,newValue)



            hObj.Angle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadContainer matlab.graphics.primitive.Marker;
    end

    methods
        function valueToCaller=get.HeadContainer(hObj)


            valueToCaller=hObj.HeadContainer_I;

        end

        function set.HeadContainer(hObj,newValue)



            hObj.HeadContainerMode='manual';


            hObj.HeadContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadContainerMode(hObj)
            storedValue=hObj.HeadContainerMode;
        end

        function set.HeadContainerMode(hObj,newValue)

            oldValue=hObj.HeadContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        HeadContainer_I;
    end

    methods
        function set.HeadContainer_I(hObj,newValue)
            hObj.HeadContainer_I=newValue;
            try
                hObj.setHeadContainer_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.EdgeColor(hObj)


            valueToCaller=hObj.EdgeColor_I;

        end

        function set.EdgeColor(hObj,newValue)



            hObj.EdgeColorMode='manual';


            hObj.EdgeColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeColorMode(hObj)
            storedValue=hObj.EdgeColorMode;
        end

        function set.EdgeColorMode(hObj,newValue)

            oldValue=hObj.EdgeColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.EdgeColor_I(hObj)
            storedValue=hObj.EdgeColor_I;
        end

        function set.EdgeColor_I(hObj,newValue)



            fanChild=hObj.EdgeHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        EdgeHandle matlab.graphics.primitive.world.LineStrip;
    end

    methods
        function valueToCaller=get.EdgeHandle(hObj)


            valueToCaller=hObj.EdgeHandle_I;

        end

        function set.EdgeHandle(hObj,newValue)



            hObj.EdgeHandleMode='manual';


            hObj.EdgeHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeHandleMode(hObj)
            storedValue=hObj.EdgeHandleMode;
        end

        function set.EdgeHandleMode(hObj,newValue)

            oldValue=hObj.EdgeHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        EdgeHandle_I;
    end

    methods
        function set.EdgeHandle_I(hObj,newValue)
            oldValue=hObj.EdgeHandle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.HeadContainer.replaceChild(hObj.EdgeHandle_I,newValue);
                else

                    hObj.HeadContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.EdgeHandle_I=newValue;
            try
                hObj.setEdgeHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        QuadHandle matlab.graphics.primitive.world.Quadrilateral;
    end

    methods
        function valueToCaller=get.QuadHandle(hObj)


            valueToCaller=hObj.QuadHandle_I;

        end

        function set.QuadHandle(hObj,newValue)



            hObj.QuadHandleMode='manual';


            hObj.QuadHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        QuadHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.QuadHandleMode(hObj)
            storedValue=hObj.QuadHandleMode;
        end

        function set.QuadHandleMode(hObj,newValue)

            oldValue=hObj.QuadHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.QuadHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        QuadHandle_I;
    end

    methods
        function set.QuadHandle_I(hObj,newValue)
            oldValue=hObj.QuadHandle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.HeadContainer.replaceChild(hObj.QuadHandle_I,newValue);
                else

                    hObj.HeadContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.QuadHandle_I=newValue;
            try
                hObj.setQuadHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.FaceColor(hObj)


            valueToCaller=hObj.FaceColor_I;

        end

        function set.FaceColor(hObj,newValue)



            hObj.FaceColorMode='manual';


            hObj.FaceColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceColorMode(hObj)
            storedValue=hObj.FaceColorMode;
        end

        function set.FaceColorMode(hObj,newValue)

            oldValue=hObj.FaceColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.FaceColor_I(hObj)
            storedValue=hObj.FaceColor_I;
        end

        function set.FaceColor_I(hObj,newValue)



            fanChild=hObj.FaceHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.FaceColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceAlpha(1,1)double=1;
    end

    methods
        function valueToCaller=get.FaceAlpha(hObj)


            valueToCaller=hObj.FaceAlpha_I;

        end

        function set.FaceAlpha(hObj,newValue)



            hObj.FaceAlphaMode='manual';


            hObj.FaceAlpha_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceAlphaMode(hObj)
            storedValue=hObj.FaceAlphaMode;
        end

        function set.FaceAlphaMode(hObj,newValue)

            oldValue=hObj.FaceAlphaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceAlphaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceAlpha_I(1,1)double=1;
    end

    methods
        function storedValue=get.FaceAlpha_I(hObj)
            storedValue=hObj.FaceAlpha_I;
        end

        function set.FaceAlpha_I(hObj,newValue)



            hObj.FaceAlpha_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceHandle matlab.graphics.primitive.world.TriangleStrip;
    end

    methods
        function valueToCaller=get.FaceHandle(hObj)


            valueToCaller=hObj.FaceHandle_I;

        end

        function set.FaceHandle(hObj,newValue)



            hObj.FaceHandleMode='manual';


            hObj.FaceHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceHandleMode(hObj)
            storedValue=hObj.FaceHandleMode;
        end

        function set.FaceHandleMode(hObj,newValue)

            oldValue=hObj.FaceHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        FaceHandle_I;
    end

    methods
        function set.FaceHandle_I(hObj,newValue)
            oldValue=hObj.FaceHandle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.HeadContainer.replaceChild(hObj.FaceHandle_I,newValue);
                else

                    hObj.HeadContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.FaceHandle_I=newValue;
            try
                hObj.setFaceHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        HypocycloidN(1,1)double=3;
    end

    methods
        function valueToCaller=get.HypocycloidN(hObj)



            valueToCaller=hObj.getHypocycloidNImpl(hObj.HypocycloidN_I);


        end

        function set.HypocycloidN(hObj,newValue)



            hObj.HypocycloidNMode='manual';



            reallyDoCopy=~isequal(hObj.HypocycloidN_I,newValue);

            if reallyDoCopy
                hObj.HypocycloidN_I=hObj.setHypocycloidNImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HypocycloidNMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HypocycloidNMode(hObj)
            storedValue=hObj.HypocycloidNMode;
        end

        function set.HypocycloidNMode(hObj,newValue)

            oldValue=hObj.HypocycloidNMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HypocycloidNMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HypocycloidN_I(1,1)double=3;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Length(1,1)double=10;
    end

    methods
        function valueToCaller=get.Length(hObj)


            valueToCaller=hObj.Length_I;

        end

        function set.Length(hObj,newValue)



            hObj.LengthMode='manual';


            hObj.Length_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LengthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LengthMode(hObj)
            storedValue=hObj.LengthMode;
        end

        function set.LengthMode(hObj,newValue)

            oldValue=hObj.LengthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LengthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Length_I(1,1)double=10;
    end

    methods
        function storedValue=get.Length_I(hObj)
            storedValue=hObj.Length_I;
        end

        function set.Length_I(hObj,newValue)



            hObj.Length_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='none';
    end

    methods
        function valueToCaller=get.LineStyle(hObj)


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineStyleMode(hObj)
            storedValue=hObj.LineStyleMode;
        end

        function set.LineStyleMode(hObj,newValue)

            oldValue=hObj.LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='none';
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.EdgeHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    methods
        function storedValue=get.LineWidth(hObj)




            passObj=hObj.EdgeHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.LineWidth(hObj,newValue)






            hObj.LineWidthMode='manual';
            hObj.LineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            passObj=hObj.EdgeHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)


            passObj=hObj.EdgeHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            passObj=hObj.EdgeHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)


            passObj=hObj.EdgeHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        RosePQ(1,1)double=2;
    end

    methods
        function valueToCaller=get.RosePQ(hObj)



            valueToCaller=hObj.getRosePQImpl(hObj.RosePQ_I);


        end

        function set.RosePQ(hObj,newValue)



            hObj.RosePQMode='manual';



            reallyDoCopy=~isequal(hObj.RosePQ_I,newValue);

            if reallyDoCopy
                hObj.RosePQ_I=hObj.setRosePQImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        RosePQMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RosePQMode(hObj)
            storedValue=hObj.RosePQMode;
        end

        function set.RosePQMode(hObj,newValue)

            oldValue=hObj.RosePQMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RosePQMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        RosePQ_I(1,1)double=2;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Style matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function valueToCaller=get.Style(hObj)


            valueToCaller=hObj.Style_I;

        end

        function set.Style(hObj,newValue)



            hObj.StyleMode='manual';


            hObj.Style_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        StyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.StyleMode(hObj)
            storedValue=hObj.StyleMode;
        end

        function set.StyleMode(hObj,newValue)

            oldValue=hObj.StyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.StyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Style_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.Style_I(hObj)
            storedValue=hObj.Style_I;
        end

        function set.Style_I(hObj,newValue)



            hObj.Style_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Width(1,1)double=10;
    end

    methods
        function valueToCaller=get.Width(hObj)


            valueToCaller=hObj.Width_I;

        end

        function set.Width(hObj,newValue)



            hObj.WidthMode='manual';


            hObj.Width_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.WidthMode(hObj)
            storedValue=hObj.WidthMode;
        end

        function set.WidthMode(hObj,newValue)

            oldValue=hObj.WidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.WidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Width_I(1,1)double=10;
    end

    methods
        function storedValue=get.Width_I(hObj)
            storedValue=hObj.Width_I;
        end

        function set.Width_I(hObj,newValue)



            hObj.Width_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        X(1,1)double=0;
    end

    methods
        function valueToCaller=get.X(hObj)


            valueToCaller=hObj.X_I;

        end

        function set.X(hObj,newValue)



            hObj.XMode='manual';


            hObj.X_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XMode(hObj)
            storedValue=hObj.XMode;
        end

        function set.XMode(hObj,newValue)

            oldValue=hObj.XMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        X_I(1,1)double=0;
    end

    methods
        function storedValue=get.X_I(hObj)
            storedValue=hObj.X_I;
        end

        function set.X_I(hObj,newValue)



            hObj.X_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Y(1,1)double=0;
    end

    methods
        function valueToCaller=get.Y(hObj)


            valueToCaller=hObj.Y_I;

        end

        function set.Y(hObj,newValue)



            hObj.YMode='manual';


            hObj.Y_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YMode(hObj)
            storedValue=hObj.YMode;
        end

        function set.YMode(hObj,newValue)

            oldValue=hObj.YMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Y_I(1,1)double=0;
    end

    methods
        function storedValue=get.Y_I(hObj)
            storedValue=hObj.Y_I;
        end

        function set.Y_I(hObj,newValue)



            hObj.Y_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'HeadContainer')
                b=true;
                return;
            end
            if strcmp(name,'HeadContainer_I')
                b=true;
                return;
            end
            if strcmp(name,'EdgeHandle')
                b=true;
                return;
            end
            if strcmp(name,'EdgeHandle_I')
                b=true;
                return;
            end
            if strcmp(name,'QuadHandle')
                b=true;
                return;
            end
            if strcmp(name,'QuadHandle_I')
                b=true;
                return;
            end
            if strcmp(name,'FaceHandle')
                b=true;
                return;
            end
            if strcmp(name,'FaceHandle_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.primitive.world.Group(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=ArrowHead(varargin)






            hObj.HeadContainer_I=matlab.graphics.primitive.Marker;

            set(hObj.HeadContainer,'Description_I','ArrowHead HeadContainer');

            set(hObj.HeadContainer,'Internal',true);

            hObj.EdgeHandle_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.EdgeHandle,'Description_I','ArrowHead EdgeHandle');

            set(hObj.EdgeHandle,'Internal',true);

            hObj.QuadHandle_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.QuadHandle,'Description_I','ArrowHead QuadHandle');

            set(hObj.QuadHandle,'Internal',true);

            hObj.FaceHandle_I=matlab.graphics.primitive.world.TriangleStrip;

            set(hObj.FaceHandle,'Description_I','ArrowHead FaceHandle');

            set(hObj.FaceHandle,'Internal',true);


            hObj.LineWidth_I=0.5;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setHeadContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setEdgeHandle_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.EdgeHandle,hObj.EdgeColor_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.EdgeHandle,hObj.LineStyle_I);

        end
    end
    methods(Access=private)
        function setQuadHandle_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setFaceHandle_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.FaceHandle,hObj.FaceColor_I);

        end
    end


    methods(Access='private',Hidden=true)
        function varargout=getHypocycloidNImpl(hObj,storedValue)
            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setHypocycloidNImpl(hObj,newValue)

            newValue=floor(newValue);
            if newValue<3
                newValue=3;
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getRosePQImpl(hObj,storedValue)
            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setRosePQImpl(hObj,newValue)

            if newValue<0
                newValue=0;
            elseif mod(newValue,2)>0
                newValue=2*floor(newValue/2);
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.HeadContainer_I.XLimInclude='off';
            hObj.HeadContainer_I.YLimInclude='off';
            hObj.HeadContainer_I.ZLimInclude='off';
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)

            set(hObj.HeadContainer,'Anchor',[hObj.X,hObj.Y,0]);


            theta=hObj.Angle;
            costh=cos(theta);
            sinth=sin(theta);


            L=hObj.Length;
            W=hObj.Width/2;
            style=hObj.Style;
            switch(style)
            case 'plain'
                x=[-L,0,-L];
                y=[W,0,-W];
            case{'vback1','vback2','vback3'}
                narrowfrx=.75;
                d=[.15,.35,.8];b={'vback1','vback2','vback3'};
                depth=d(strcmp(b,style));
                x=[-L,0;0,-L;-(1-depth)*L,-(1-depth)*L];
                y=narrowfrx.*[W,0;0,-W;0,0];
            case 'diamond'
                x=[-L/2,-L/2;0,-L;-L/2,-L/2];
                y=[W,-W;0,0;-W,W];
            case 'rectangle'
                x=[-L,0;0,-L;0,-L];
                y=[W,-W;W,-W;-W,W];
            case 'fourstar'
                x=[-L/3,-L/2,-L,-L/2,-(2*L/3),-(2*L/3);
                0,-L/3,-(2*L/3),-(2*L/3),-(2*L/3),-L/3;
                -L/3,-(2*L/3),-(2*L/3),-L/3,-L/3,-L/3];
                y=[W/2,W,0,-W,-W/3,W/3;
                0,W/3,W/3,-W/3,W/3,W/3;
                -W/3,W/3,-W/3,-W/3,-W/3,-W/3];
            case{'cback1','cback2','cback3'}
                d=[.1,.25,.6];b={'cback1','cback2','cback3'};
                depth=d(strcmp(b,style));
                Y=pi/2:pi/40:3*pi/2;
                X=cos(Y);
                xbot=3;
                xoff=2*depth;
                X=(-1*xoff).*X;
                Y=Y./pi-1;
                Y=Y.*2*W;
                X=X.*(L/3);
                X=X+-L;
                xtip=xbot*(L/3)-L;
                ytip=0;
                x=zeros(3,length(X)-1);y=zeros(3,length(X)-1);
                for i=1:length(X)-1
                    x(:,i)=[xtip;X(i);X(i+1)];
                    y(:,i)=[ytip;Y(i);Y(i+1)];
                end
            case 'ellipse'

                xstart=L/2;ystart=0;
                x=zeros(3,39);y=zeros(3,39);
                for i=1:39
                    th=i*pi/20;
                    x(:,i)=[xstart;L/2*cos(th);L/2*cos(th+pi/20)];
                    y(:,i)=[ystart;W*sin(th);W*sin(th+pi/20)];
                end

                x=x-L/2;
            case 'rose'


                pq=hObj.RosePQ;
                xstart=sin(pi/4).*cos(pq*pi/4)*L/2;
                ystart=cos(pi/4).*cos(pq*pi/4)*W;
                x=zeros(3,39);y=zeros(3,39);
                delta_t=pi/20;
                for i=1:39
                    t1=pi/4+i*delta_t;
                    t2=t1+delta_t;
                    x1=sin(t1).*cos(pq*t1)*L/2;
                    x2=sin(t2).*cos(pq*t2)*L/2;
                    y1=cos(t1).*cos(pq*t1)*W;
                    y2=cos(t2).*cos(pq*t2)*W;
                    x(:,i)=[xstart;x1;x2];
                    y(:,i)=[ystart;y1;y2];
                end
                x=x-L/2;
            case 'hypocycloid'
                N=hObj.HypocycloidN;
                a=1;
                b=1/N;
                xstart=(a-2*b);ystart=0;
                x=zeros(3,12*N-1);y=zeros(3,12*N-1);
                delta_t=pi/(6*N);

                for i=1:12*N-1
                    t1=i*delta_t;
                    t2=t1+delta_t;
                    x1=(a-b)*cos(t1)-b*cos(((a-b)/b)*t1);
                    x2=(a-b)*cos(t2)-b*cos(((a-b)/b)*t2);
                    y1=(a-b)*sin(t1)+b*sin(((a-b)/b)*t1);
                    y2=(a-b)*sin(t2)+b*sin(((a-b)/b)*t2);
                    x(:,i)=[xstart;x1;x2];
                    y(:,i)=[ystart;y1;y2];
                end
                if mod(N,2)==0


                    phi=pi/N;cosphi=cos(phi);sinphi=sin(phi);
                    xx=x.*cosphi-y.*sinphi;
                    yy=x.*sinphi+y.*cosphi;
                    x=xx;
                    y=yy;
                else


                    x=-x;
                end
                x=x*L/2;
                y=y*W;
                x=x-L/2;
            case 'astroid'
                N=4;
                a=1;
                b=1/N;
                xstart=(a-2*b);ystart=0;
                x=zeros(3,47);y=zeros(3,47);
                delta_t=pi/24;
                for i=1:47
                    t1=i*delta_t;
                    t2=t1+delta_t;
                    x1=(a-b)*cos(t1)-b*cos(((a-b)/b)*t1);
                    x2=(a-b)*cos(t2)-b*cos(((a-b)/b)*t2);
                    y1=(a-b)*sin(t1)+b*sin(((a-b)/b)*t1);
                    y2=(a-b)*sin(t2)+b*sin(((a-b)/b)*t2);
                    x(:,i)=[xstart;x1;x2];
                    y(:,i)=[ystart;y1;y2];
                end



                phi=pi/N;cosphi=cos(phi);sinphi=sin(phi);
                xx=x.*cosphi-y.*sinphi;
                yy=x.*sinphi+y.*cosphi;
                x=xx;
                y=yy;
                x=x*L/2;
                y=y*W;
                x=x-L/2;
            case 'deltoid'
                N=3;
                a=1;
                b=1/N;

                xstart=(a-2*b);ystart=0;
                x=zeros(3,35);y=zeros(3,35);
                delta_t=pi/18;
                for i=1:35
                    t1=i*delta_t;
                    t2=t1+delta_t;
                    x1=(a-b)*cos(t1)-b*cos(((a-b)/b)*t1);
                    x2=(a-b)*cos(t2)-b*cos(((a-b)/b)*t2);
                    y1=(a-b)*sin(t1)+b*sin(((a-b)/b)*t1);
                    y2=(a-b)*sin(t2)+b*sin(((a-b)/b)*t2);
                    x(:,i)=[xstart;x1;x2];
                    y(:,i)=[ystart;y1;y2];
                end



                x=-x;
                x=x*L/2;
                y=y*W;
                x=x-L/2;
            case 'none'
                x=0;y=0;
            end


            xx=x.*costh-y.*sinth;
            yy=x.*sinth+y.*costh;



            [vertices,faces]=convertXYZToFaceVertex(xx,yy);
            hIterator=matlab.graphics.axis.dataspace.XYZPointsIterator;
            hIterator.XData=vertices(:,1);
            hIterator.YData=vertices(:,2);
            hIterator.ZData=vertices(:,3);


            vertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hIterator);


            if size(faces,2)<3
                vertexData=[];
                faces=[];
            end

            hFace=hObj.FaceHandle;
            hFace.VertexData=vertexData;



            if~strcmpi(hObj.FaceColor,'none')
                faceColor=hFace.ColorData_I;
                alpha=min(1,hObj.FaceAlpha);
                alpha=max(0,alpha);
                faceColor(4)=uint8(255*alpha);
                hFace.ColorData_I=faceColor;
                hFace.ColorType_I='truecoloralpha';
            end


            hLine=hObj.EdgeHandle;


            numPoints=size(vertexData,2);
            numFaces=size(faces,1);
            edgeVertexData=zeros(3,numPoints+numFaces,'single');
            currIndex=1;
            for i=1:numPoints
                edgeVertexData(:,currIndex)=vertexData(:,i);
                currIndex=currIndex+1;
                if mod(i,3)==0
                    edgeVertexData(:,currIndex)=vertexData(:,i-2);
                    currIndex=currIndex+1;
                end
            end
            hLine.VertexData=edgeVertexData;

            hLine.StripData=uint32(1:4:size(edgeVertexData,2)+1);





            hFig=ancestor(hObj,'figure');
            if hObj.LineWidth>=2&&...
                (strcmpi(hFig.Renderer,'none')||strcmpi(hFig.Renderer,'opengl'))
                if strcmpi(style,'plain')
                    outlineEdgeVertexData=edgeVertexData;
                elseif any(strcmp(style,{'vback1','vback2','vback3'}))








                    outlineEdgeVertexData=edgeVertexData(:,[1,2,6,3,1]);
                else
                    hObj.QuadHandle.Visible='off';
                    hObj.EdgeHandle.Visible='on';
                    return
                end
                hObj.EdgeHandle.Visible='off';


                quadVertexData=matlab.graphics.shape.internal.arrow.ArrowHead.doLineVertToQuadVert(outlineEdgeVertexData,single(hObj.LineWidth));
                hObj.QuadHandle.VertexData=quadVertexData;

                hObj.QuadHandle.StripData=uint32(1:4:4*(1+size(quadVertexData,2)/4));
                hObj.QuadHandle.ColorData=hObj.EdgeHandle.ColorData;
                hObj.QuadHandle.ColorBinding=hObj.EdgeHandle.ColorBinding;
                hObj.QuadHandle.Visible='on';

            else
                hObj.QuadHandle.Visible='off';
                hObj.EdgeHandle.Visible='on';
            end

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getOffset(hObj)

            L=hObj.Length;
            style=hObj.Style;
            switch(style)
            case 'none'
                varargout{1}=0;
            case{'plain','diamond','fourstar','ellipse','rectangle','rose'}
                varargout{1}=L;
            case{'vback1','vback2','vback3'}
                d=[.15,.35,.8];
                b={'vback1','vback2','vback3'};
                varargout{1}=(1-d(strcmp(b,style)))*L;
            case{'cback1','cback2','cback3'}
                d=[.1,.25,.6];
                b={'cback1','cback2','cback3'};
                depth=d(strcmp(b,style));
                varargout{1}=(1-depth)*L;
            case 'hypocycloid'
                N=hObj.HypocycloidN;



                if mod(N,2)>0
                    varargout{1}=((N-1)/N)*L;
                else
                    varargout{1}=L;
                end
            case 'astroid'
                varargout{1}=L;
            case 'deltoid'
                varargout{1}=2*L/3;
            end
        end
    end
    methods(Access='private',Static=true,Hidden=true)
        function varargout=computeJoinVertices(lineVertices,w)

            P1=lineVertices(:,1);
            P2=lineVertices(:,2);
            P3=lineVertices(:,3);
            uBasis=(P2-P3)/norm(P2-P3);
            vBasis=-cross(uBasis,[0,0,1]');

            theta=matlab.graphics.shape.internal.arrow.ArrowHead.getLineAngle(lineVertices);
            v1=lineVertices(:,2)-(w/(2*tan(theta)))*uBasis+(w/2)*vBasis;
            v3=v1-w*vBasis+uBasis*w/tan(theta);


            lambda=-cross(v3-P1,P2-P1);
            if lambda(3)>0
                vertices=[v3,v1];
            else
                vertices=[v1,v3];
            end
            varargout{1}=vertices;
        end
    end
    methods(Access='private',Static=true,Hidden=true)
        function varargout=getLineAngle(vertexTriple)

            P1=vertexTriple(:,1);
            P2=vertexTriple(:,2);
            P3=vertexTriple(:,3);
            costheta=((P2-P3)'*(P2-P1))/...
            (norm(P2-P3)*norm(P2-P1));
            theta=acos(costheta)/2;
            varargout{1}=theta;
        end
    end
    methods(Access='private',Static=true,Hidden=true)
        function varargout=doLineVertToQuadVert(lineVertices,w)












            n=size(lineVertices,2)-1;







            if isequal(lineVertices(:,end),lineVertices(:,1))


                theta=matlab.graphics.shape.internal.arrow.ArrowHead.getLineAngle(lineVertices(:,[size(lineVertices,2)-1,1,2]));
                w=min([w,2*tan(theta)*norm(lineVertices(:,size(lineVertices,2)-1)-lineVertices(:,1)),...
                2*tan(theta)*norm(lineVertices(:,1)-lineVertices(:,2))]);
            end

            for k=1:size(lineVertices,2)-2
                theta=matlab.graphics.shape.internal.arrow.ArrowHead.getLineAngle(lineVertices(:,k:k+2));
                w=min([w,2*tan(theta)*norm(lineVertices(:,k+2)-lineVertices(:,k+1)),...
                2*tan(theta)*norm(lineVertices(:,k)-lineVertices(:,k+1))]);
            end

            if isequal(lineVertices(:,end),lineVertices(:,1))


                theta=matlab.graphics.shape.internal.arrow.ArrowHead.getLineAngle(lineVertices(:,[size(lineVertices,2)-1,1,2]));
                w=min([w,2*tan(theta)*norm(lineVertices(:,size(lineVertices,2)-1)-lineVertices(:,1)),...
                2*tan(theta)*norm(lineVertices(:,2)-lineVertices(:,1))]);
            end

            quadVertices=zeros(3,n*4,'single');


            if isequal(lineVertices(:,end),lineVertices(:,1))



                quadVertices(:,[2,1])=matlab.graphics.shape.internal.arrow.ArrowHead.computeJoinVertices(lineVertices(:,[n,1,2]),single(w));
            else
                n1=cross(lineVertices(:,2)-lineVertices(:,1),[0;0;1]);
                n1=-n1/norm(n1);
                quadVertices(:,1:2)=[lineVertices(:,1)-w/2*n1,lineVertices(:,1)+w/2*n1];
            end



            quadVertices(:,[4,3])=matlab.graphics.shape.internal.arrow.ArrowHead.computeJoinVertices(lineVertices(:,1:3),single(w));



            for k=2:size(lineVertices,2)-2



                quadVertices(:,(4*k-2):-1:(4*k-3))=matlab.graphics.shape.internal.arrow.ArrowHead.computeJoinVertices(lineVertices(:,k-1:k+1),single(w));
                quadVertices(:,(4*k):-1:(4*k-1))=matlab.graphics.shape.internal.arrow.ArrowHead.computeJoinVertices(lineVertices(:,k:k+2),single(w));
            end


            quadVertices(:,(4*size(lineVertices,2)-6):-1:(4*size(lineVertices,2)-7))=...
            matlab.graphics.shape.internal.arrow.ArrowHead.computeJoinVertices(lineVertices(:,end-2:end),single(w));
            if isequal(lineVertices(:,end),lineVertices(:,1))
                quadVertices(:,4*size(lineVertices,2)-5:4*size(lineVertices,2)-4)=...
                quadVertices(:,[1,2]);
            else
                n2=cross(lineVertices(:,end)-lineVertices(:,end-1),[0;0;1]);
                n2=-n2/norm(n2);
                quadVertices(:,4*size(lineVertices,2)-5:4*size(lineVertices,2)-4)=...
                [lineVertices(:,end)+w/2*n2,lineVertices(:,end)-w/2*n2];
            end
            varargout{1}=quadVertices;

        end
    end




end
