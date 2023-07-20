
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Arrow<matlab.graphics.shape.internal.OneDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadBackDepth(1,1)double=0.35;
    end

    methods
        function valueToCaller=get.HeadBackDepth(hObj)




            valueToCaller=hObj.HeadBackDepth_I;

        end

        function set.HeadBackDepth(hObj,newValue)



            hObj.HeadBackDepthMode='manual';


            hObj.HeadBackDepth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadBackDepthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadBackDepthMode(hObj)
            storedValue=hObj.HeadBackDepthMode;
        end

        function set.HeadBackDepthMode(hObj,newValue)

            oldValue=hObj.HeadBackDepthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadBackDepthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HeadBackDepth_I(1,1)double=0.35;
    end

    methods
        function storedValue=get.HeadBackDepth_I(hObj)
            storedValue=hObj.HeadBackDepth_I;
        end

        function set.HeadBackDepth_I(hObj,newValue)



            hObj.HeadBackDepth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.HeadColor(hObj)


            valueToCaller=hObj.HeadColor_I;

        end

        function set.HeadColor(hObj,newValue)



            hObj.HeadColorMode='manual';


            hObj.HeadColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadColorMode(hObj)
            storedValue=hObj.HeadColorMode;
        end

        function set.HeadColorMode(hObj,newValue)

            oldValue=hObj.HeadColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HeadColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.HeadColor_I(hObj)
            storedValue=hObj.HeadColor_I;
        end

        function set.HeadColor_I(hObj,newValue)



            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'FaceColorMode'),'auto')
                    set(fanChild,'FaceColor_I',newValue);
                end
            end
            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'EdgeColorMode'),'auto')
                    set(fanChild,'EdgeColor_I',newValue);
                end
            end
            hObj.HeadColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.HeadEdgeColor(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.EdgeColor;
        end

        function set.HeadEdgeColor(hObj,newValue)






            hObj.HeadEdgeColorMode='manual';
            hObj.HeadEdgeColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadEdgeColorMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.EdgeColorMode;
        end

        function set.HeadEdgeColorMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.EdgeColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.HeadEdgeColor_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.EdgeColor_I;
        end

        function set.HeadEdgeColor_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.EdgeColor_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadFaceAlpha(1,1)double=1;
    end

    methods
        function storedValue=get.HeadFaceAlpha(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FaceAlpha;
        end

        function set.HeadFaceAlpha(hObj,newValue)






            hObj.HeadFaceAlphaMode='manual';
            hObj.HeadFaceAlpha_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadFaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadFaceAlphaMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlphaMode;
        end

        function set.HeadFaceAlphaMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlphaMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadFaceAlpha_I(1,1)double=1;
    end

    methods
        function storedValue=get.HeadFaceAlpha_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceAlpha_I;
        end

        function set.HeadFaceAlpha_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceAlpha_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.HeadFaceColor(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FaceColor;
        end

        function set.HeadFaceColor(hObj,newValue)






            hObj.HeadFaceColorMode='manual';
            hObj.HeadFaceColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadFaceColorMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceColorMode;
        end

        function set.HeadFaceColorMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.HeadFaceColor_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceColor_I;
        end

        function set.HeadFaceColor_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceColor_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

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

        HeadHypocycloidN(1,1)double=3;
    end

    methods
        function storedValue=get.HeadHypocycloidN(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.HypocycloidN;
        end

        function set.HeadHypocycloidN(hObj,newValue)






            hObj.HeadHypocycloidNMode='manual';
            hObj.HeadHypocycloidN_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadHypocycloidNMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadHypocycloidNMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidNMode;
        end

        function set.HeadHypocycloidNMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidNMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadHypocycloidN_I(1,1)double=3;
    end

    methods
        function storedValue=get.HeadHypocycloidN_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HypocycloidN_I;
        end

        function set.HeadHypocycloidN_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HypocycloidN_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        HeadLength(1,1)double=10;
    end

    methods
        function storedValue=get.HeadLength(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Length;
        end

        function set.HeadLength(hObj,newValue)






            hObj.HeadLengthMode='manual';
            hObj.HeadLength_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadLengthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadLengthMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LengthMode;
        end

        function set.HeadLengthMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LengthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadLength_I(1,1)double=10;
    end

    methods
        function storedValue=get.HeadLength_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Length_I;
        end

        function set.HeadLength_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Length_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadLineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function valueToCaller=get.HeadLineStyle(hObj)


            valueToCaller=hObj.HeadLineStyle_I;

        end

        function set.HeadLineStyle(hObj,newValue)



            hObj.HeadLineStyleMode='manual';


            hObj.HeadLineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadLineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadLineStyleMode(hObj)
            storedValue=hObj.HeadLineStyleMode;
        end

        function set.HeadLineStyleMode(hObj,newValue)

            oldValue=hObj.HeadLineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeadLineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HeadLineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function storedValue=get.HeadLineStyle_I(hObj)
            storedValue=hObj.HeadLineStyle_I;
        end

        function set.HeadLineStyle_I(hObj,newValue)



            fanChild=hObj.Head;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.HeadLineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadLineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.HeadLineWidth(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.HeadLineWidth(hObj,newValue)






            hObj.HeadLineWidthMode='manual';
            hObj.HeadLineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadLineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadLineWidthMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.HeadLineWidthMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadLineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.HeadLineWidth_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.HeadLineWidth_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HeadRosePQ(1,1)double=2;
    end

    methods
        function storedValue=get.HeadRosePQ(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.RosePQ;
        end

        function set.HeadRosePQ(hObj,newValue)






            hObj.HeadRosePQMode='manual';
            hObj.HeadRosePQ_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadRosePQMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadRosePQMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQMode;
        end

        function set.HeadRosePQMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadRosePQ_I(1,1)double=2;
    end

    methods
        function storedValue=get.HeadRosePQ_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RosePQ_I;
        end

        function set.HeadRosePQ_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RosePQ_I=newValue;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        HeadStyle matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.HeadStyle(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Style;
        end

        function set.HeadStyle(hObj,newValue)






            hObj.HeadStyleMode='manual';
            hObj.HeadStyle_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadStyleMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.StyleMode;
        end

        function set.HeadStyleMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.StyleMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadStyle_I matlab.internal.datatype.matlab.graphics.chart.datatype.ArrowHeadType='vback2';
    end

    methods
        function storedValue=get.HeadStyle_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Style_I;
        end

        function set.HeadStyle_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Style_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        HeadWidth(1,1)double=10;
    end

    methods
        function storedValue=get.HeadWidth(hObj)




            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Width;
        end

        function set.HeadWidth(hObj,newValue)






            hObj.HeadWidthMode='manual';
            hObj.HeadWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeadWidthMode(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.WidthMode;
        end

        function set.HeadWidthMode(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.WidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeadWidth_I(1,1)double=10;
    end

    methods
        function storedValue=get.HeadWidth_I(hObj)
            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Width_I;
        end

        function set.HeadWidth_I(hObj,newValue)


            passObj=hObj.Head;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Width_I=newValue;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

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
            b=isChildProperty@matlab.graphics.shape.internal.OneDimensional(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=Arrow(varargin)






            hObj.Head_I=matlab.graphics.shape.internal.arrow.ArrowHead;

            set(hObj.Head,'Description_I','Arrow Head');

            set(hObj.Head,'Internal',true);

            hObj.Tail_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Tail,'Description_I','Arrow Tail');

            set(hObj.Tail,'Internal',true);


            hObj.HeadEdgeColor_I=[0,0,0];

            hObj.HeadFaceAlpha_I=1;

            hObj.HeadFaceColor_I=[0,0,0];

            hObj.HeadHypocycloidN_I=3;

            hObj.HeadLength_I=10;

            hObj.HeadLineWidth_I=get(0,'DefaultLineLineWidth');

            hObj.HeadRosePQ_I=2;

            hObj.HeadStyle_I='vback2';

            hObj.HeadWidth_I=10;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setHead_IFanoutProps(hObj)

            try
                mode=hObj.Head.FaceColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head,'FaceColor_I',hObj.HeadColor_I);
            end


            try
                mode=hObj.Head.EdgeColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Head,'EdgeColor_I',hObj.HeadColor_I);
            end


            hgfilter('LineStyleToPrimLineStyle',hObj.Head,hObj.HeadLineStyle_I);

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


            hObj.Type='arrowshape';




            hG=matlab.graphics.primitive.world.Group.empty;
            hHead=hObj.Head;
            hHead.Parent=hG;
            hObj.addNode(hHead);




            hAf=hObj.Srect;
            set(hAf,'Parent',hG);
            for k=1:numel(hAf)
                hObj.addNode(hAf(k));
            end


            colorProps=hObj.ColorProps;
            colorProps{end+1}='TailColor';
            colorProps{end+1}='HeadColor';
            hObj.ColorProps=colorProps;


            defaultLineWidth=get(0,'DefaultLineLineWidth');
            hObj.LineWidth_I=defaultLineWidth;
            hObj.HeadLineWidth_I=defaultLineWidth;

            defaultLineStyle=get(0,'DefaultLineLineStyle');
            hObj.HeadLineStyle_I=defaultLineStyle;
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

            fanChild=hObj.Head;
            if~isempty(fanChild)&&isvalid(fanChild)
                set(fanChild,'Length',newValue);
            end
            fanChild=hObj.Head;
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

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.Arrow.uicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end



            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=uimenu(hFig,'Label',getString(message('MATLAB:uistring:scribemenu:ReverseDirection')),'Callback',{@localReverseDirection,hMode},...
            'HandleVisibility','off');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
            set(res(end),'Separator','on');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')),'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')),'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')));


            menuSpecificTags={'ReverseDirection','Color','LineWidth','LineStyle','HeadStyle','HeadSize'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.Arrow.uicontextmenu','.',menuSpecificTags{i}]);
            end


            set(res,'Visible','off','Parent',hMenu);
            delete(tempParent);
            varargout{1}=res;

            function localReverseDirection(obj,evd,hMode)


                props={'X','Y'};
                hObjs=hMode.ModeStateData.SelectedObjects;
                origVals=get(hObjs,props);

                newVals=cellfun(@(x)(fliplr(x)),origVals,'UniformOutput',false);

                matlab.graphics.annotation.internal.scribeContextMenuCallback(obj,evd,'localConstructPropertyUndoCallback',...
                hMode.FigureHandle,hMode,'Direction',props,origVals,newVals)
                set(hObjs,props,newVals);
            end
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)



            updatePins(hObj,updateState);
            updateMarkers(hObj,updateState);


            normX=hObj.NormX;
            normY=hObj.NormY;
            set(hObj.Head,'X',normX(2));
            set(hObj.Head,'Y',normY(2));


            p=updateState.convertUnits('camera','points','normalized',[normX',normY']);
            startPoint=p(1,:);
            endPoint=p(2,:);

            dx=endPoint(1)-startPoint(1);
            dy=endPoint(2)-startPoint(2);
            pointLength=sqrt(dx.^2+dy.^2);


            theta=atan2(dy,dx);
            set(hObj.Head,'Angle',theta);




            offset=getOffset(hObj.Head);
            x=[0,(pointLength-offset)];
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
                varargout{1}={'HeadColor'};
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
            'HeadStyle','Position','Units','X','Y'});

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
