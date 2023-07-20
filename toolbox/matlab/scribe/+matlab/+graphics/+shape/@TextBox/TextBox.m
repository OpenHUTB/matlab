
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)TextBox<matlab.graphics.shape.internal.TwoDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Transform matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Transform(hObj)


            valueToCaller=hObj.Transform_I;

        end

        function set.Transform(hObj,newValue)



            hObj.TransformMode='manual';


            hObj.Transform_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TransformMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TransformMode(hObj)
            storedValue=hObj.TransformMode;
        end

        function set.TransformMode(hObj,newValue)

            oldValue=hObj.TransformMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TransformMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Transform_I;
    end

    methods
        function set.Transform_I(hObj,newValue)
            hObj.Transform_I=newValue;
            try
                hObj.setTransform_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function valueToCaller=get.BackgroundColor(hObj)


            valueToCaller=hObj.BackgroundColor_I;

        end

        function set.BackgroundColor(hObj,newValue)



            hObj.BackgroundColorMode='manual';


            hObj.BackgroundColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BackgroundColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BackgroundColorMode(hObj)
            storedValue=hObj.BackgroundColorMode;
        end

        function set.BackgroundColorMode(hObj,newValue)

            oldValue=hObj.BackgroundColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BackgroundColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BackgroundColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.BackgroundColor_I(hObj)
            storedValue=hObj.BackgroundColor_I;
        end

        function set.BackgroundColor_I(hObj,newValue)



            fanChild=hObj.Face;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.BackgroundColor_I=newValue;

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



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Face matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Face(hObj)


            valueToCaller=hObj.Face_I;

        end

        function set.Face(hObj,newValue)



            hObj.FaceMode='manual';


            hObj.Face_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        FaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceMode(hObj)
            storedValue=hObj.FaceMode;
        end

        function set.FaceMode(hObj,newValue)

            oldValue=hObj.FaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Face_I;
    end

    methods
        function set.Face_I(hObj,newValue)
            oldValue=hObj.Face_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.Face_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Face_I=newValue;
            try
                hObj.setFace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Edge_I;
    end

    methods
        function set.Edge_I(hObj,newValue)
            oldValue=hObj.Edge_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.Edge_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Edge_I=newValue;
            try
                hObj.setEdge_IFanoutProps();
            catch
            end
        end
    end

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

        FitBoxToText matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.FitBoxToText(hObj)


            valueToCaller=hObj.FitBoxToText_I;

        end

        function set.FitBoxToText(hObj,newValue)



            hObj.FitBoxToTextMode='manual';


            hObj.FitBoxToText_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FitBoxToTextMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FitBoxToTextMode(hObj)
            storedValue=hObj.FitBoxToTextMode;
        end

        function set.FitBoxToTextMode(hObj,newValue)

            oldValue=hObj.FitBoxToTextMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FitBoxToTextMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FitBoxToText_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.FitBoxToText_I(hObj)
            storedValue=hObj.FitBoxToText_I;
        end

        function set.FitBoxToText_I(hObj,newValue)



            hObj.FitBoxToText_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FitHeightToText='off';
    end

    methods
        function valueToCaller=get.FitHeightToText(hObj)




            valueToCaller=hObj.FitHeightToText_I;

        end

        function set.FitHeightToText(hObj,newValue)



            hObj.FitHeightToTextMode='manual';


            hObj.FitHeightToText_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FitHeightToTextMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FitHeightToTextMode(hObj)
            storedValue=hObj.FitHeightToTextMode;
        end

        function set.FitHeightToTextMode(hObj,newValue)

            oldValue=hObj.FitHeightToTextMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FitHeightToTextMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FitHeightToText_I='off';
    end

    methods
        function storedValue=get.FitHeightToText_I(hObj)
            storedValue=hObj.FitHeightToText_I;
        end

        function set.FitHeightToText_I(hObj,newValue)



            hObj.FitHeightToText_I=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        HorizontalAlignment matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='left';
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

        HorizontalAlignment_I matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='left';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Image(:,:)double;
    end

    methods
        function valueToCaller=get.Image(hObj)


            valueToCaller=hObj.Image_I;

        end

        function set.Image(hObj,newValue)



            hObj.ImageMode='manual';


            hObj.Image_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ImageMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ImageMode(hObj)
            storedValue=hObj.ImageMode;
        end

        function set.ImageMode(hObj,newValue)

            oldValue=hObj.ImageMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ImageMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Image_I(:,:)double;
    end

    methods
        function storedValue=get.Image_I(hObj)
            storedValue=hObj.Image_I;
        end

        function set.Image_I(hObj,newValue)



            hObj.Image_I=newValue;

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



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Margin(1,1)double=5;
    end

    methods
        function valueToCaller=get.Margin(hObj)


            valueToCaller=hObj.Margin_I;

        end

        function set.Margin(hObj,newValue)



            hObj.MarginMode='manual';


            hObj.Margin_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarginMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarginMode(hObj)
            storedValue=hObj.MarginMode;
        end

        function set.MarginMode(hObj,newValue)

            oldValue=hObj.MarginMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarginMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Margin_I(1,1)double=5;
    end

    methods
        function storedValue=get.Margin_I(hObj)
            storedValue=hObj.Margin_I;
        end

        function set.Margin_I(hObj,newValue)



            hObj.Margin_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Rotation matlab.internal.datatype.matlab.graphics.datatype.RealWithNoInfs=0;
    end

    methods
        function valueToCaller=get.Rotation(hObj)


            valueToCaller=hObj.Rotation_I;

        end

        function set.Rotation(hObj,newValue)



            hObj.RotationMode='manual';


            hObj.Rotation_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        RotationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RotationMode(hObj)
            storedValue=hObj.RotationMode;
        end

        function set.RotationMode(hObj,newValue)

            oldValue=hObj.RotationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RotationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Rotation_I matlab.internal.datatype.matlab.graphics.datatype.RealWithNoInfs=0;
    end

    methods
        function storedValue=get.Rotation_I(hObj)
            storedValue=hObj.Rotation_I;
        end

        function set.Rotation_I(hObj,newValue)



            hObj.Rotation_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        String matlab.internal.datatype.matlab.graphics.datatype.NumericOrString={''};
    end

    methods
        function valueToCaller=get.String(hObj)


            valueToCaller=hObj.String_I;

        end

        function set.String(hObj,newValue)



            hObj.StringMode='manual';


            hObj.String_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        StringMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.StringMode(hObj)
            storedValue=hObj.StringMode;
        end

        function set.StringMode(hObj,newValue)

            oldValue=hObj.StringMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.StringMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        String_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString={''};
    end

    methods
        function storedValue=get.String_I(hObj)
            storedValue=hObj.String_I;
        end

        function set.String_I(hObj,newValue)



            fanChild=hObj.Text;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'StringMode'),'auto')
                    set(fanChild,'String_I',newValue);
                end
            end
            hObj.String_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Text_I;
    end

    methods
        function set.Text_I(hObj,newValue)
            oldValue=hObj.Text_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.Text_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Text_I=newValue;
            try
                hObj.setText_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        VerticalAlignment matlab.internal.datatype.matlab.graphics.datatype.VerticalAlignment='top';
    end

    methods
        function valueToCaller=get.VerticalAlignment(hObj)


            valueToCaller=hObj.VerticalAlignment_I;

        end

        function set.VerticalAlignment(hObj,newValue)



            hObj.VerticalAlignmentMode='manual';


            hObj.VerticalAlignment_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        VerticalAlignmentMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.VerticalAlignmentMode(hObj)
            storedValue=hObj.VerticalAlignmentMode;
        end

        function set.VerticalAlignmentMode(hObj,newValue)

            oldValue=hObj.VerticalAlignmentMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.VerticalAlignmentMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        VerticalAlignment_I matlab.internal.datatype.matlab.graphics.datatype.VerticalAlignment='top';
    end

    methods
        function storedValue=get.VerticalAlignment_I(hObj)
            storedValue=hObj.VerticalAlignment_I;
        end

        function set.VerticalAlignment_I(hObj,newValue)



            hObj.VerticalAlignment_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Transform')
                b=true;
                return;
            end
            if strcmp(name,'Transform_I')
                b=true;
                return;
            end
            if strcmp(name,'Face')
                b=true;
                return;
            end
            if strcmp(name,'Face_I')
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
            if strcmp(name,'Text')
                b=true;
                return;
            end
            if strcmp(name,'Text_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.shape.internal.TwoDimensional(obj,name);
            return;
            b=false;
        end
    end








    methods(Access={?tTextBox_resizeText})
        [strout,finalPos]=resizeText(hObj,doUpdate,str)
    end






    methods(Access={?tTextBox_calculateTextPosition})
        [textPos,vertAlign]=calculateTextPosition(hObj,pos)
    end



    methods
        function hObj=TextBox(varargin)






            hObj.Transform_I=matlab.graphics.primitive.Transform;

            set(hObj.Transform,'Description_I','TextBox Transform');

            set(hObj.Transform,'Internal',true);

            hObj.Face_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.Face,'Description_I','TextBox Face');

            set(hObj.Face,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineLoop;

            set(hObj.Edge,'Description_I','TextBox Edge');

            set(hObj.Edge,'Internal',true);

            hObj.Text_I=matlab.graphics.primitive.Text;

            set(hObj.Text,'Description_I','TextBox Text');

            set(hObj.Text,'Internal',true);


            hObj.Editing_I='off';

            hObj.FontAngle_I='normal';

            hObj.FontName_I='Helvetica';

            hObj.FontUnits_I='points';

            hObj.FontSize_I=10;

            hObj.FontWeight_I='normal';

            hObj.HorizontalAlignment_I='left';

            hObj.Interpreter_I='tex';


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setTransform_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setFace_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,hObj.BackgroundColor_I);

        end
    end
    methods(Access=private)
        function setEdge_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.EdgeColor_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle_I);


            try
                mode=hObj.Edge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setText_IFanoutProps(hObj)

            try
                mode=hObj.Text.StringMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Text,'String_I',hObj.String_I);
            end

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='textboxshape';




            hAf=hObj.Srect;
            hG=matlab.graphics.primitive.world.Group.empty;
            set(hAf,'Parent',hG);
            for k=1:numel(hAf)
                hObj.addNode(hAf(k));
            end



            addlistener(hObj,'Position','PreSet',@(obj,evd)(localPrePositionCallback(obj,evd)));
            addlistener(hObj,'Position','PostSet',@(obj,evd)(localPostPositionCallback(obj,evd)));
            pos=hObj.Position;


            hObj.LineWidth_I=get(0,'DefaultLineLineWidth');


            hObj.FontName_I=get(0,'DefaultTextFontName');
            hObj.FontSize_I=get(0,'DefaultTextFontSize');


            addDependencyConsumed(hObj,'figurecolormap');

            addlistener(hObj.Text,'String','PostSet',@(~,evd)(copy_string_up(hObj,evd)));

            function copy_string_up(obj,evd)
                if isvalid(obj)&&isvalid(evd.AffectedObject)
                    obj.String=evd.AffectedObject.String;
                end
            end

            function localPrePositionCallback(obj,evd)
                pos=hObj.Position;
            end

            function localPostPositionCallback(obj,evd)
                newPos=hObj.Position;
                changedAspect=abs(newPos-pos);
                if~all(changedAspect(3:4)<eps)
                    hObj.FitHeightToText='off';
                    hObj.FitBoxToText='off';
                end
                pos=newPos;
            end


            hObj.Text.HitTest='off';

            hObj.Transform.HitTest='off';
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

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.TextBox.uicontextmenu*');
            if~isempty(res)
                fitBoxToTextEntry=findall(res,'Tag','matlab.graphics.shape.TextBox.uicontextmenu.FitBoxToText');
                set(fitBoxToTextEntry,'Checked',get(hObj,'FitBoxToText'));
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end


            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'EditText',getString(message('MATLAB:uistring:scribemenu:Edit')),'','');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Toggle',getString(message('MATLAB:uistring:scribemenu:FitBoxToText')),'FitBoxToText',getString(message('MATLAB:uistring:scribemenu:FitBoxToText')));
            set(res(end),'Checked',get(hObj,'FitBoxToText'));
            set(res(end),'Separator','on');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
            set(res(end),'Separator','on');

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:BackgroundColorDotDotDot')),'BackgroundColor',getString(message('MATLAB:uistring:scribemenu:BackgroundColor')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Font',getString(message('MATLAB:uistring:scribemenu:FontDotDotDot')),'',getString(message('MATLAB:uistring:scribemenu:Font')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'TextInterpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')),'Interpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));



            menuSpecificTags={'Edit','FitBoxToText','Color','BackgroundColor','EdgeColor','Font','Interpreter','LineWidth','LineStyle'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.TextBox.uicontextmenu','.',menuSpecificTags{i}]);
            end


            set(res,'Visible','off','Parent',hMenu);
            delete(tempParent);
            varargout{1}=res;
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
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

            if strcmpi(toolbarProp,'edgecolor')
                varargout{1}={'EdgeColor'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:EdgeColor'));
            elseif strcmpi(toolbarProp,'facecolor')
                varargout{1}={'BackgroundColor'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:BackgroundColor'));
            elseif strcmpi(toolbarProp,'textcolor')
                varargout{1}={'Color'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:TextColor'));
            else
                outargs=cell(1,nargout);
                [outargs{1:nargout}]=getPlotEditToolbarProp@matlab.graphics.shape.internal.TwoDimensional(hObj,toolbarProp);
                varargout=outargs;
            end
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=splitString(str,hText,updateState)
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'String','FontName','FontSize','FontWeight',...
            'Color','BackgroundColor','EdgeColor','LineStyle','LineWidth',...
            'Position','Units'});

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
    methods(Access={?tTextBox_resizeText},Hidden=true)
        function installMockPin(hObj,newValue)

            hObj.Pin=newValue;
        end
    end




end
