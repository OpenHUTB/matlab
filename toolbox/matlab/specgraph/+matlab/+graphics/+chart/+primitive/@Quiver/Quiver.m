
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Quiver<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.chart.interaction.DataAnnotatable





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

        Head matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Head(hObj)


            valueToCaller=hObj.Head_I;

        end

        function set.Head(hObj,newValue)



            hObj.HeadMode='manual';


            hObj.Head_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadMode(hObj)
            storedValue=hObj.HeadMode;
        end

        function set.HeadMode(hObj,newValue)

            oldValue=hObj.HeadMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Head_I;
    end

    methods
        function set.Head_I(hObj,newValue)
            hObj.Head_I=newValue;
            try
                hObj.setHead_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Tail matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Tail(hObj)


            valueToCaller=hObj.Tail_I;

        end

        function set.Tail(hObj,newValue)



            hObj.TailMode='manual';


            hObj.Tail_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TailMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TailMode(hObj)
            storedValue=hObj.TailMode;
        end

        function set.TailMode(hObj,newValue)

            oldValue=hObj.TailMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TailMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Tail_I;
    end

    methods
        function set.Tail_I(hObj,newValue)
            hObj.Tail_I=newValue;
            try
                hObj.setTail_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AlignVertexCenters matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
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

        AlignVertexCenters_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.AlignVertexCenters_I(hObj)
            storedValue=hObj.AlignVertexCenters_I;
        end

        function set.AlignVertexCenters_I(hObj,newValue)



            fanChild=hObj.Tail;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'AlignVertexCentersMode'),'auto')
                    set(fanChild,'AlignVertexCenters_I',newValue);
                end
            end
            hObj.AlignVertexCenters_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AutoScale matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.AutoScale(hObj)


            valueToCaller=hObj.AutoScale_I;

        end

        function set.AutoScale(hObj,newValue)



            hObj.AutoScaleMode='manual';


            hObj.AutoScale_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AutoScaleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AutoScaleMode(hObj)
            storedValue=hObj.AutoScaleMode;
        end

        function set.AutoScaleMode(hObj,newValue)

            oldValue=hObj.AutoScaleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AutoScaleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AutoScale_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.AutoScale_I(hObj)
            storedValue=hObj.AutoScale_I;
        end

        function set.AutoScale_I(hObj,newValue)



            hObj.AutoScale_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AutoScaleFactor(1,1)double=.9;
    end

    methods
        function valueToCaller=get.AutoScaleFactor(hObj)


            valueToCaller=hObj.AutoScaleFactor_I;

        end

        function set.AutoScaleFactor(hObj,newValue)



            hObj.AutoScaleFactorMode='manual';


            hObj.AutoScaleFactor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AutoScaleFactorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AutoScaleFactorMode(hObj)
            storedValue=hObj.AutoScaleFactorMode;
        end

        function set.AutoScaleFactorMode(hObj,newValue)

            oldValue=hObj.AutoScaleFactorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AutoScaleFactorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AutoScaleFactor_I(1,1)double=.9;
    end

    methods
        function storedValue=get.AutoScaleFactor_I(hObj)
            storedValue=hObj.AutoScaleFactor_I;
        end

        function set.AutoScaleFactor_I(hObj,newValue)



            hObj.AutoScaleFactor_I=newValue;

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



            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            fanChild=hObj.Tail;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

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



            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            fanChild=hObj.Tail;

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



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.Tail;

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

        MaxHeadSize(1,1)double=.2;
    end

    methods
        function valueToCaller=get.MaxHeadSize(hObj)


            valueToCaller=hObj.MaxHeadSize_I;

        end

        function set.MaxHeadSize(hObj,newValue)



            hObj.MaxHeadSizeMode='manual';


            hObj.MaxHeadSize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MaxHeadSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MaxHeadSizeMode(hObj)
            storedValue=hObj.MaxHeadSizeMode;
        end

        function set.MaxHeadSizeMode(hObj,newValue)

            oldValue=hObj.MaxHeadSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MaxHeadSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MaxHeadSize_I(1,1)double=.2;
    end

    methods
        function storedValue=get.MaxHeadSize_I(hObj)
            storedValue=hObj.MaxHeadSize_I;
        end

        function set.MaxHeadSize_I(hObj,newValue)



            hObj.MaxHeadSize_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ShowArrowHead matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.ShowArrowHead(hObj)


            valueToCaller=hObj.ShowArrowHead_I;

        end

        function set.ShowArrowHead(hObj,newValue)



            hObj.ShowArrowHeadMode='manual';


            hObj.ShowArrowHead_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ShowArrowHeadMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ShowArrowHeadMode(hObj)
            storedValue=hObj.ShowArrowHeadMode;
        end

        function set.ShowArrowHeadMode(hObj,newValue)

            oldValue=hObj.ShowArrowHeadMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ShowArrowHeadMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ShowArrowHead_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.ShowArrowHead_I(hObj)
            storedValue=hObj.ShowArrowHead_I;
        end

        function set.ShowArrowHead_I(hObj,newValue)



            hObj.ShowArrowHead_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Alignment matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowAlignmentType='tail';
    end

    methods
        function valueToCaller=get.Alignment(hObj)


            valueToCaller=hObj.Alignment_I;

        end

        function set.Alignment(hObj,newValue)



            hObj.AlignmentMode='manual';


            hObj.Alignment_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AlignmentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AlignmentMode(hObj)
            storedValue=hObj.AlignmentMode;
        end

        function set.AlignmentMode(hObj,newValue)

            oldValue=hObj.AlignmentMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AlignmentMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Alignment_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowAlignmentType='tail';
    end

    methods
        function storedValue=get.Alignment_I(hObj)
            storedValue=hObj.Alignment_I;
        end

        function set.Alignment_I(hObj,newValue)



            hObj.Alignment_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
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

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

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


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.XDataSource(hObj)


            valueToCaller=hObj.XDataSource_I;

        end

        function set.XDataSource(hObj,newValue)



            hObj.XDataSourceMode='manual';


            hObj.XDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XDataSourceMode(hObj)
            storedValue=hObj.XDataSourceMode;
        end

        function set.XDataSourceMode(hObj,newValue)

            oldValue=hObj.XDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.XDataSource_I(hObj)
            storedValue=hObj.XDataSource_I;
        end

        function set.XDataSource_I(hObj,newValue)



            hObj.XDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
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

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

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


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.YDataSource(hObj)


            valueToCaller=hObj.YDataSource_I;

        end

        function set.YDataSource(hObj,newValue)



            hObj.YDataSourceMode='manual';


            hObj.YDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YDataSourceMode(hObj)
            storedValue=hObj.YDataSourceMode;
        end

        function set.YDataSourceMode(hObj,newValue)

            oldValue=hObj.YDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.YDataSource_I(hObj)
            storedValue=hObj.YDataSource_I;
        end

        function set.YDataSource_I(hObj,newValue)



            hObj.YDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function valueToCaller=get.ZData(hObj)


            valueToCaller=hObj.ZData_I;

        end

        function set.ZData(hObj,newValue)



            hObj.ZDataMode='manual';


            hObj.ZData_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZDataMode(hObj)
            storedValue=hObj.ZDataMode;
        end

        function set.ZDataMode(hObj,newValue)

            oldValue=hObj.ZDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function storedValue=get.ZData_I(hObj)
            storedValue=hObj.ZData_I;
        end

        function set.ZData_I(hObj,newValue)



            hObj.ZData_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.ZDataSource(hObj)


            valueToCaller=hObj.ZDataSource_I;

        end

        function set.ZDataSource(hObj,newValue)



            hObj.ZDataSourceMode='manual';


            hObj.ZDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZDataSourceMode(hObj)
            storedValue=hObj.ZDataSourceMode;
        end

        function set.ZDataSourceMode(hObj,newValue)

            oldValue=hObj.ZDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.ZDataSource_I(hObj)
            storedValue=hObj.ZDataSource_I;
        end

        function set.ZDataSource_I(hObj,newValue)



            hObj.ZDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        UData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function valueToCaller=get.UData(hObj)



            valueToCaller=hObj.getUDataImpl(hObj.UData_I);


        end

        function set.UData(hObj,newValue)



            hObj.UDataMode='manual';



            reallyDoCopy=~isequal(hObj.UData_I,newValue);

            if reallyDoCopy
                hObj.UData_I=hObj.setUDataImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        UDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.UDataMode(hObj)
            storedValue=hObj.UDataMode;
        end

        function set.UDataMode(hObj,newValue)

            oldValue=hObj.UDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.UDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        UData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        UDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.UDataSource(hObj)


            valueToCaller=hObj.UDataSource_I;

        end

        function set.UDataSource(hObj,newValue)



            hObj.UDataSourceMode='manual';


            hObj.UDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        UDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.UDataSourceMode(hObj)
            storedValue=hObj.UDataSourceMode;
        end

        function set.UDataSourceMode(hObj,newValue)

            oldValue=hObj.UDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.UDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        UDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.UDataSource_I(hObj)
            storedValue=hObj.UDataSource_I;
        end

        function set.UDataSource_I(hObj,newValue)



            hObj.UDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        VData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function valueToCaller=get.VData(hObj)



            valueToCaller=hObj.getVDataImpl(hObj.VData_I);


        end

        function set.VData(hObj,newValue)



            hObj.VDataMode='manual';



            reallyDoCopy=~isequal(hObj.VData_I,newValue);

            if reallyDoCopy
                hObj.VData_I=hObj.setVDataImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.VDataMode(hObj)
            storedValue=hObj.VDataMode;
        end

        function set.VDataMode(hObj,newValue)

            oldValue=hObj.VDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.VDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        VData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        VDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.VDataSource(hObj)


            valueToCaller=hObj.VDataSource_I;

        end

        function set.VDataSource(hObj,newValue)



            hObj.VDataSourceMode='manual';


            hObj.VDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.VDataSourceMode(hObj)
            storedValue=hObj.VDataSourceMode;
        end

        function set.VDataSourceMode(hObj,newValue)

            oldValue=hObj.VDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.VDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.VDataSource_I(hObj)
            storedValue=hObj.VDataSource_I;
        end

        function set.VDataSource_I(hObj,newValue)



            hObj.VDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        WData matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function valueToCaller=get.WData(hObj)


            valueToCaller=hObj.WData_I;

        end

        function set.WData(hObj,newValue)



            hObj.WDataMode='manual';


            hObj.WData_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.WDataMode(hObj)
            storedValue=hObj.WDataMode;
        end

        function set.WDataMode(hObj,newValue)

            oldValue=hObj.WDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.WDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        WData_I matlab.internal.datatype.matlab.graphics.datatype.Numeric2D3DMatrix;
    end

    methods
        function storedValue=get.WData_I(hObj)
            storedValue=hObj.WData_I;
        end

        function set.WData_I(hObj,newValue)



            hObj.WData_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        WDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.WDataSource(hObj)


            valueToCaller=hObj.WDataSource_I;

        end

        function set.WDataSource(hObj,newValue)



            hObj.WDataSourceMode='manual';


            hObj.WDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.WDataSourceMode(hObj)
            storedValue=hObj.WDataSourceMode;
        end

        function set.WDataSourceMode(hObj,newValue)

            oldValue=hObj.WDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.WDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.WDataSource_I(hObj)
            storedValue=hObj.WDataSource_I;
        end

        function set.WDataSource_I(hObj,newValue)



            hObj.WDataSource_I=newValue;

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



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.Tail;

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
            if strcmp(name,'Head')
                b=true;
                return;
            end
            if strcmp(name,'Head_I')
                b=true;
                return;
            end
            if strcmp(name,'Tail')
                b=true;
                return;
            end
            if strcmp(name,'Tail_I')
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








    methods(Access={?tQuiver_preProcessData})
        [x,y,z,u,v,w,msg]=preProcessData(hObj)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doIncrementIndex(hObj,index,direction,interpolationStep)
    end



    methods
        function hObj=Quiver(varargin)






            hObj.MarkerHandle_I=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','Quiver MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);

            hObj.Head_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Head,'Description_I','Quiver Head');

            set(hObj.Head,'Internal',true);

            hObj.Tail_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Tail,'Description_I','Quiver Tail');

            set(hObj.Tail,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','Quiver SelectionHandle');

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


            try
                mode=hObj.MarkerHandle.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'Clipping_I',hObj.Clipping_I);
            end

        end
    end
    methods(Access=private)
        function setHead_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Head,hObj.Color_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Head,hObj.LineStyle_I);


            try
                mode=hObj.Head.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head,'LineWidth_I',hObj.LineWidth_I);
            end


            try
                mode=hObj.Head.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head,'Clipping_I',hObj.Clipping_I);
            end

        end
    end
    methods(Access=private)
        function setTail_IFanoutProps(hObj)

            try
                mode=hObj.Tail.AlignVertexCentersMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Tail,'AlignVertexCenters_I',hObj.AlignVertexCenters_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Tail,hObj.Color_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Tail,hObj.LineStyle_I);


            try
                mode=hObj.Tail.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Tail,'LineWidth_I',hObj.LineWidth_I);
            end


            try
                mode=hObj.Tail.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Tail,'Clipping_I',hObj.Clipping_I);
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
        function varargout=getXDataImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setXDataImpl(hObj,newValue)

            if isempty(newValue)&&strcmpi(hObj.XDataMode,'auto')
                [m,n]=size(hObj.UData);
                newValue=1:n;
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYDataImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYDataImpl(hObj,newValue)

            if isempty(newValue)&&strcmpi(hObj.YDataMode,'auto')
                [m,n]=size(hObj.VData);
                newValue=1:m;
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getUDataImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setUDataImpl(hObj,newValue)

            if strcmpi(hObj.XDataMode,'auto')
                n=size(newValue,2);
                set(hObj,'XData_I',1:n);
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getVDataImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setVDataImpl(hObj,newValue)

            if strcmpi(hObj.YDataMode,'auto')
                m=size(newValue,1);
                set(hObj,'YData_I',1:m);
            end
            varargout{1}=newValue;
        end
    end
    methods(Access={?tQuiver_is3D},Hidden=true)

        varargout=is3D(hObj)
    end
    methods(Access='private',Hidden=true)
        function varargout=doAutoScaleUVWValues(hObj,is3D,x,y,z,u,v,w)





            if min(size(x))==1,n=sqrt(numel(x));m=n;else[m,n]=size(x);end
            delx=diff([min(x(:)),max(x(:))])/n;
            dely=diff([min(y(:)),max(y(:))])/m;
            if is3D
                delz=diff([min(z(:)),max(z(:))])/max(m,n);
                del=delx.^2+dely.^2+delz.^2;
            else
                del=delx.^2+dely.^2;
            end

            if del>0
                if is3D
                    len=sqrt((u.^2+v.^2+w.^2)/del);
                else
                    len=sqrt((u.^2+v.^2)/del);
                end
                maxlen=max(len(:));
            else
                maxlen=0;
            end

            if maxlen>0
                scaleFactor=hObj.AutoScaleFactor/maxlen;
            else
                scaleFactor=hObj.AutoScaleFactor;
            end

            u=u*scaleFactor;v=v*scaleFactor;

            if is3D
                w=w*scaleFactor;
            end

            varargout={u,v,w};
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=calculateMarkerVertexData(hObj,is3D,x,y,z)

            if~is3D
                z=zeros(size(x));
            end

            varargout{1}=[x(:),y(:),z(:)];
        end
    end
    methods(Access={?matlab.unittest.TestCase},Hidden=true)
        function varargout=getAlignmentOffset(hObj)

            switch hObj.Alignment
            case 'center'
                offset=[-0.5;0.5];
            case 'head'
                offset=[-1;0];
            otherwise
                offset=[0;1];
            end

            varargout{1}=offset;
        end
    end
    methods(Access={?matlab.unittest.TestCase},Hidden=true)
        function varargout=calculateTailVertexData(hObj,is3D,x,y,z,u,v,w,offset)

            tu=x+offset.*u;
            tv=y+offset.*v;
            if is3D
                tw=z+offset.*w;
            else
                tw=zeros(size(tu));
            end

            varargout{1}=[tu(:),tv(:),tw(:)];
        end
    end
    methods(Access={?matlab.unittest.TestCase},Hidden=true)
        function varargout=calculateHeadVertexData(hObj,is3D,x,y,z,u,v,w,offset)


            alpha=.33;
            beta=.25;

            if is3D
                norm=sqrt(u.*u+v.*v+w.*w);
            else
                norm=sqrt(u.*u+v.*v);
            end
            normxy=sqrt(u.*u+v.*v)+eps;
            allx=[x(:);x(:)+u(:)];
            spanx=max(allx)-min(allx);
            ally=[y(:);y(:)+v(:)];
            spany=max(ally)-min(ally);

            if is3D
                allz=[z(:);z(:)+w(:)];
                spanz=max(allz)-min(allz);
            end

            if is3D
                cutoff=hObj.MaxHeadSize*max(spanx,max(spany,spanz));
            else
                cutoff=hObj.MaxHeadSize*max(spanx,spany);
            end

            beta=beta.*norm./normxy;
            norm2=normxy;
            norm2(norm<=cutoff)=1;
            norm2(norm>cutoff)=norm(norm>cutoff)./cutoff;
            alpha=alpha./norm2;


            hu=[x-alpha.*(u+beta.*(v+eps));x;...
            x-alpha.*(u-beta.*(v+eps))]+u.*offset(2);
            hv=[y-alpha.*(v-beta.*(u+eps));y;...
            y-alpha.*(v+beta.*(u+eps))]+v.*offset(2);

            if is3D
                hw=[z-alpha.*w;z;...
                z-alpha.*w]+w.*offset(2);
            else
                hw=zeros(size(hu));
            end


            varargout{1}=[hu(:),hv(:),hw(:)];
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='public',Hidden=true)
        function doSetup(hObj)


            hObj.Type='quiver';



            addlistener(hObj,{'XData','YData','ZData','UData','VData','WData'},'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));


            addDependencyConsumed(hObj,{'colororder_linestyleorder'});


            setInteractionHint(hObj,'DataBrushing',false);
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetDataDescriptors(hObj,index,~)




            primpos=hObj.getReportedPosition(index,0);
            location=primpos.getLocation(hObj);

            numPoints=numel(hObj.UData);
            if index>0&&index<=numPoints
                uVal=hObj.UData(index);
                vVal=hObj.VData(index);
                if~primpos.Is2D
                    wVal=hObj.WData(index);
                else
                    wVal=0;
                end
            else
                uVal=NaN;
                vVal=NaN;
                wVal=NaN;
            end

            if~primpos.Is2D
                sizeVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('[X,Y,Z]',location);
                locationVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('[U,V,W]',[uVal,vVal,wVal]);
            else
                sizeVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('[X,Y]',location);
                locationVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('[U,V]',[uVal,vVal]);
            end

            varargout{1}=[sizeVal,locationVal];
        end
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



            numPoints=numel(hObj.UData);


            if numPoints>0
                index=max(1,min(index,numPoints));
            end
            varargout{1}=index;
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestPoint(hObj,position)
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
            if isempty(hObj.ZData)
                pt.Is2D=true;
            end
            varargout{1}=pt;
        end
    end
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)


            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);
            varargout{1}=hObj;
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Color','LineStyle','LineWidth',...
            'XData','YData','ZData','UData','VData','WData'});
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
