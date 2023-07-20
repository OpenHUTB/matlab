
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)TextArrow<matlab.graphics.shape.internal.OneDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Editing matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Editing(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Editing;
        end

        function set.Editing(hObj,newValue)






            hObj.EditingMode='manual';
            hObj.Editing_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        EditingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EditingMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.EditingMode;
        end

        function set.EditingMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.EditingMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true)

        Editing_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Editing_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Editing_I;
        end

        function set.Editing_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Editing_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
    end

    methods
        function storedValue=get.FontAngle(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FontAngle;
        end

        function set.FontAngle(hObj,newValue)






            hObj.FontAngleMode='manual';
            hObj.FontAngle_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontAngleMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontAngleMode;
        end

        function set.FontAngleMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontAngleMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontAngle_I matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
    end

    methods
        function storedValue=get.FontAngle_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontAngle_I;
        end

        function set.FontAngle_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontAngle_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
    end

    methods
        function storedValue=get.FontName(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FontName;
        end

        function set.FontName(hObj,newValue)






            hObj.FontNameMode='manual';
            hObj.FontName_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontNameMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontNameMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontNameMode;
        end

        function set.FontNameMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontNameMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontName_I matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
    end

    methods
        function storedValue=get.FontName_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontName_I;
        end

        function set.FontName_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontName_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
    end

    methods
        function storedValue=get.FontSize(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FontSize;
        end

        function set.FontSize(hObj,newValue)






            hObj.FontSizeMode='manual';
            hObj.FontSize_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontSizeMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontSizeMode;
        end

        function set.FontSizeMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontSizeMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
    end

    methods
        function storedValue=get.FontSize_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontSize_I;
        end

        function set.FontSize_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontSize_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontUnits matlab.internal.datatype.matlab.graphics.datatype.FontUnits='points';
    end

    methods
        function storedValue=get.FontUnits(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FontUnits;
        end

        function set.FontUnits(hObj,newValue)






            hObj.FontUnitsMode='manual';
            hObj.FontUnits_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontUnitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontUnitsMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontUnitsMode;
        end

        function set.FontUnitsMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontUnitsMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontUnits_I matlab.internal.datatype.matlab.graphics.datatype.FontUnits='points';
    end

    methods
        function storedValue=get.FontUnits_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontUnits_I;
        end

        function set.FontUnits_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontUnits_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
    end

    methods
        function storedValue=get.FontWeight(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FontWeight;
        end

        function set.FontWeight(hObj,newValue)






            hObj.FontWeightMode='manual';
            hObj.FontWeight_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontWeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontWeightMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontWeightMode;
        end

        function set.FontWeightMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontWeightMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontWeight_I matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
    end

    methods
        function storedValue=get.FontWeight_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontWeight_I;
        end

        function set.FontWeight_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontWeight_I=newValue;
        end
    end

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

        HorizontalAlignment matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='right';
    end

    methods
        function storedValue=get.HorizontalAlignment(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.HorizontalAlignment;
        end

        function set.HorizontalAlignment(hObj,newValue)






            hObj.HorizontalAlignmentMode='manual';
            hObj.HorizontalAlignment_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HorizontalAlignmentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HorizontalAlignmentMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HorizontalAlignmentMode;
        end

        function set.HorizontalAlignmentMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HorizontalAlignmentMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HorizontalAlignment_I matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='right';
    end

    methods
        function storedValue=get.HorizontalAlignment_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.HorizontalAlignment_I;
        end

        function set.HorizontalAlignment_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.HorizontalAlignment_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function storedValue=get.Interpreter(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Interpreter;
        end

        function set.Interpreter(hObj,newValue)






            hObj.InterpreterMode='manual';
            hObj.Interpreter_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        InterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.InterpreterMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.InterpreterMode;
        end

        function set.InterpreterMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.InterpreterMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Interpreter_I matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function storedValue=get.Interpreter_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Interpreter_I;
        end

        function set.Interpreter_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Interpreter_I=newValue;
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
            fanChild=hObj.Text;

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
            fanChild=hObj.Text;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        String matlab.internal.datatype.matlab.graphics.datatype.NumericOrString={''};
    end

    methods
        function storedValue=get.String(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.String;
        end

        function set.String(hObj,newValue)






            hObj.StringMode='manual';
            hObj.String_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        StringMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.StringMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.StringMode;
        end

        function set.StringMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.StringMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        String_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString={''};
    end

    methods
        function storedValue=get.String_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.String_I;
        end

        function set.String_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.String_I=newValue;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextBackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.TextBackgroundColor(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.BackgroundColor;
        end

        function set.TextBackgroundColor(hObj,newValue)






            hObj.TextBackgroundColorMode='manual';
            hObj.TextBackgroundColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextBackgroundColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextBackgroundColorMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.BackgroundColorMode;
        end

        function set.TextBackgroundColorMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.BackgroundColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextBackgroundColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.TextBackgroundColor_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.BackgroundColor_I;
        end

        function set.TextBackgroundColor_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.BackgroundColor_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.TextColor(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Color;
        end

        function set.TextColor(hObj,newValue)






            hObj.TextColorMode='manual';
            hObj.TextColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextColorMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.ColorMode;
        end

        function set.TextColorMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.ColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.TextColor_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Color_I;
        end

        function set.TextColor_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Color_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.TextEdgeColor(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.EdgeColor;
        end

        function set.TextEdgeColor(hObj,newValue)






            hObj.TextEdgeColorMode='manual';
            hObj.TextEdgeColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextEdgeColorMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.EdgeColorMode;
        end

        function set.TextEdgeColorMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.EdgeColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.TextEdgeColor_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.EdgeColor_I;
        end

        function set.TextEdgeColor_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.EdgeColor_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Text matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Text(hObj)


            valueToCaller=hObj.Text_I;

        end

        function set.Text(hObj,newValue)



            hObj.TextMode='manual';


            hObj.Text_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextMode(hObj)
            storedValue=hObj.TextMode;
        end

        function set.TextMode(hObj,newValue)

            oldValue=hObj.TextMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TextMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Text_I;
    end

    methods
        function set.Text_I(hObj,newValue)
            hObj.Text_I=newValue;
            try
                hObj.setText_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextLineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.TextLineWidth(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.TextLineWidth(hObj,newValue)






            hObj.TextLineWidthMode='manual';
            hObj.TextLineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextLineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextLineWidthMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.TextLineWidthMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextLineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.TextLineWidth_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.TextLineWidth_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextMargin(1,1)double=2;
    end

    methods
        function storedValue=get.TextMargin(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Margin;
        end

        function set.TextMargin(hObj,newValue)






            hObj.TextMarginMode='manual';
            hObj.TextMargin_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextMarginMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextMarginMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.MarginMode;
        end

        function set.TextMarginMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.MarginMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextMargin_I(1,1)double=2;
    end

    methods
        function storedValue=get.TextMargin_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Margin_I;
        end

        function set.TextMargin_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Margin_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextRotation(1,1)double=0;
    end

    methods
        function storedValue=get.TextRotation(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Rotation;
        end

        function set.TextRotation(hObj,newValue)






            hObj.TextRotationMode='manual';
            hObj.TextRotation_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextRotationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextRotationMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.RotationMode;
        end

        function set.TextRotationMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.RotationMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextRotation_I(1,1)double=0;
    end

    methods
        function storedValue=get.TextRotation_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Rotation_I;
        end

        function set.TextRotation_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Rotation_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        VerticalAlignment matlab.internal.datatype.matlab.graphics.datatype.VerticalAlignment='top';
    end

    methods
        function storedValue=get.VerticalAlignment(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.VerticalAlignment;
        end

        function set.VerticalAlignment(hObj,newValue)






            hObj.VerticalAlignmentMode='manual';
            hObj.VerticalAlignment_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VerticalAlignmentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.VerticalAlignmentMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.VerticalAlignmentMode;
        end

        function set.VerticalAlignmentMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.VerticalAlignmentMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VerticalAlignment_I matlab.internal.datatype.matlab.graphics.datatype.VerticalAlignment='top';
    end

    methods
        function storedValue=get.VerticalAlignment_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.VerticalAlignment_I;
        end

        function set.VerticalAlignment_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.VerticalAlignment_I=newValue;
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
            if strcmp(name,'Text')
                b=true;
                return;
            end
            if strcmp(name,'Text_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.shape.internal.OneDimensional(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=TextArrow(varargin)






            hObj.Head_I=matlab.graphics.shape.internal.arrow.ArrowHead;

            set(hObj.Head,'Description_I','TextArrow Head');

            set(hObj.Head,'Internal',true);

            hObj.Tail_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Tail,'Description_I','TextArrow Tail');

            set(hObj.Tail,'Internal',true);

            hObj.Text_I=matlab.graphics.primitive.Text;

            set(hObj.Text,'Description_I','TextArrow Text');

            set(hObj.Text,'Internal',true);


            hObj.Editing_I='off';

            hObj.FontAngle_I='normal';

            hObj.FontName_I='Helvetica';

            hObj.FontSize_I=10;

            hObj.FontUnits_I='points';

            hObj.FontWeight_I='normal';

            hObj.HeadEdgeColor_I=[0,0,0];

            hObj.HeadFaceAlpha_I=1;

            hObj.HeadHypocycloidN_I=3;

            hObj.HeadLength_I=10;

            hObj.HeadLineWidth_I=get(0,'DefaultLineLineWidth');

            hObj.HeadRosePQ_I=2;

            hObj.HeadStyle_I='vback2';

            hObj.HeadWidth_I=10;

            hObj.HorizontalAlignment_I='right';

            hObj.Interpreter_I='tex';

            hObj.String_I={''};

            hObj.TextBackgroundColor_I='none';

            hObj.TextColor_I=[0,0,0];

            hObj.TextEdgeColor_I='none';

            hObj.TextLineWidth_I=get(0,'DefaultLineLineWidth');

            hObj.TextMargin_I=2;

            hObj.TextRotation_I=0;

            hObj.VerticalAlignment_I='top';


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
    methods(Access=private)
        function setText_IFanoutProps(hObj)

            hgfilter('LineStyleToPrimLineStyle',hObj.Text,hObj.LineStyle_I);


            try
                mode=hObj.Text.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Text,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='textarrowshape';




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
            colorProps{end+1}='TextColor';
            hObj.ColorProps=colorProps;


            defaultLineWidth=get(0,'DefaultLineLineWidth');
            hObj.LineWidth_I=defaultLineWidth;
            hObj.HeadLineWidth_I=defaultLineWidth;
            hObj.TextLineWidth_I=defaultLineWidth;

            defaultLineStyle=get(0,'DefaultLineLineStyle');
            hObj.HeadLineStyle_I=defaultLineStyle;
            hObj.LineStyle_I=defaultLineStyle;


            hObj.FontName_I=get(0,'DefaultTextFontName');
            hObj.FontSize_I=get(0,'DefaultTextFontSize');


            hObj.Text.HitTest='off';

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

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.TextArrow.uicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end


            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=uimenu(tempParent,'Label',getString(message('MATLAB:uistring:scribemenu:ReverseDirection')),'Callback',{@localReverseDirection,hMode},...
            'HandleVisibility','off');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'EditText',getString(message('MATLAB:uistring:scribemenu:Edit')),'','');
            set(res(end),'Separator','on');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
            set(res(end),'Separator','on');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:TextBackgroundColorDotDotDot')),'TextBackgroundColor',getString(message('MATLAB:uistring:scribemenu:TextBackgroundColor')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Font',getString(message('MATLAB:uistring:scribemenu:FontDotDotDot')),[],getString(message('MATLAB:uistring:scribemenu:Font')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')),'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')),'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')));


            menuSpecificTags={'ReverseDirection','Edit','Color','TextBackgroundColor','Font','LineWidth','LineStyle','HeadStyle','HeadSize'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.TextArrow.uicontextmenu','.',menuSpecificTags{i}]);
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


            pos=[normX(1),normY(1)];
            hText=hObj.Text;




            hFont=matlab.graphics.general.Font;
            hFont.Name=hText.FontName;
            hFont.Size=hText.FontSize;
            hFont.Angle=hText.FontAngle;
            hFont.Weight=hText.FontWeight;
            smoothing='on';
            try
                textBounds=updateState.getStringBounds(hObj.String,hFont,hObj.Interpreter,smoothing);
            catch interpreterError


                textBounds=updateState.getStringBounds(hObj.String,hFont,'none',smoothing);




            end


            textBounds=textBounds+2*hText.Margin;

            p=updateState.convertUnits('camera','normalized','points',[0,0,textBounds]);
            ext=p(3:4);

            if strcmp(get(hObj,'VerticalAlignmentMode'),'auto')
                if abs(theta-(-pi/2))<pi/3
                    set(hObj,'VerticalAlignment_I','bottom');
                elseif abs(theta-(pi/2))<pi/3
                    set(hObj,'VerticalAlignment_I','top');
                else
                    set(hObj,'VerticalAlignment_I','middle');
                end
            end

            if strcmp(get(hObj,'HorizontalAlignmentMode'),'auto')
                if abs(theta)<pi/3
                    set(hObj,'HorizontalAlignment_I','right');
                elseif theta<-2*pi/3||theta>2*pi/3
                    set(hObj,'HorizontalAlignment_I','left');
                else
                    set(hObj,'HorizontalAlignment_I','center');
                end
            end

            set(hObj.Text,'Units_I','data');
            set(hObj.Text,'Position_I',[pos,0]);
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=handleScribeButtonUp(hObj)

            varargout{1}=false;
            fig=ancestor(hObj,'figure');
            if strcmp(get(fig,'SelectionType'),'open')
                hObj.Editing='on';
                varargout{1}=true;
            end
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPlotEditToolbarProp(hObj,toolbarProp)

            if strcmpi(toolbarProp,'facecolor')
                varargout{1}={'HeadColor'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:HeadColor'));
            elseif strcmpi(toolbarProp,'textcolor')
                varargout{1}={'TextColor'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:TextColor'));
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
            {'String','FontName','FontSize','Color','TextColor','LineStyle','LineWidth',...
            'HeadStyle','Position','Units','X','Y'});

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            if~isempty(hObj.Tag)
                varargout{1}=hObj.Tag;
            else
                varargout{1}=hObj.String;
            end
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end




end
