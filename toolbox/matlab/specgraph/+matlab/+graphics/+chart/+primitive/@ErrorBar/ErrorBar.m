
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?hErrorBarTest})ErrorBar<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.mixin.Chartable2D&matlab.graphics.chart.interaction.DataAnnotatable





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Bar matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Bar(hObj)


            valueToCaller=hObj.Bar_I;

        end

        function set.Bar(hObj,newValue)



            hObj.BarMode='manual';


            hObj.Bar_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BarMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BarMode(hObj)
            storedValue=hObj.BarMode;
        end

        function set.BarMode(hObj,newValue)

            oldValue=hObj.BarMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BarMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Bar_I;
    end

    methods
        function set.Bar_I(hObj,newValue)
            hObj.Bar_I=newValue;
            try
                hObj.setBar_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Line matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Line(hObj)


            valueToCaller=hObj.Line_I;

        end

        function set.Line(hObj,newValue)



            hObj.LineMode='manual';


            hObj.Line_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        LineMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineMode(hObj)
            storedValue=hObj.LineMode;
        end

        function set.LineMode(hObj,newValue)

            oldValue=hObj.LineMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Line_I;
    end

    methods
        function set.Line_I(hObj,newValue)
            hObj.Line_I=newValue;
            try
                hObj.setLine_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Cap matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Cap(hObj)


            valueToCaller=hObj.Cap_I;

        end

        function set.Cap(hObj,newValue)



            hObj.CapMode='manual';


            hObj.Cap_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        CapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CapMode(hObj)
            storedValue=hObj.CapMode;
        end

        function set.CapMode(hObj,newValue)

            oldValue=hObj.CapMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CapMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Cap_I;
    end

    methods
        function set.Cap_I(hObj,newValue)
            hObj.Cap_I=newValue;
            try
                hObj.setCap_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        CapH matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.CapH(hObj)


            valueToCaller=hObj.CapH_I;

        end

        function set.CapH(hObj,newValue)



            hObj.CapHMode='manual';


            hObj.CapH_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        CapHMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CapHMode(hObj)
            storedValue=hObj.CapHMode;
        end

        function set.CapHMode(hObj,newValue)

            oldValue=hObj.CapHMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CapHMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        CapH_I;
    end

    methods
        function set.CapH_I(hObj,newValue)
            hObj.CapH_I=newValue;
            try
                hObj.setCapH_IFanoutProps();
            catch
            end
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AlignVertexCenters matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.AlignVertexCenters(hObj)


            valueToCaller=hObj.AlignVertexCenters_I;

        end

        function set.AlignVertexCenters(hObj,newValue)



            hObj.AlignVertexCentersMode='manual';


            hObj.AlignVertexCenters_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AlignVertexCentersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AlignVertexCentersMode(hObj)
            storedValue=hObj.AlignVertexCentersMode;
        end

        function set.AlignVertexCentersMode(hObj,newValue)

            oldValue=hObj.AlignVertexCentersMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AlignVertexCentersMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AlignVertexCenters_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.AlignVertexCenters_I(hObj)
            storedValue=hObj.AlignVertexCenters_I;
        end

        function set.AlignVertexCenters_I(hObj,newValue)



            fanChild=hObj.Line;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'AlignVertexCentersMode'),'auto')
                    set(fanChild,'AlignVertexCenters_I',newValue);
                end
            end
            hObj.AlignVertexCenters_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        CapSize matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=6;
    end

    methods
        function valueToCaller=get.CapSize(hObj)


            valueToCaller=hObj.CapSize_I;

        end

        function set.CapSize(hObj,newValue)



            hObj.CapSizeMode='manual';


            hObj.CapSize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CapSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CapSizeMode(hObj)
            storedValue=hObj.CapSizeMode;
        end

        function set.CapSizeMode(hObj,newValue)

            oldValue=hObj.CapSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CapSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        CapSize_I matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=6;
    end

    methods
        function storedValue=get.CapSize_I(hObj)
            storedValue=hObj.CapSize_I;
        end

        function set.CapSize_I(hObj,newValue)



            hObj.CapSize_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

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



            fanChild=hObj.Line;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.Bar;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.Cap;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.CapH;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.SelectionHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            hObj.Clipping_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.Color(hObj)

            if strcmpi(get(hObj,'ColorMode'),'auto')
                forceFullUpdate(hObj,'all','Color');
            end


            valueToCaller=hObj.Color_I;

        end

        function set.Color(hObj,newValue)



            hObj.ColorMode='manual';


            hObj.Color_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

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

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.Bar;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            fanChild=hObj.Cap;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('EdgeColorToMarkerPrimitive',fanChild,newValue);
            end
            fanChild=hObj.Cap;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('FaceColorToMarkerPrimitive',fanChild,newValue);
            end
            fanChild=hObj.CapH;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('EdgeColorToMarkerPrimitive',fanChild,newValue);
            end
            fanChild=hObj.CapH;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('FaceColorToMarkerPrimitive',fanChild,newValue);
            end
            fanChild=hObj.Line;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
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

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            storedValue=hObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)



            fanChild=hObj.Bar;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.Cap;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.CapH;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.Line;

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

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function valueToCaller=get.LineStyle(hObj)

            if strcmpi(get(hObj,'LineStyleMode'),'auto')
                forceFullUpdate(hObj,'all','LineStyle');
            end


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

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



            fanChild=hObj.Line;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    methods
        function valueToCaller=get.Marker(hObj)

            if strcmpi(get(hObj,'MarkerMode'),'auto')
                forceFullUpdate(hObj,'all','Marker');
            end


            valueToCaller=hObj.Marker_I;

        end

        function set.Marker(hObj,newValue)



            hObj.MarkerMode='manual';


            hObj.Marker_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

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

        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
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

        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
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

        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
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

        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
    end

    methods
        function storedValue=get.MarkerFaceColor_I(hObj)
            storedValue=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor_I(hObj,newValue)



            hObj.MarkerFaceColor_I=newValue;

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

        XNegativeDelta matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.XNegativeDelta(hObj)


            valueToCaller=hObj.XNegativeDelta_I;

        end

        function set.XNegativeDelta(hObj,newValue)



            hObj.XNegativeDeltaMode='manual';


            hObj.XNegativeDelta_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XNegativeDeltaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XNegativeDeltaMode(hObj)
            storedValue=hObj.XNegativeDeltaMode;
        end

        function set.XNegativeDeltaMode(hObj,newValue)

            oldValue=hObj.XNegativeDeltaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XNegativeDeltaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XNegativeDelta_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function storedValue=get.XNegativeDelta_I(hObj)
            storedValue=hObj.XNegativeDelta_I;
        end

        function set.XNegativeDelta_I(hObj,newValue)
            oldValue=hObj.XNegativeDelta_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.XNegativeDelta_I=hObj.setXNegativeDeltaImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,NonCopyable=true,Transient=true,AffectsLegend)

        XNegativeDeltaCache matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.XNegativeDeltaCache(hObj)
            storedValue=hObj.getXNegativeDeltaCacheImpl(hObj.XNegativeDeltaCache);
        end

        function set.XNegativeDeltaCache(hObj,newValue)
            hObj.XNegativeDeltaCache=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XNegativeDeltaSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.XNegativeDeltaSource(hObj)


            valueToCaller=hObj.XNegativeDeltaSource_I;

        end

        function set.XNegativeDeltaSource(hObj,newValue)



            hObj.XNegativeDeltaSourceMode='manual';


            hObj.XNegativeDeltaSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XNegativeDeltaSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XNegativeDeltaSourceMode(hObj)
            storedValue=hObj.XNegativeDeltaSourceMode;
        end

        function set.XNegativeDeltaSourceMode(hObj,newValue)

            oldValue=hObj.XNegativeDeltaSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XNegativeDeltaSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XNegativeDeltaSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.XNegativeDeltaSource_I(hObj)
            storedValue=hObj.XNegativeDeltaSource_I;
        end

        function set.XNegativeDeltaSource_I(hObj,newValue)



            hObj.XNegativeDeltaSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XPositiveDelta matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.XPositiveDelta(hObj)


            valueToCaller=hObj.XPositiveDelta_I;

        end

        function set.XPositiveDelta(hObj,newValue)



            hObj.XPositiveDeltaMode='manual';


            hObj.XPositiveDelta_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XPositiveDeltaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XPositiveDeltaMode(hObj)
            storedValue=hObj.XPositiveDeltaMode;
        end

        function set.XPositiveDeltaMode(hObj,newValue)

            oldValue=hObj.XPositiveDeltaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XPositiveDeltaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XPositiveDelta_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function storedValue=get.XPositiveDelta_I(hObj)
            storedValue=hObj.XPositiveDelta_I;
        end

        function set.XPositiveDelta_I(hObj,newValue)
            oldValue=hObj.XPositiveDelta_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.XPositiveDelta_I=hObj.setXPositiveDeltaImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,NonCopyable=true,Transient=true,AffectsLegend)

        XPositiveDeltaCache matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.XPositiveDeltaCache(hObj)
            storedValue=hObj.getXPositiveDeltaCacheImpl(hObj.XPositiveDeltaCache);
        end

        function set.XPositiveDeltaCache(hObj,newValue)
            hObj.XPositiveDeltaCache=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XPositiveDeltaSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.XPositiveDeltaSource(hObj)


            valueToCaller=hObj.XPositiveDeltaSource_I;

        end

        function set.XPositiveDeltaSource(hObj,newValue)



            hObj.XPositiveDeltaSourceMode='manual';


            hObj.XPositiveDeltaSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XPositiveDeltaSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XPositiveDeltaSourceMode(hObj)
            storedValue=hObj.XPositiveDeltaSourceMode;
        end

        function set.XPositiveDeltaSourceMode(hObj,newValue)

            oldValue=hObj.XPositiveDeltaSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XPositiveDeltaSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XPositiveDeltaSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.XPositiveDeltaSource_I(hObj)
            storedValue=hObj.XPositiveDeltaSource_I;
        end

        function set.XPositiveDeltaSource_I(hObj,newValue)



            hObj.XPositiveDeltaSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YNegativeDelta matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.YNegativeDelta(hObj)


            valueToCaller=hObj.YNegativeDelta_I;

        end

        function set.YNegativeDelta(hObj,newValue)



            hObj.YNegativeDeltaMode='manual';


            hObj.YNegativeDelta_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YNegativeDeltaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YNegativeDeltaMode(hObj)
            storedValue=hObj.YNegativeDeltaMode;
        end

        function set.YNegativeDeltaMode(hObj,newValue)

            oldValue=hObj.YNegativeDeltaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YNegativeDeltaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YNegativeDelta_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function storedValue=get.YNegativeDelta_I(hObj)
            storedValue=hObj.YNegativeDelta_I;
        end

        function set.YNegativeDelta_I(hObj,newValue)
            oldValue=hObj.YNegativeDelta_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.YNegativeDelta_I=hObj.setYNegativeDeltaImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,NonCopyable=true,Transient=true,AffectsLegend)

        YNegativeDeltaCache matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.YNegativeDeltaCache(hObj)
            storedValue=hObj.getYNegativeDeltaCacheImpl(hObj.YNegativeDeltaCache);
        end

        function set.YNegativeDeltaCache(hObj,newValue)
            hObj.YNegativeDeltaCache=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YNegativeDeltaSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.YNegativeDeltaSource(hObj)


            valueToCaller=hObj.YNegativeDeltaSource_I;

        end

        function set.YNegativeDeltaSource(hObj,newValue)



            hObj.YNegativeDeltaSourceMode='manual';


            hObj.YNegativeDeltaSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YNegativeDeltaSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YNegativeDeltaSourceMode(hObj)
            storedValue=hObj.YNegativeDeltaSourceMode;
        end

        function set.YNegativeDeltaSourceMode(hObj,newValue)

            oldValue=hObj.YNegativeDeltaSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YNegativeDeltaSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YNegativeDeltaSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.YNegativeDeltaSource_I(hObj)
            storedValue=hObj.YNegativeDeltaSource_I;
        end

        function set.YNegativeDeltaSource_I(hObj,newValue)



            hObj.YNegativeDeltaSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YPositiveDelta matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.YPositiveDelta(hObj)


            valueToCaller=hObj.YPositiveDelta_I;

        end

        function set.YPositiveDelta(hObj,newValue)



            hObj.YPositiveDeltaMode='manual';


            hObj.YPositiveDelta_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YPositiveDeltaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YPositiveDeltaMode(hObj)
            storedValue=hObj.YPositiveDeltaMode;
        end

        function set.YPositiveDeltaMode(hObj,newValue)

            oldValue=hObj.YPositiveDeltaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YPositiveDeltaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YPositiveDelta_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function storedValue=get.YPositiveDelta_I(hObj)
            storedValue=hObj.YPositiveDelta_I;
        end

        function set.YPositiveDelta_I(hObj,newValue)
            oldValue=hObj.YPositiveDelta_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.YPositiveDelta_I=hObj.setYPositiveDeltaImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,NonCopyable=true,Transient=true,AffectsLegend)

        YPositiveDeltaCache matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.YPositiveDeltaCache(hObj)
            storedValue=hObj.getYPositiveDeltaCacheImpl(hObj.YPositiveDeltaCache);
        end

        function set.YPositiveDeltaCache(hObj,newValue)
            hObj.YPositiveDeltaCache=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YPositiveDeltaSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.YPositiveDeltaSource(hObj)


            valueToCaller=hObj.YPositiveDeltaSource_I;

        end

        function set.YPositiveDeltaSource(hObj,newValue)



            hObj.YPositiveDeltaSourceMode='manual';


            hObj.YPositiveDeltaSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YPositiveDeltaSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YPositiveDeltaSourceMode(hObj)
            storedValue=hObj.YPositiveDeltaSourceMode;
        end

        function set.YPositiveDeltaSourceMode(hObj,newValue)

            oldValue=hObj.YPositiveDeltaSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YPositiveDeltaSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YPositiveDeltaSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.YPositiveDeltaSource_I(hObj)
            storedValue=hObj.YPositiveDeltaSource_I;
        end

        function set.YPositiveDeltaSource_I(hObj,newValue)



            hObj.YPositiveDeltaSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LData;
    end

    methods
        function valueToCaller=get.LData(hObj)

            valueToCaller=hObj.YNegativeDelta;
        end

        function set.LData(hObj,newValue)

            hObj.YNegativeDelta=newValue;
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true)

        LData_I matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.LData_I(hObj)
            storedValue=hObj.LData_I;
        end

        function set.LData_I(hObj,newValue)



            hObj.LData_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LDataSource;
    end

    methods
        function valueToCaller=get.LDataSource(hObj)

            valueToCaller=hObj.YNegativeDeltaSource;
        end

        function set.LDataSource(hObj,newValue)

            hObj.YNegativeDeltaSource=newValue;
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true)

        LDataSource_I matlab.internal.datatype.asciiString;
    end

    methods
        function storedValue=get.LDataSource_I(hObj)
            storedValue=hObj.LDataSource_I;
        end

        function set.LDataSource_I(hObj,newValue)



            hObj.LDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        UData;
    end

    methods
        function valueToCaller=get.UData(hObj)

            valueToCaller=hObj.YPositiveDelta;
        end

        function set.UData(hObj,newValue)

            hObj.YPositiveDelta=newValue;
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true)

        UData_I matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function storedValue=get.UData_I(hObj)
            storedValue=hObj.UData_I;
        end

        function set.UData_I(hObj,newValue)



            hObj.UData_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        UDataSource;
    end

    methods
        function valueToCaller=get.UDataSource(hObj)

            valueToCaller=hObj.YPositiveDeltaSource;
        end

        function set.UDataSource(hObj,newValue)

            hObj.YPositiveDeltaSource=newValue;
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true)

        UDataSource_I matlab.internal.datatype.asciiString;
    end

    methods
        function storedValue=get.UDataSource_I(hObj)
            storedValue=hObj.UDataSource_I;
        end

        function set.UDataSource_I(hObj,newValue)



            hObj.UDataSource_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Bar')
                b=true;
                return;
            end
            if strcmp(name,'Bar_I')
                b=true;
                return;
            end
            if strcmp(name,'Line')
                b=true;
                return;
            end
            if strcmp(name,'Line_I')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandle')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandle_I')
                b=true;
                return;
            end
            if strcmp(name,'Cap')
                b=true;
                return;
            end
            if strcmp(name,'Cap_I')
                b=true;
                return;
            end
            if strcmp(name,'CapH')
                b=true;
                return;
            end
            if strcmp(name,'CapH_I')
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








    methods(Access='public')
        [xData,yData,lineStripData,xBarData,yBarData,vBarStripData,hBarStripData]=createErrorBarVertices(hObj,hDataSpace)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doIncrementIndex(hObj,index,direction,interpolationStep)
    end



    methods
        function hObj=ErrorBar(varargin)






            hObj.Bar_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Bar,'Description_I','ErrorBar Bar');

            set(hObj.Bar,'Internal',true);

            hObj.Line_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Line,'Description_I','ErrorBar Line');

            set(hObj.Line,'Internal',true);

            hObj.MarkerHandle_I=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','ErrorBar MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);

            hObj.Cap_I=matlab.graphics.primitive.world.Marker;

            set(hObj.Cap,'Description_I','ErrorBar Cap');

            set(hObj.Cap,'Internal',true);

            hObj.CapH_I=matlab.graphics.primitive.world.Marker;

            set(hObj.CapH,'Description_I','ErrorBar CapH');

            set(hObj.CapH,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','ErrorBar SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);


            hObj.MarkerSize_I=6;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setBar_IFanoutProps(hObj)

            try
                mode=hObj.Bar.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Bar,'Clipping_I',hObj.Clipping_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Bar,hObj.Color_I);


            try
                mode=hObj.Bar.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Bar,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setLine_IFanoutProps(hObj)

            try
                mode=hObj.Line.AlignVertexCentersMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Line,'AlignVertexCenters_I',hObj.AlignVertexCenters_I);
            end


            try
                mode=hObj.Line.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Line,'Clipping_I',hObj.Clipping_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Line,hObj.Color_I);


            try
                mode=hObj.Line.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Line,'LineWidth_I',hObj.LineWidth_I);
            end


            hgfilter('LineStyleToPrimLineStyle',hObj.Line,hObj.LineStyle_I);

        end
    end
    methods(Access=private)
        function setMarkerHandle_IFanoutProps(hObj)

            try
                mode=hObj.MarkerHandle.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'Clipping_I',hObj.Clipping_I);
            end


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
        function setCap_IFanoutProps(hObj)

            try
                mode=hObj.Cap.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Cap,'Clipping_I',hObj.Clipping_I);
            end


            hgfilter('EdgeColorToMarkerPrimitive',hObj.Cap,hObj.Color_I);


            hgfilter('FaceColorToMarkerPrimitive',hObj.Cap,hObj.Color_I);


            try
                mode=hObj.Cap.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Cap,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setCapH_IFanoutProps(hObj)

            try
                mode=hObj.CapH.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.CapH,'Clipping_I',hObj.Clipping_I);
            end


            hgfilter('EdgeColorToMarkerPrimitive',hObj.CapH,hObj.Color_I);


            hgfilter('FaceColorToMarkerPrimitive',hObj.CapH,hObj.Color_I);


            try
                mode=hObj.CapH.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.CapH,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setSelectionHandle_IFanoutProps(hObj)

            try
                mode=hObj.SelectionHandle.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.SelectionHandle,'Clipping_I',hObj.Clipping_I);
            end

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='errorbar';

            addlistener(hObj,{'XData','YData','XNegativeDelta','XPositiveDelta','YNegativeDelta','YPositiveDelta'},'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));


            addDependencyConsumed(hObj,{'colororder_linestyleorder'});

            setInteractionHint(hObj,'DataBrushing',false);
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetDataDescriptors(hObj,index,~)
    end
    methods(Access='public',Hidden=true)

        varargout=createDefaultDataTipRows(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=createCoordinateData(hObj,valueSource,dataIndex,~)
    end
    methods(Access='public',Hidden=true)

        varargout=getAllValidValueSources(hObj)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetNearestIndex(hObj,index)


            numPoints=numel(hObj.XData);


            if numPoints>0
                index=max(1,min(index,numPoints));
            end

            varargout{1}=index;
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestPoint(hObj,position)
    end
    methods(Access='public',Hidden=true)
        function resetDataCacheProperties(hObj)

            resetDataCacheProperties@matlab.graphics.mixin.Chartable2D(hObj);
            hObj.XNegativeDeltaCache=[];
            hObj.XPositiveDeltaCache=[];
            hObj.YNegativeDeltaCache=[];
            hObj.YPositiveDeltaCache=[];
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=setDeltaImpl(hObj,newValue,axis,propName,cacheName)
    end
    methods(Access='private',Hidden=true)
        function varargout=setXNegativeDeltaImpl(hObj,newValue)

            try
                varargout{1}=setDeltaImpl(hObj,newValue,'XNegativeDelta','XNegativeDeltaCache',0);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setXPositiveDeltaImpl(hObj,newValue)

            try
                varargout{1}=setDeltaImpl(hObj,newValue,'XPositiveDelta','XPositiveDeltaCache',0);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYNegativeDeltaImpl(hObj,newValue)

            try
                varargout{1}=setDeltaImpl(hObj,newValue,'YNegativeDelta','YNegativeDeltaCache',1);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYPositiveDeltaImpl(hObj,newValue)

            try
                varargout{1}=setDeltaImpl(hObj,newValue,'YPositiveDelta','YPositiveDeltaCache',1);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=getDeltaCacheImpl(hObj,propName,cacheName,delta,deltaCache,axis)
    end
    methods(Access='private',Hidden=true)
        function varargout=getXNegativeDeltaCacheImpl(hObj,deltaCache)

            try
                varargout{1}=getDeltaCacheImpl(hObj,'XNegativeDelta',...
                'XNegativeDeltaCache',hObj.XNegativeDelta_I,deltaCache,0);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getXPositiveDeltaCacheImpl(hObj,deltaCache)

            try
                varargout{1}=getDeltaCacheImpl(hObj,'XPositiveDelta',...
                'XPositiveDeltaCache',hObj.XPositiveDelta_I,deltaCache,0);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYNegativeDeltaCacheImpl(hObj,deltaCache)

            try
                varargout{1}=getDeltaCacheImpl(hObj,'YNegativeDelta',...
                'YNegativeDeltaCache',hObj.YNegativeDelta_I,deltaCache,1);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYPositiveDeltaCacheImpl(hObj,deltaCache)

            try
                varargout{1}=getDeltaCacheImpl(hObj,'YPositiveDelta',...
                'YPositiveDeltaCache',hObj.YPositiveDelta_I,deltaCache,1);
            catch err
                throwAsCaller(err);
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetEnclosedPoints(hObj,~)


            varargout{1}=[];
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetDisplayAnchorPoint(hObj,index,~)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetReportedPosition(hObj,index,~)


            pt=doGetDisplayAnchorPoint(hObj,index,0);
            pt.Is2D=true;
            varargout{1}=pt;
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='public',Hidden=true)
        function varargout=saveobj(hObj)




            hObj.LData_I=hObj.YNegativeDeltaCache;
            hObj.UData_I=hObj.YPositiveDeltaCache;
            hObj.LDataSource_I=hObj.YNegativeDeltaSource_I;
            hObj.UDataSource_I=hObj.YPositiveDeltaSource_I;
            varargout{1}=hObj;
        end
    end
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)


            if isempty(hObj.YNegativeDelta_I)&&~isempty(hObj.LData_I)
                hObj.YNegativeDelta_I=hObj.LData_I;
                hObj.YNegativeDeltaSource_I=hObj.LDataSource_I;
            end
            if isempty(hObj.YPositiveDelta_I)&&~isempty(hObj.UData_I)
                hObj.YPositiveDelta_I=hObj.LData_I;
                hObj.YPositiveDeltaSource_I=hObj.LDataSource_I;
            end


            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);
            varargout{1}=hObj;
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Color','LineStyle','LineWidth','Marker',...
            'XData','YData','XNegativeDelta','XPositiveDelta',...
            'YNegativeDelta','YPositiveDelta'});
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            if~isempty(hObj.Tag)
                varargout{1}=hObj.Tag;
            else
                varargout{1}=hObj.DisplayName;
            end
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end




end
