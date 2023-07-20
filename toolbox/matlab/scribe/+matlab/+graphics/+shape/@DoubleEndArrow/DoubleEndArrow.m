
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true)DoubleEndArrow<matlab.graphics.shape.internal.OneDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1BackDepth(1,1)double=0.35;
    end

    methods
        function valueToCaller=get.Head1BackDepth(hObj)




            valueToCaller=hObj.Head1BackDepth_I;

        end

        function set.Head1BackDepth(hObj,newValue)



            hObj.Head1BackDepthMode='manual';


            hObj.Head1BackDepth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1BackDepthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1BackDepthMode(hObj)
            storedValue=hObj.Head1BackDepthMode;
        end

        function set.Head1BackDepthMode(hObj,newValue)

            oldValue=hObj.Head1BackDepthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head1BackDepthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head1BackDepth_I(1,1)double=0.35;
    end

    methods
        function storedValue=get.Head1BackDepth_I(hObj)
            storedValue=hObj.Head1BackDepth_I;
        end

        function set.Head1BackDepth_I(hObj,newValue)



            hObj.Head1BackDepth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.Head1Color(hObj)


            valueToCaller=hObj.Head1Color_I;

        end

        function set.Head1Color(hObj,newValue)



            hObj.Head1ColorMode='manual';


            hObj.Head1Color_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1ColorMode(hObj)
            storedValue=hObj.Head1ColorMode;
        end

        function set.Head1ColorMode(hObj,newValue)

            oldValue=hObj.Head1ColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head1ColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head1Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Head1Color_I(hObj)
            storedValue=hObj.Head1Color_I;
        end

        function set.Head1Color_I(hObj,newValue)



            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'FaceColorMode'),'auto')
                    set(fanChild,'FaceColor_I',newValue);
                end
            end
            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'EdgeColorMode'),'auto')
                    set(fanChild,'EdgeColor_I',newValue);
                end
            end
            hObj.Head1Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1FaceAlpha(1,1)double=1;
    end

    methods
        function storedValue=get.Head1FaceAlpha(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FaceAlpha;
        end

        function set.Head1FaceAlpha(hObj,newValue)






            hObj.Head1FaceAlphaMode='manual';
            hObj.Head1FaceAlpha_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1FaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1FaceAlphaMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlphaMode;
        end

        function set.Head1FaceAlphaMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlphaMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1FaceAlpha_I(1,1)double=1;
    end

    methods
        function storedValue=get.Head1FaceAlpha_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlpha_I;
        end

        function set.Head1FaceAlpha_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlpha_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Head1Handle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Head1Handle(hObj)


            valueToCaller=hObj.Head1Handle_I;

        end

        function set.Head1Handle(hObj,newValue)



            hObj.Head1HandleMode='manual';


            hObj.Head1Handle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        Head1HandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1HandleMode(hObj)
            storedValue=hObj.Head1HandleMode;
        end

        function set.Head1HandleMode(hObj,newValue)

            oldValue=hObj.Head1HandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head1HandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Head1Handle_I;
    end

    methods
        function set.Head1Handle_I(hObj,newValue)
            hObj.Head1Handle_I=newValue;
            try
                hObj.setHead1Handle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1HypocycloidN(1,1)double=3;
    end

    methods
        function storedValue=get.Head1HypocycloidN(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.HypocycloidN;
        end

        function set.Head1HypocycloidN(hObj,newValue)






            hObj.Head1HypocycloidNMode='manual';
            hObj.Head1HypocycloidN_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1HypocycloidNMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1HypocycloidNMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidNMode;
        end

        function set.Head1HypocycloidNMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidNMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1HypocycloidN_I(1,1)double=3;
    end

    methods
        function storedValue=get.Head1HypocycloidN_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidN_I;
        end

        function set.Head1HypocycloidN_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidN_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head1Length(1,1)double=10;
    end

    methods
        function storedValue=get.Head1Length(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Length;
        end

        function set.Head1Length(hObj,newValue)






            hObj.Head1LengthMode='manual';
            hObj.Head1Length_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1LengthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1LengthMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LengthMode;
        end

        function set.Head1LengthMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LengthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1Length_I(1,1)double=10;
    end

    methods
        function storedValue=get.Head1Length_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Length_I;
        end

        function set.Head1Length_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Length_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function valueToCaller=get.Head1LineStyle(hObj)


            valueToCaller=hObj.Head1LineStyle_I;

        end

        function set.Head1LineStyle(hObj,newValue)



            hObj.Head1LineStyleMode='manual';


            hObj.Head1LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1LineStyleMode(hObj)
            storedValue=hObj.Head1LineStyleMode;
        end

        function set.Head1LineStyleMode(hObj,newValue)

            oldValue=hObj.Head1LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head1LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head1LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function storedValue=get.Head1LineStyle_I(hObj)
            storedValue=hObj.Head1LineStyle_I;
        end

        function set.Head1LineStyle_I(hObj,newValue)



            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.Head1LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.Head1LineWidth(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.Head1LineWidth(hObj,newValue)






            hObj.Head1LineWidthMode='manual';
            hObj.Head1LineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1LineWidthMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.Head1LineWidthMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.Head1LineWidth_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.Head1LineWidth_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1RosePQ(1,1)double=2;
    end

    methods
        function storedValue=get.Head1RosePQ(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.RosePQ;
        end

        function set.Head1RosePQ(hObj,newValue)






            hObj.Head1RosePQMode='manual';
            hObj.Head1RosePQ_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1RosePQMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1RosePQMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQMode;
        end

        function set.Head1RosePQMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1RosePQ_I(1,1)double=2;
    end

    methods
        function storedValue=get.Head1RosePQ_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQ_I;
        end

        function set.Head1RosePQ_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQ_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head1Size(1,1)double=10;
    end

    methods
        function valueToCaller=get.Head1Size(hObj)


            valueToCaller=hObj.Head1Size_I;

        end

        function set.Head1Size(hObj,newValue)



            hObj.Head1SizeMode='manual';


            hObj.Head1Size_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1SizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1SizeMode(hObj)
            storedValue=hObj.Head1SizeMode;
        end

        function set.Head1SizeMode(hObj,newValue)

            oldValue=hObj.Head1SizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head1SizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head1Size_I(1,1)double=10;
    end

    methods
        function storedValue=get.Head1Size_I(hObj)
            storedValue=hObj.Head1Size_I;
        end

        function set.Head1Size_I(hObj,newValue)



            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LengthMode'),'auto')
                    set(fanChild,'Length_I',newValue);
                end
            end
            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'WidthMode'),'auto')
                    set(fanChild,'Width_I',newValue);
                end
            end
            hObj.Head1Size_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head1Style matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.Head1Style(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Style;
        end

        function set.Head1Style(hObj,newValue)






            hObj.Head1StyleMode='manual';
            hObj.Head1Style_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1StyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1StyleMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.StyleMode;
        end

        function set.Head1StyleMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.StyleMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1Style_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.Head1Style_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Style_I;
        end

        function set.Head1Style_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Style_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head1Width(1,1)double=10;
    end

    methods
        function storedValue=get.Head1Width(hObj)




            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Width;
        end

        function set.Head1Width(hObj,newValue)






            hObj.Head1WidthMode='manual';
            hObj.Head1Width_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1WidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head1WidthMode(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.WidthMode;
        end

        function set.Head1WidthMode(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.WidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head1Width_I(1,1)double=10;
    end

    methods
        function storedValue=get.Head1Width_I(hObj)
            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Width_I;
        end

        function set.Head1Width_I(hObj,newValue)


            passObj=hObj.Head1Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Width_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2BackDepth(1,1)double=0.35;
    end

    methods
        function valueToCaller=get.Head2BackDepth(hObj)




            valueToCaller=hObj.Head2BackDepth_I;

        end

        function set.Head2BackDepth(hObj,newValue)



            hObj.Head2BackDepthMode='manual';


            hObj.Head2BackDepth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2BackDepthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2BackDepthMode(hObj)
            storedValue=hObj.Head2BackDepthMode;
        end

        function set.Head2BackDepthMode(hObj,newValue)

            oldValue=hObj.Head2BackDepthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head2BackDepthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head2BackDepth_I(1,1)double=0.35;
    end

    methods
        function storedValue=get.Head2BackDepth_I(hObj)
            storedValue=hObj.Head2BackDepth_I;
        end

        function set.Head2BackDepth_I(hObj,newValue)



            hObj.Head2BackDepth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.Head2Color(hObj)


            valueToCaller=hObj.Head2Color_I;

        end

        function set.Head2Color(hObj,newValue)



            hObj.Head2ColorMode='manual';


            hObj.Head2Color_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2ColorMode(hObj)
            storedValue=hObj.Head2ColorMode;
        end

        function set.Head2ColorMode(hObj,newValue)

            oldValue=hObj.Head2ColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head2ColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head2Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Head2Color_I(hObj)
            storedValue=hObj.Head2Color_I;
        end

        function set.Head2Color_I(hObj,newValue)



            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'FaceColorMode'),'auto')
                    set(fanChild,'FaceColor_I',newValue);
                end
            end
            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'EdgeColorMode'),'auto')
                    set(fanChild,'EdgeColor_I',newValue);
                end
            end
            hObj.Head2Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2FaceAlpha(1,1)double=1;
    end

    methods
        function storedValue=get.Head2FaceAlpha(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FaceAlpha;
        end

        function set.Head2FaceAlpha(hObj,newValue)






            hObj.Head2FaceAlphaMode='manual';
            hObj.Head2FaceAlpha_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2FaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2FaceAlphaMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlphaMode;
        end

        function set.Head2FaceAlphaMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlphaMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2FaceAlpha_I(1,1)double=1;
    end

    methods
        function storedValue=get.Head2FaceAlpha_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlpha_I;
        end

        function set.Head2FaceAlpha_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlpha_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Head2Handle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Head2Handle(hObj)


            valueToCaller=hObj.Head2Handle_I;

        end

        function set.Head2Handle(hObj,newValue)



            hObj.Head2HandleMode='manual';


            hObj.Head2Handle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        Head2HandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2HandleMode(hObj)
            storedValue=hObj.Head2HandleMode;
        end

        function set.Head2HandleMode(hObj,newValue)

            oldValue=hObj.Head2HandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head2HandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Head2Handle_I;
    end

    methods
        function set.Head2Handle_I(hObj,newValue)
            hObj.Head2Handle_I=newValue;
            try
                hObj.setHead2Handle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2HypocycloidN=3;
    end

    methods
        function storedValue=get.Head2HypocycloidN(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.HypocycloidN;
        end

        function set.Head2HypocycloidN(hObj,newValue)






            hObj.Head2HypocycloidNMode='manual';
            hObj.Head2HypocycloidN_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2HypocycloidNMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2HypocycloidNMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidNMode;
        end

        function set.Head2HypocycloidNMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidNMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2HypocycloidN_I=3;
    end

    methods
        function storedValue=get.Head2HypocycloidN_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidN_I;
        end

        function set.Head2HypocycloidN_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidN_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head2Length(1,1)double=10;
    end

    methods
        function storedValue=get.Head2Length(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Length;
        end

        function set.Head2Length(hObj,newValue)






            hObj.Head2LengthMode='manual';
            hObj.Head2Length_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2LengthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2LengthMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LengthMode;
        end

        function set.Head2LengthMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LengthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2Length_I(1,1)double=10;
    end

    methods
        function storedValue=get.Head2Length_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Length_I;
        end

        function set.Head2Length_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Length_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function valueToCaller=get.Head2LineStyle(hObj)


            valueToCaller=hObj.Head2LineStyle_I;

        end

        function set.Head2LineStyle(hObj,newValue)



            hObj.Head2LineStyleMode='manual';


            hObj.Head2LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2LineStyleMode(hObj)
            storedValue=hObj.Head2LineStyleMode;
        end

        function set.Head2LineStyleMode(hObj,newValue)

            oldValue=hObj.Head2LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head2LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head2LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function storedValue=get.Head2LineStyle_I(hObj)
            storedValue=hObj.Head2LineStyle_I;
        end

        function set.Head2LineStyle_I(hObj,newValue)



            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.Head2LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.Head2LineWidth(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.Head2LineWidth(hObj,newValue)






            hObj.Head2LineWidthMode='manual';
            hObj.Head2LineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2LineWidthMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.Head2LineWidthMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.Head2LineWidth_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.Head2LineWidth_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2RosePQ(1,1)double=2;
    end

    methods
        function storedValue=get.Head2RosePQ(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.RosePQ;
        end

        function set.Head2RosePQ(hObj,newValue)






            hObj.Head2RosePQMode='manual';
            hObj.Head2RosePQ_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2RosePQMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2RosePQMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQMode;
        end

        function set.Head2RosePQMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2RosePQ_I(1,1)double=2;
    end

    methods
        function storedValue=get.Head2RosePQ_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQ_I;
        end

        function set.Head2RosePQ_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQ_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Head2Size=10;
    end

    methods
        function valueToCaller=get.Head2Size(hObj)


            valueToCaller=hObj.Head2Size_I;

        end

        function set.Head2Size(hObj,newValue)



            hObj.Head2SizeMode='manual';


            hObj.Head2Size_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2SizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2SizeMode(hObj)
            storedValue=hObj.Head2SizeMode;
        end

        function set.Head2SizeMode(hObj,newValue)

            oldValue=hObj.Head2SizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Head2SizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Head2Size_I=10;
    end

    methods
        function storedValue=get.Head2Size_I(hObj)
            storedValue=hObj.Head2Size_I;
        end

        function set.Head2Size_I(hObj,newValue)



            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LengthMode'),'auto')
                    set(fanChild,'Length_I',newValue);
                end
            end
            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'WidthMode'),'auto')
                    set(fanChild,'Width_I',newValue);
                end
            end
            hObj.Head2Size_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head2Style matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.Head2Style(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Style;
        end

        function set.Head2Style(hObj,newValue)






            hObj.Head2StyleMode='manual';
            hObj.Head2Style_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2StyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2StyleMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.StyleMode;
        end

        function set.Head2StyleMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.StyleMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2Style_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.Head2Style_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Style_I;
        end

        function set.Head2Style_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Style_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Head2Width(1,1)double=10;
    end

    methods
        function storedValue=get.Head2Width(hObj)




            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Width;
        end

        function set.Head2Width(hObj,newValue)






            hObj.Head2WidthMode='manual';
            hObj.Head2Width_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2WidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Head2WidthMode(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.WidthMode;
        end

        function set.Head2WidthMode(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.WidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Head2Width_I(1,1)double=10;
    end

    methods
        function storedValue=get.Head2Width_I(hObj)
            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Width_I;
        end

        function set.Head2Width_I(hObj,newValue)


            passObj=hObj.Head2Handle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Width_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadSize(1,1)double=10;
    end

    methods
        function valueToCaller=get.HeadSize(hObj)



            valueToCaller=hObj.getHeadSizeImpl(hObj.HeadSize_I);


        end

        function set.HeadSize(hObj,newValue)



            hObj.HeadSizeMode='manual';



            reallyDoCopy=~isequal(hObj.HeadSize_I,newValue);

            if reallyDoCopy
                hObj.HeadSize_I=hObj.setHeadSizeImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadSizeMode(hObj)
            storedValue=hObj.HeadSizeMode;
        end

        function set.HeadSizeMode(hObj,newValue)

            oldValue=hObj.HeadSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HeadSize_I(1,1)double=10;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadStyle matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function valueToCaller=get.HeadStyle(hObj)


            valueToCaller=hObj.HeadStyle_I;

        end

        function set.HeadStyle(hObj,newValue)



            hObj.HeadStyleMode='manual';


            hObj.HeadStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadStyleMode(hObj)
            storedValue=hObj.HeadStyleMode;
        end

        function set.HeadStyleMode(hObj,newValue)

            oldValue=hObj.HeadStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HeadStyle_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.HeadStyle_I(hObj)
            storedValue=hObj.HeadStyle_I;
        end

        function set.HeadStyle_I(hObj,newValue)



            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'StyleMode'),'auto')
                    set(fanChild,'Style_I',newValue);
                end
            end
            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'StyleMode'),'auto')
                    set(fanChild,'Style_I',newValue);
                end
            end
            hObj.HeadStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
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

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.Tail;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
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

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            storedValue=hObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)



            fanChild=hObj.Tail;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        TailColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.TailColor(hObj)


            valueToCaller=hObj.TailColor_I;

        end

        function set.TailColor(hObj,newValue)



            hObj.TailColorMode='manual';


            hObj.TailColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TailColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TailColorMode(hObj)
            storedValue=hObj.TailColorMode;
        end

        function set.TailColorMode(hObj,newValue)

            oldValue=hObj.TailColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TailColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TailColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.TailColor_I(hObj)
            storedValue=hObj.TailColor_I;
        end

        function set.TailColor_I(hObj,newValue)



            fanChild=hObj.Tail;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.TailColor_I=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        TailLineStyle;
    end

    methods
        function valueToCaller=get.TailLineStyle(hObj)

            valueToCaller=hObj.LineStyle;
        end

        function set.TailLineStyle(hObj,newValue)

            hObj.LineStyle=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        TailLineWidth;
    end

    methods
        function valueToCaller=get.TailLineWidth(hObj)

            valueToCaller=hObj.LineWidth;
        end

        function set.TailLineWidth(hObj,newValue)

            hObj.LineWidth=newValue;
        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Head1Handle')
                b=true;
                return;
            end
            if strcmp(name,'Head1Handle_I')
                b=true;
                return;
            end
            if strcmp(name,'Head2Handle')
                b=true;
                return;
            end
            if strcmp(name,'Head2Handle_I')
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
            b=isChildProperty@matlab.graphics.shape.internal.OneDimensional(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=DoubleEndArrow(varargin)






            hObj.Head1Handle_I=matlab.graphics.shape.internal.arrow.ArrowHead;

            set(hObj.Head1Handle,'Description_I','DoubleEndArrow Head1Handle');

            set(hObj.Head1Handle,'Internal',true);

            hObj.Head2Handle_I=matlab.graphics.shape.internal.arrow.ArrowHead;

            set(hObj.Head2Handle,'Description_I','DoubleEndArrow Head2Handle');

            set(hObj.Head2Handle,'Internal',true);

            hObj.Tail_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Tail,'Description_I','DoubleEndArrow Tail');

            set(hObj.Tail,'Internal',true);


            hObj.Head1FaceAlpha_I=1;

            hObj.Head1HypocycloidN_I=3;

            hObj.Head1Length_I=10;

            hObj.Head1LineWidth_I=get(0,'DefaultLineLineWidth');

            hObj.Head1RosePQ_I=2;

            hObj.Head1Style_I='vback2';

            hObj.Head1Width_I=10;

            hObj.Head2FaceAlpha_I=1;

            hObj.Head2HypocycloidN_I=3;

            hObj.Head2Length_I=10;

            hObj.Head2LineWidth_I=get(0,'DefaultLineLineWidth');

            hObj.Head2RosePQ_I=2;

            hObj.Head2Style_I='vback2';

            hObj.Head2Width_I=10;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setHead1Handle_IFanoutProps(hObj)

            try
                mode=hObj.Head1Handle.FaceColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head1Handle,'FaceColor_I',hObj.Head1Color_I);
            end


            try
                mode=hObj.Head1Handle.EdgeColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head1Handle,'EdgeColor_I',hObj.Head1Color_I);
            end


            hgfilter('LineStyleToPrimLineStyle',hObj.Head1Handle,hObj.Head1LineStyle_I);


            try
                mode=hObj.Head1Handle.LengthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head1Handle,'Length_I',hObj.Head1Size_I);
            end


            try
                mode=hObj.Head1Handle.WidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head1Handle,'Width_I',hObj.Head1Size_I);
            end


            try
                mode=hObj.Head1Handle.StyleMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head1Handle,'Style_I',hObj.HeadStyle_I);
            end

        end
    end
    methods(Access=private)
        function setHead2Handle_IFanoutProps(hObj)

            try
                mode=hObj.Head2Handle.FaceColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head2Handle,'FaceColor_I',hObj.Head2Color_I);
            end


            try
                mode=hObj.Head2Handle.EdgeColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head2Handle,'EdgeColor_I',hObj.Head2Color_I);
            end


            hgfilter('LineStyleToPrimLineStyle',hObj.Head2Handle,hObj.Head2LineStyle_I);


            try
                mode=hObj.Head2Handle.LengthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head2Handle,'Length_I',hObj.Head2Size_I);
            end


            try
                mode=hObj.Head2Handle.WidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head2Handle,'Width_I',hObj.Head2Size_I);
            end


            try
                mode=hObj.Head2Handle.StyleMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head2Handle,'Style_I',hObj.HeadStyle_I);
            end

        end
    end
    methods(Access=private)
        function setTail_IFanoutProps(hObj)

            hgfilter('LineStyleToPrimLineStyle',hObj.Tail,hObj.LineStyle_I);


            try
                mode=hObj.Tail.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Tail,'LineWidth_I',hObj.LineWidth_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Tail,hObj.TailColor_I);

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='doubleendarrowshape';




            hG=matlab.graphics.primitive.world.Group.empty;
            hHead1=hObj.Head1Handle;
            hHead1.Parent=hG;
            hObj.addNode(hHead1);
            hHead2=hObj.Head2Handle;
            hHead2.Parent=hG;
            hObj.addNode(hHead2);




            hAf=hObj.Srect;
            set(hAf,'Parent',hG);
            for k=1:numel(hAf)
                hObj.addNode(hAf(k));
            end


            colorProps=hObj.ColorProps;
            colorProps{end+1}='TailColor';
            colorProps{end+1}='Head1Color';
            colorProps{end+1}='Head2Color';
            hObj.ColorProps=colorProps;


            defaultLineWidth=get(0,'DefaultLineLineWidth');
            hObj.LineWidth_I=defaultLineWidth;
            hObj.Head1LineWidth_I=defaultLineWidth;
            hObj.Head2LineWidth_I=defaultLineWidth;

            defaultLineStyle=get(0,'DefaultLineLineStyle');
            hObj.Head1LineStyle_I=defaultLineStyle;
            hObj.Head2LineStyle_I=defaultLineStyle;
            hObj.LineStyle_I=defaultLineStyle;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getHeadSizeImpl(hObj,storedValue)

            varargout{1}=storedValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setHeadSizeImpl(hObj,newValue)





            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)
                set(fanChild,'Length',newValue);
            end
            fanChild=hObj.Head1Handle;

            if~isempty(fanChild)&&isvalid(fanChild)
                set(fanChild,'Width',newValue);
            end
            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)
                set(fanChild,'Length',newValue);
            end
            fanChild=hObj.Head2Handle;

            if~isempty(fanChild)&&isvalid(fanChild)
                set(fanChild,'Width',newValue);
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getScribeMenus(hObj)










            hFig=ancestor(hObj,'figure');
            res=matlab.ui.container.Menu.empty;

            if isempty(hFig)||~isvalid(hFig)
                varargout{1}=res;
                return;
            end

            hPlotEdit=plotedit(hFig,'getmode');
            hMode=hPlotEdit.ModeStateData.PlotSelectMode;
            hMenu=hMode.UIContextMenu;

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.DoubleEndArrow.uicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end


            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')),'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')),'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')));



            menuSpecificTags={'Color','LineWidth','LineStyle','HeadStyle','HeadSize'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.DoubleEndArrow.uicontextmenu','.',menuSpecificTags{i}]);
            end


            set(res,'Visible','off','Parent',hMenu);
            delete(tempParent);
            varargout{1}=res;
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)



            updatePins(hObj,updateState);
            updateMarkers(hObj,updateState);


            normX=hObj.NormX;
            normY=hObj.NormY;
            set(hObj.Head1Handle,'X',normX(1));
            set(hObj.Head1Handle,'Y',normY(1));
            set(hObj.Head2Handle,'X',normX(2));
            set(hObj.Head2Handle,'Y',normY(2));


            p=updateState.convertUnits('camera','points','normalized',[normX',normY']);
            startPoint=p(1,:);
            endPoint=p(2,:);

            dx=endPoint(1)-startPoint(1);
            dy=endPoint(2)-startPoint(2);
            pointLength=sqrt(dx.^2+dy.^2);


            theta=atan2(dy,dx);
            set(hObj.Head1Handle,'Angle',theta-pi);
            set(hObj.Head2Handle,'Angle',theta);




            startOffset=getOffset(hObj.Head1Handle);
            endOffset=getOffset(hObj.Head2Handle);
            x=[startOffset,(pointLength-endOffset)];
            y=[0,0];

            costh=cos(theta);
            sinth=sin(theta);
            xx=x.*costh-y.*sinth+startPoint(1);
            yy=x.*sinth+y.*costh+startPoint(2);
            p=updateState.convertUnits('camera','normalized','points',[xx',yy']);
            xx=p(:,1);
            yy=p(:,2);


            hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            hIter.XData=xx;
            hIter.YData=yy;
            hIter.ZData=[0,0];
            vertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hIter);

            set(hObj.Tail,'VertexData',vertexData);
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPlotEditToolbarProp(hObj,toolbarProp)

            if strcmpi(toolbarProp,'facecolor')
                varargout{1}={'Head1Color','Head2Color'};
                varargout{2}='Head Color';
            else
                outargs=cell(1,nargout);
                [outargs{1:nargout}]=getPlotEditToolbarProp@matlab.graphics.shape.internal.OneDimensional(hObj,toolbarProp);
                varargout=outargs;
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Color','LineStyle','LineWidth',...
            'Head1Style','Head2Style','Position','Units','X','Y'});

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            varargout{1}=hObj.Tag;
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end




end
