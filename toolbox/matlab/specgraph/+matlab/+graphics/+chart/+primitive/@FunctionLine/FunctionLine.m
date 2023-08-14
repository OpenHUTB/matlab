
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed,Hidden=true)FunctionLine<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Legendable&matlab.graphics.chart.internal.ExtentVisitorExcludable





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

        Function;
    end

    methods
        function valueToCaller=get.Function(hObj)


            valueToCaller=hObj.Function_I;

        end

        function set.Function(hObj,newValue)



            hObj.FunctionMode='manual';


            hObj.Function_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FunctionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FunctionMode(hObj)
            storedValue=hObj.FunctionMode;
        end

        function set.FunctionMode(hObj,newValue)

            oldValue=hObj.FunctionMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FunctionMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Function_I;
    end

    methods
        function storedValue=get.Function_I(hObj)
            storedValue=hObj.Function_I;
        end

        function set.Function_I(hObj,newValue)



            hObj.Function_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Granularity(1,1)int32=300;
    end

    methods
        function storedValue=get.Granularity(hObj)
            storedValue=hObj.Granularity;
        end

        function set.Granularity(hObj,newValue)



            hObj.Granularity=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        UserArgs={};
    end

    methods
        function valueToCaller=get.UserArgs(hObj)


            valueToCaller=hObj.UserArgs_I;

        end

        function set.UserArgs(hObj,newValue)



            hObj.UserArgsMode='manual';


            hObj.UserArgs_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        UserArgsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.UserArgsMode(hObj)
            storedValue=hObj.UserArgsMode;
        end

        function set.UserArgsMode(hObj,newValue)

            oldValue=hObj.UserArgsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.UserArgsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        UserArgs_I={};
    end

    methods
        function storedValue=get.UserArgs_I(hObj)
            storedValue=hObj.UserArgs_I;
        end

        function set.UserArgs_I(hObj,newValue)



            hObj.UserArgs_I=newValue;

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
        function hObj=FunctionLine(varargin)






            hObj.MarkerHandle_I=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','FunctionLine MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Edge,'Description_I','FunctionLine Edge');

            set(hObj.Edge,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','FunctionLine SelectionHandle');

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

            ax=ancestor(hObj,'axes');
            if~isempty(ax)
                if strcmpi(ax.XLimMode,'manual')
                    xlims=ax.XLim;
                else
                    if~isequal(ax.Children,hObj)
                        axesXLim=ax.DataSpace.XLim;
                        peerExtents=matlab.graphics.chart.internal.ChartHelpers.getChildExtentsWithExclusion(ax.ChildContainer,'matlab.graphics.chart.internal.ExtentVisitorExcludable');
                        if strcmpi(ax.DataSpace.XLimSpec,'tightmin')
                            xlims=[peerExtents(1,1),axesXLim(2)];
                        elseif strcmpi(ax.DataSpace.XLimSpec,'tightmax')
                            xlims=[axesXLim(1),peerExtents(2,1)];
                        else
                            xlims=peerExtents(:,1)';
                        end
                    else
                        xlims=[0,1];
                    end
                end
            else
                xlims=[0,1];
            end

            if strcmpi(get(hObj,'YLimInclude'),'off')

                ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(NaN);
            else
                [~,ydata]=calcXYData(hObj,xlims);
                ydata=matlab.graphics.chart.primitive.utilities.preprocessextents(ydata(:));
                if~isempty(ydata)
                    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(ydata);
                else
                    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(NaN);
                end
            end
            xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(NaN);
            zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(0);
            varargout{1}=[xlim;ylim;zlim];
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=calcXYData(hObj,xlims)

            gran=hObj.Granularity;
            if gran<1||length(xlims)<2
                varargout{1}=[];
                varargout{2}=[];
                return
            end


            x=linspace(xlims(2),xlims(1),gran);
            if~isempty(hObj.Function)&&iscell(hObj.UserArgs)
                try
                    varargout{2}=feval(hObj.Function,x,hObj.UserArgs{:});
                catch me
                    error(message('MATLAB:FunctionLine:doUpdate',me.message));
                end
                varargout{1}=x;
            else
                varargout{1}=[];
                varargout{2}=[];
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

            varargout{1}=hObj.calcXYData(hDataSpace.XLim);
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

            x=hObj.XData;
            [~,varargout{1}]=hObj.calcXYData([min(x(:)),max(x(:))]);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYDataImpl(hObj,newValue)


            varargout{1}=[];
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)




            hPar=hObj.Parent;
            if strcmpi(hObj.ColorMode,'auto')&&isprop(hPar,'XColor')
                hObj.Color_I=hPar.XColor;
            end



            gran=hObj.Granularity;
            if gran<1
                hObj.Edge.VertexData=[];
                hObj.Edge.StripData=[];
                hObj.MarkerHandle.VertexData=[];
                hObj.SelectionHandle.VertexData=[];
                if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                    hObj.SelectionHandle.Visible='on';
                else
                    hObj.SelectionHandle.Visible='off';
                end
                return;
            end


            xdata=linspace(updateState.DataSpace.XLim(1),updateState.DataSpace.XLim(2),gran);
            if~isempty(hObj.Function)&&iscell(hObj.UserArgs)
                ua=hObj.UserArgs;
                try
                    ydata=feval(hObj.Function,xdata,ua{:});

                catch me
                    error(message('MATLAB:FunctionLine:doUpdate',me.message));
                end

            else
                ydata=[];
            end

            if isempty(xdata)||isempty(ydata)||~isequal(size(xdata),size(ydata))
                hObj.Edge.VertexData=[];
                hObj.Edge.StripData=[];
                hObj.MarkerHandle.VertexData=[];
                hObj.SelectionHandle.VertexData=[];
                if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                    hObj.SelectionHandle.Visible='on';
                else
                    hObj.SelectionHandle.Visible='off';
                end
                return;
            end

            if strcmpi(updateState.DataSpace.isLinear,'on')


                hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;

                Ifinite=isfinite(ydata);
                if all(Ifinite)
                    stripData=uint32([1,length(ydata)+1]);
                else
                    xdata=xdata(Ifinite);
                    ydata=ydata(Ifinite);
                    stripData=unique([1,find(~Ifinite)-(0:(sum(~Ifinite)-1)),length(ydata)+1]);
                end

                hIter.XData=xdata;
                hIter.YData=ydata;
                hIter.ZData=zeros(size(xdata));

                vertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,hIter);

                hObj.Edge.VertexData=single(vertexData);
                hObj.Edge.StripData=uint32(stripData);
                hObj.SelectionHandle.VertexData=single(vertexData);
            else

                if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
                    if strcmp('log',get(updateState.DataSpace,'XScale'))&&~all(xdata<0)
                        xdata(xdata<=0)=NaN;
                    end
                    if strcmp('log',get(updateState.DataSpace,'YScale'))&&~all(ydata<0)
                        ydata(ydata<=0)=NaN;
                    end
                end

                vertexData=zeros(3,0);
                for k=1:length(ydata)-1
                    vertexData=[vertexData,TransformLine(updateState.DataSpace,updateState.TransformUnderDataSpace,[xdata(k:k+1)',ydata(k:k+1)',[0;0]])];
                end
                stripdata=uint32([1,length(vertexData)+1]);
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

        mcodeConstructor(hObj,hCode)
    end




end
