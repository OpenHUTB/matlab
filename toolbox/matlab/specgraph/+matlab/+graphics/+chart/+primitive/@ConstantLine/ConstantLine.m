
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed,Hidden=true)ConstantLine<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Legendable





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1];
    end

    methods
        function valueToCaller=get.Color(hObj)


            valueToCaller=hObj.Color_I;

        end

        function set.Color(hObj,newValue)



            hObj.ColorMode='manual';


            hObj.Color_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColorMode(hObj)
            storedValue=hObj.ColorMode;
        end

        function set.ColorMode(hObj,newValue)

            oldValue=hObj.ColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=false)

        XData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function valueToCaller=get.XData(hObj)



            valueToCaller=hObj.getXDataImpl(hObj.XData_I);


        end

        function set.XData(hObj,newValue)



            hObj.XDataMode='manual';



            reallyDoCopy=~isequal(hObj.XData_I,newValue);

            if reallyDoCopy
                hObj.XData_I=hObj.setXDataImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XDataMode(hObj)
            storedValue=hObj.XDataMode;
        end

        function set.XDataMode(hObj,newValue)

            oldValue=hObj.XDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XData_I matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=false)

        YData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function valueToCaller=get.YData(hObj)



            valueToCaller=hObj.getYDataImpl(hObj.YData_I);


        end

        function set.YData(hObj,newValue)



            hObj.YDataMode='manual';



            reallyDoCopy=~isequal(hObj.YData_I,newValue);

            if reallyDoCopy
                hObj.YData_I=hObj.setYDataImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YDataMode(hObj)
            storedValue=hObj.YDataMode;
        end

        function set.YDataMode(hObj,newValue)

            oldValue=hObj.YDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YData_I matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods





    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=false,AffectsLegend)

        ZData matlab.internal.datatype.matlab.graphics.datatype.VectorData=zeros(1,0);
    end

    methods
        function storedValue=get.ZData(hObj)
            storedValue=hObj.ZData;
        end

        function set.ZData(hObj,newValue)



            hObj.ZData=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        XDataCache;
    end

    methods
        function valueToCaller=get.XDataCache(hObj)

            valueToCaller=hObj.XData;
        end

        function set.XDataCache(hObj,newValue)

            hObj.XData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        YDataCache;
    end

    methods
        function valueToCaller=get.YDataCache(hObj)

            valueToCaller=hObj.YData;
        end

        function set.YDataCache(hObj,newValue)

            hObj.YData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        ZDataCache;
    end

    methods
        function valueToCaller=get.ZDataCache(hObj)

            valueToCaller=hObj.ZData;
        end

        function set.ZDataCache(hObj,newValue)

            hObj.ZData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
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

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
    end

    methods
        function valueToCaller=get.LineWidth(hObj)


            valueToCaller=hObj.LineWidth_I;

        end

        function set.LineWidth(hObj,newValue)



            hObj.LineWidthMode='manual';


            hObj.LineWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            storedValue=hObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)

            oldValue=hObj.LineWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            storedValue=hObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    methods
        function valueToCaller=get.Marker(hObj)


            valueToCaller=hObj.Marker_I;

        end

        function set.Marker(hObj,newValue)



            hObj.MarkerMode='manual';


            hObj.Marker_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerMode(hObj)
            storedValue=hObj.MarkerMode;
        end

        function set.MarkerMode(hObj,newValue)

            oldValue=hObj.MarkerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    methods
        function storedValue=get.Marker_I(hObj)
            storedValue=hObj.Marker_I;
        end

        function set.Marker_I(hObj,newValue)



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('MarkerStyleToPrimMarkerStyle',fanChild,newValue);
            end
            hObj.Marker_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    methods
        function storedValue=get.MarkerSize(hObj)




            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Size;
        end

        function set.MarkerSize(hObj,newValue)






            hObj.MarkerSizeMode='manual';
            hObj.MarkerSize_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerSizeMode(hObj)
            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.SizeMode;
        end

        function set.MarkerSizeMode(hObj,newValue)


            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.SizeMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    methods
        function storedValue=get.MarkerSize_I(hObj)
            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Size_I;
        end

        function set.MarkerSize_I(hObj,newValue)


            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Size_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='auto';
    end

    methods
        function valueToCaller=get.MarkerEdgeColor(hObj)


            valueToCaller=hObj.MarkerEdgeColor_I;

        end

        function set.MarkerEdgeColor(hObj,newValue)



            hObj.MarkerEdgeColorMode='manual';


            hObj.MarkerEdgeColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerEdgeColorMode(hObj)
            storedValue=hObj.MarkerEdgeColorMode;
        end

        function set.MarkerEdgeColorMode(hObj,newValue)

            oldValue=hObj.MarkerEdgeColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerEdgeColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='auto';
    end

    methods
        function storedValue=get.MarkerEdgeColor_I(hObj)
            storedValue=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor_I(hObj,newValue)



            hObj.MarkerEdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='none';
    end

    methods
        function valueToCaller=get.MarkerFaceColor(hObj)


            valueToCaller=hObj.MarkerFaceColor_I;

        end

        function set.MarkerFaceColor(hObj,newValue)



            hObj.MarkerFaceColorMode='manual';


            hObj.MarkerFaceColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerFaceColorMode(hObj)
            storedValue=hObj.MarkerFaceColorMode;
        end

        function set.MarkerFaceColorMode(hObj,newValue)

            oldValue=hObj.MarkerFaceColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerFaceColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='none';
    end

    methods
        function storedValue=get.MarkerFaceColor_I(hObj)
            storedValue=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor_I(hObj,newValue)



            hObj.MarkerFaceColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        MarkerHandle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.MarkerHandle(hObj)


            valueToCaller=hObj.MarkerHandle_I;

        end

        function set.MarkerHandle(hObj,newValue)



            hObj.MarkerHandleMode='manual';


            hObj.MarkerHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerHandleMode(hObj)
            storedValue=hObj.MarkerHandleMode;
        end

        function set.MarkerHandleMode(hObj,newValue)

            oldValue=hObj.MarkerHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        MarkerHandle_I;
    end

    methods
        function set.MarkerHandle_I(hObj,newValue)
            hObj.MarkerHandle_I=newValue;
            try
                hObj.setMarkerHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Edge matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Edge(hObj)


            valueToCaller=hObj.Edge_I;

        end

        function set.Edge(hObj,newValue)



            hObj.EdgeMode='manual';


            hObj.Edge_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeMode(hObj)
            storedValue=hObj.EdgeMode;
        end

        function set.EdgeMode(hObj,newValue)

            oldValue=hObj.EdgeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Edge_I;
    end

    methods
        function set.Edge_I(hObj,newValue)
            hObj.Edge_I=newValue;
            try
                hObj.setEdge_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.Clipping(hObj)


            valueToCaller=hObj.Clipping_I;

        end

        function set.Clipping(hObj,newValue)



            hObj.ClippingMode='manual';


            hObj.Clipping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ClippingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ClippingMode(hObj)
            storedValue=hObj.ClippingMode;
        end

        function set.ClippingMode(hObj,newValue)

            oldValue=hObj.ClippingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ClippingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Clipping_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.Clipping_I(hObj)
            storedValue=hObj.Clipping_I;
        end

        function set.Clipping_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            hObj.Clipping_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Value matlab.internal.datatype.matlab.graphics.datatype.VectorData=0.0;
    end

    methods
        function valueToCaller=get.Value(hObj)


            valueToCaller=hObj.Value_I;

        end

        function set.Value(hObj,newValue)



            hObj.ValueMode='manual';


            hObj.Value_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ValueMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ValueMode(hObj)
            storedValue=hObj.ValueMode;
        end

        function set.ValueMode(hObj,newValue)

            oldValue=hObj.ValueMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ValueMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Value_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=0.0;
    end

    methods
        function storedValue=get.Value_I(hObj)
            storedValue=hObj.Value_I;
        end

        function set.Value_I(hObj,newValue)



            hObj.Value_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        DependVar matlab.internal.datatype.matlab.graphics.chart.datatype.BaseLineOrientation='y';
    end

    methods
        function storedValue=get.DependVar(hObj)
            storedValue=hObj.DependVar;
        end

        function set.DependVar(hObj,newValue)



            hObj.DependVar=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        SelectionHandle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.SelectionHandle(hObj)


            valueToCaller=hObj.SelectionHandle_I;

        end

        function set.SelectionHandle(hObj,newValue)



            hObj.SelectionHandleMode='manual';


            hObj.SelectionHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        SelectionHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SelectionHandleMode(hObj)
            storedValue=hObj.SelectionHandleMode;
        end

        function set.SelectionHandleMode(hObj,newValue)

            oldValue=hObj.SelectionHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SelectionHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        SelectionHandle_I;
    end

    methods
        function set.SelectionHandle_I(hObj,newValue)
            hObj.SelectionHandle_I=newValue;
            try
                hObj.setSelectionHandle_IFanoutProps();
            catch
            end
        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'MarkerHandle')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandle_I')
                b=true;
                return;
            end
            if strcmp(name,'Edge')
                b=true;
                return;
            end
            if strcmp(name,'Edge_I')
                b=true;
                return;
            end
            if strcmp(name,'SelectionHandle')
                b=true;
                return;
            end
            if strcmp(name,'SelectionHandle_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.primitive.Data(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=ConstantLine(varargin)






            hObj.MarkerHandle_I=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','ConstantLine MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Edge,'Description_I','ConstantLine Edge');

            set(hObj.Edge,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','ConstantLine SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);


            hObj.MarkerSize_I=6;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setMarkerHandle_IFanoutProps(hObj)

            try
                mode=hObj.MarkerHandle.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'LineWidth_I',hObj.LineWidth_I);
            end


            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker_I);

        end
    end
    methods(Access=private)
        function setEdge_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.Color_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle_I);


            try
                mode=hObj.Edge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'LineWidth_I',hObj.LineWidth_I);
            end


            try
                mode=hObj.Edge.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'Clipping_I',hObj.Clipping_I);
            end

        end
    end
    methods(Access=private)
        function setSelectionHandle_IFanoutProps(hObj)
        end
    end


    methods(Access='public',Hidden=true)
        function varargout=getXYZDataExtents(hObj)

            if strcmpi(hObj.DependVar,'y')
                varargout{1}=[matlab.graphics.chart.primitive.utilities.arraytolimits(NaN);...
                matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.Value);...
                matlab.graphics.chart.primitive.utilities.arraytolimits(0)];
            else
                varargout{1}=[matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.Value);...
                matlab.graphics.chart.primitive.utilities.arraytolimits(NaN);...
                matlab.graphics.chart.primitive.utilities.arraytolimits(0)];
            end
        end
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)

            hObj.addDependencyConsumed({'dataspace','hgtransform_under_dataspace','xyzdatalimits'});
            hObj.Type='line';
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getXDataImpl(hObj,storedValue)

            ax=ancestor(hObj,'axes');
            if isempty(ax)
                varargout{1}=[];
                return;
            end
            hDataSpace=ax.DataSpace;
            if isempty(hDataSpace)
                varargout{1}=[];
                return;
            end

            val=hObj.Value;
            if strcmpi(hObj.DependVar,'y')

                if length(val)==1
                    varargout{1}=hDataSpace.XLim;
                else
                    varargout{1}=repmat([hDataSpace.XLim,NaN],1,length(val));
                end
            else
                if length(val)==1
                    varargout{1}=[val,val];
                else
                    varargout{1}=reshape([repmat(val(:)',2,1);repmat(NaN,1,length(val))],1,length(val)*3);
                end
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setXDataImpl(hObj,newValue)


            varargout{1}=[];
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYDataImpl(hObj,storedValue)

            ax=ancestor(hObj,'axes');
            if isempty(ax)
                varargout{1}=[];
                return;
            end
            hDataSpace=ax.DataSpace;
            if isempty(hDataSpace)
                varargout{1}=[];
                return;
            end

            val=hObj.Value;
            if strcmpi(hObj.DependVar,'x')

                if length(val)==1
                    varargout{1}=hDataSpace.YLim;
                else
                    varargout{1}=repmat([hDataSpace.YLim,NaN],1,length(val));
                end
            else
                if length(val)==1
                    varargout{1}=[val,val];
                else
                    varargout{1}=reshape([repmat(val(:)',2,1);repmat(NaN,1,length(val))],1,length(val)*3);
                end
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYDataImpl(hObj,newValue)


            varargout{1}=[];
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=changedependvar(hObj,newvar)

            hObj.DependVar=newvar;
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)

            hDataSpace=updateState.DataSpace;




            hPar=hObj.Parent;
            if strcmpi(hObj.ColorMode,'auto')&&isprop(hPar,'XColor')
                hObj.Color_I=hPar.XColor;
            end

            if strcmpi(updateState.DataSpace.isLinear,'on')


                hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                if strcmpi(hObj.DependVar,'y')
                    hIter.XData=repmat(hDataSpace.XLim,[1,length(hObj.Value)]);
                    hIter.YData=reshape([hObj.Value(:)';hObj.Value(:)'],1,2*length(hObj.Value));
                else
                    hIter.YData=repmat(hDataSpace.YLim,[1,length(hObj.Value)]);
                    hIter.XData=reshape([hObj.Value(:)';hObj.Value(:)'],1,2*length(hObj.Value));
                end
                hIter.ZData=zeros(1,2*length(hObj.Value));

                vertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,hIter);

                hObj.Edge.VertexData=vertexData;
                hObj.Edge.StripData=uint32(1:2:(2*length(hObj.Value)+1));
                hObj.SelectionHandle.VertexData=vertexData;
            else
                vertexData=zeros(3,0);
                stripdata=uint32(1);
                if strcmpi(hObj.DependVar,'y')
                    for k=1:length(hObj.Value)
                        vertexData=[vertexData,TransformLine(updateState.DataSpace,updateState.TransformUnderDataSpace,[hDataSpace.XLim(:),[hObj.Value(k);hObj.Value(k)],[0;0]])];
                        stripdata=[stripdata,uint32(size(vertexData,2)+1)];
                    end
                else
                    for k=1:length(hObj.Value)
                        vertexData=[vertexData,TransformLine(updateState.DataSpace,updateState.TransformUnderDataSpace,[[hObj.Value(k);hObj.Value(k)],hDataSpace.YLim(:),[0;0]])];
                        stripdata=[stripdata,uint32(size(vertexData,2)+1)];
                    end
                end
                hObj.Edge.VertexData=single(vertexData);
                hObj.Edge.StripData=stripdata;
                hObj.SelectionHandle.VertexData=single(vertexData);
            end
            hObj.MarkerHandle.VertexData=single(vertexData);


            mec=hObj.MarkerEdgeColor;
            if strcmpi(mec,'auto')
                mec=hObj.Color;
            end
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec);

            mfc=hObj.MarkerFaceColor;
            if strcmpi(mfc,'auto');
                mfc=mec;
            end
            hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                hObj.SelectionHandle.Visible='on';
            else
                hObj.SelectionHandle.Visible='off';
            end
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=mcodeIgnoreHandle(hObj,hOther)
    end




end
