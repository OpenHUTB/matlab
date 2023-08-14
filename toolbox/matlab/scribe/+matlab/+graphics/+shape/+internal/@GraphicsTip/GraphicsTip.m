
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed,Hidden=true)GraphicsTip<matlab.graphics.shape.internal.TipInfo





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        ScribeHost matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.ScribeHost(hObj)


            valueToCaller=hObj.ScribeHost_I;

        end

        function set.ScribeHost(hObj,newValue)



            hObj.ScribeHostMode='manual';


            hObj.ScribeHost_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        ScribeHostMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ScribeHostMode(hObj)
            storedValue=hObj.ScribeHostMode;
        end

        function set.ScribeHostMode(hObj,newValue)

            oldValue=hObj.ScribeHostMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ScribeHostMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        ScribeHost_I;
    end

    methods
        function set.ScribeHost_I(hObj,newValue)
            hObj.ScribeHost_I=newValue;
            try
                hObj.setScribeHost_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        TipContainer matlab.graphics.primitive.world.CompositeMarker;
    end

    methods
        function valueToCaller=get.TipContainer(hObj)


            valueToCaller=hObj.TipContainer_I;

        end

        function set.TipContainer(hObj,newValue)



            hObj.TipContainerMode='manual';


            hObj.TipContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TipContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TipContainerMode(hObj)
            storedValue=hObj.TipContainerMode;
        end

        function set.TipContainerMode(hObj,newValue)

            oldValue=hObj.TipContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TipContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        TipContainer_I;
    end

    methods
        function set.TipContainer_I(hObj,newValue)
            oldValue=hObj.TipContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.ScribeHost.replaceChild(hObj.TipContainer_I,newValue);
                else

                    hObj.ScribeHost.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.TipContainer_I=newValue;
            try
                hObj.setTipContainer_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        ParentLayer='overlay';
    end

    methods
        function valueToCaller=get.ParentLayer(hObj)


            valueToCaller=hObj.ParentLayer_I;

        end

        function set.ParentLayer(hObj,newValue)



            hObj.ParentLayerMode='manual';


            hObj.ParentLayer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ParentLayerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ParentLayerMode(hObj)
            storedValue=hObj.ParentLayerMode;
        end

        function set.ParentLayerMode(hObj,newValue)

            oldValue=hObj.ParentLayerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ParentLayerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ParentLayer_I='overlay';
    end

    methods
        function storedValue=get.ParentLayer_I(hObj)
            storedValue=hObj.ParentLayer_I;
        end

        function set.ParentLayer_I(hObj,newValue)



            hObj.ParentLayer_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Rectangle matlab.graphics.primitive.Rectangle;
    end

    methods
        function valueToCaller=get.Rectangle(hObj)


            valueToCaller=hObj.Rectangle_I;

        end

        function set.Rectangle(hObj,newValue)



            hObj.RectangleMode='manual';


            hObj.Rectangle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        RectangleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RectangleMode(hObj)
            storedValue=hObj.RectangleMode;
        end

        function set.RectangleMode(hObj,newValue)

            oldValue=hObj.RectangleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RectangleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        Rectangle_I;
    end

    methods
        function set.Rectangle_I(hObj,newValue)
            oldValue=hObj.Rectangle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.TipContainer.replaceChild(hObj.Rectangle_I,newValue);
                else

                    hObj.TipContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Rectangle_I=newValue;
            try
                hObj.setRectangle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Text matlab.graphics.primitive.Text;
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

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        Text_I;
    end

    methods
        function set.Text_I(hObj,newValue)
            oldValue=hObj.Text_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.TipContainer.replaceChild(hObj.Text_I,newValue);
                else

                    hObj.TipContainer.addNode(newValue);
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        TextFormatHelper matlab.graphics.shape.internal.TextFormatHelper;
    end

    methods
        function valueToCaller=get.TextFormatHelper(hObj)


            valueToCaller=hObj.TextFormatHelper_I;

        end

        function set.TextFormatHelper(hObj,newValue)



            hObj.TextFormatHelperMode='manual';


            hObj.TextFormatHelper_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TextFormatHelperMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextFormatHelperMode(hObj)
            storedValue=hObj.TextFormatHelperMode;
        end

        function set.TextFormatHelperMode(hObj,newValue)

            oldValue=hObj.TextFormatHelperMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TextFormatHelperMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        TextFormatHelper_I matlab.graphics.shape.internal.TextFormatHelper;
    end

    methods
        function storedValue=get.TextFormatHelper_I(hObj)
            storedValue=hObj.TextFormatHelper_I;
        end

        function set.TextFormatHelper_I(hObj,newValue)



            hObj.TextFormatHelper_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Curvature matlab.internal.datatype.matlab.graphics.datatype.Positive=.1;
    end

    methods
        function storedValue=get.Curvature(hObj)




            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Curvature;
        end

        function set.Curvature(hObj,newValue)






            hObj.CurvatureMode='manual';
            hObj.Curvature_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CurvatureMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CurvatureMode(hObj)
            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.CurvatureMode;
        end

        function set.CurvatureMode(hObj,newValue)


            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.CurvatureMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Curvature_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.1;
    end

    methods
        function storedValue=get.Curvature_I(hObj)
            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Curvature_I;
        end

        function set.Curvature_I(hObj,newValue)


            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Curvature_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.98,.98,1];
    end

    methods
        function storedValue=get.FaceColor(hObj)




            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.FaceColor;
        end

        function set.FaceColor(hObj,newValue)






            hObj.FaceColorMode='manual';
            hObj.FaceColor_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceColorMode(hObj)
            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceColorMode;
        end

        function set.FaceColorMode(hObj,newValue)


            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.98,.98,1];
    end

    methods
        function storedValue=get.FaceColor_I(hObj)
            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FaceColor_I;
        end

        function set.FaceColor_I(hObj,newValue)


            passObj=hObj.Rectangle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FaceColor_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        CurrentTip='off';
    end

    methods
        function valueToCaller=get.CurrentTip(hObj)


            valueToCaller=hObj.CurrentTip_I;

        end

        function set.CurrentTip(hObj,newValue)



            hObj.CurrentTipMode='manual';


            hObj.CurrentTip_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CurrentTipMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CurrentTipMode(hObj)
            storedValue=hObj.CurrentTipMode;
        end

        function set.CurrentTipMode(hObj,newValue)

            oldValue=hObj.CurrentTipMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CurrentTipMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        CurrentTip_I='off';
    end

    methods
        function storedValue=get.CurrentTip_I(hObj)
            storedValue=hObj.CurrentTip_I;
        end

        function set.CurrentTip_I(hObj,newValue)



            hObj.CurrentTip_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        BackgroundAlpha=1;
    end

    methods
        function valueToCaller=get.BackgroundAlpha(hObj)


            valueToCaller=hObj.BackgroundAlpha_I;

        end

        function set.BackgroundAlpha(hObj,newValue)



            hObj.BackgroundAlphaMode='manual';


            hObj.BackgroundAlpha_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BackgroundAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BackgroundAlphaMode(hObj)
            storedValue=hObj.BackgroundAlphaMode;
        end

        function set.BackgroundAlphaMode(hObj,newValue)

            oldValue=hObj.BackgroundAlphaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BackgroundAlphaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BackgroundAlpha_I=1;
    end

    methods
        function storedValue=get.BackgroundAlpha_I(hObj)
            storedValue=hObj.BackgroundAlpha_I;
        end

        function set.BackgroundAlpha_I(hObj,newValue)



            hObj.BackgroundAlpha_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        BackgroundColor='none';
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

        BackgroundColor_I='none';
    end

    methods
        function storedValue=get.BackgroundColor_I(hObj)
            storedValue=hObj.BackgroundColor_I;
        end

        function set.BackgroundColor_I(hObj,newValue)



            hObj.BackgroundColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Color=[.25,.25,.25];
    end

    methods
        function storedValue=get.Color(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Color;
        end

        function set.Color(hObj,newValue)






            hObj.ColorMode='manual';
            hObj.Color_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColorMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.ColorMode;
        end

        function set.ColorMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.ColorMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Color_I=[.25,.25,.25];
    end

    methods
        function storedValue=get.Color_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Color_I;
        end

        function set.Color_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Color_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        EdgeColor=[.65,.65,.65];
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

        EdgeColor_I=[.65,.65,.65];
    end

    methods
        function storedValue=get.EdgeColor_I(hObj)
            storedValue=hObj.EdgeColor_I;
        end

        function set.EdgeColor_I(hObj,newValue)



            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

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



            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontAngle='normal';
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

        FontAngle_I='normal';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontName;
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

        FontName_I;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontUnits='points';
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

        FontUnits_I='points';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontSize;
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

        FontSize_I;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontWeight='normal';
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

        FontWeight_I='normal';
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

        Interpreter='tex';
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

        Interpreter_I='tex';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Margin matlab.internal.datatype.matlab.graphics.datatype.Positive=5;
    end

    methods
        function storedValue=get.Margin(hObj)




            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Margin;
        end

        function set.Margin(hObj,newValue)






            hObj.MarginMode='manual';
            hObj.Margin_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarginMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarginMode(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.MarginMode;
        end

        function set.MarginMode(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.MarginMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Margin_I matlab.internal.datatype.matlab.graphics.datatype.Positive=5;
    end

    methods
        function storedValue=get.Margin_I(hObj)
            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Margin_I;
        end

        function set.Margin_I(hObj,newValue)


            passObj=hObj.Text;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Margin_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        String='';
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

        String_I='';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        TargetType='';
    end

    methods
        function valueToCaller=get.TargetType(hObj)


            valueToCaller=hObj.TargetType_I;

        end

        function set.TargetType(hObj,newValue)



            hObj.TargetTypeMode='manual';


            hObj.TargetType_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TargetTypeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TargetTypeMode(hObj)
            storedValue=hObj.TargetTypeMode;
        end

        function set.TargetTypeMode(hObj,newValue)

            oldValue=hObj.TargetTypeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TargetTypeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TargetType_I='';
    end

    methods
        function storedValue=get.TargetType_I(hObj)
            storedValue=hObj.TargetType_I;
        end

        function set.TargetType_I(hObj,newValue)



            hObj.TargetType_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Orientation='topright';
    end

    methods
        function valueToCaller=get.Orientation(hObj)


            valueToCaller=hObj.Orientation_I;

        end

        function set.Orientation(hObj,newValue)



            hObj.OrientationMode='manual';


            hObj.Orientation_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        OrientationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.OrientationMode(hObj)
            storedValue=hObj.OrientationMode;
        end

        function set.OrientationMode(hObj,newValue)

            oldValue=hObj.OrientationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.OrientationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Orientation_I='topright';
    end

    methods
        function storedValue=get.Orientation_I(hObj)
            storedValue=hObj.Orientation_I;
        end

        function set.Orientation_I(hObj,newValue)



            hObj.Orientation_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LocatorSize=5;
    end

    methods
        function valueToCaller=get.LocatorSize(hObj)


            valueToCaller=hObj.LocatorSize_I;

        end

        function set.LocatorSize(hObj,newValue)



            hObj.LocatorSizeMode='manual';


            hObj.LocatorSize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LocatorSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LocatorSizeMode(hObj)
            storedValue=hObj.LocatorSizeMode;
        end

        function set.LocatorSizeMode(hObj,newValue)

            oldValue=hObj.LocatorSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LocatorSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LocatorSize_I=5;
    end

    methods
        function storedValue=get.LocatorSize_I(hObj)
            storedValue=hObj.LocatorSize_I;
        end

        function set.LocatorSize_I(hObj,newValue)



            hObj.LocatorSize_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Position=[0,0,0];
    end

    methods
        function valueToCaller=get.Position(hObj)


            valueToCaller=hObj.Position_I;

        end

        function set.Position(hObj,newValue)



            hObj.PositionMode='manual';


            hObj.Position_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PositionMode(hObj)
            storedValue=hObj.PositionMode;
        end

        function set.PositionMode(hObj,newValue)

            oldValue=hObj.PositionMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PositionMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Position_I=[0,0,0];
    end

    methods
        function storedValue=get.Position_I(hObj)
            storedValue=hObj.Position_I;
        end

        function set.Position_I(hObj,newValue)



            hObj.Position_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'ScribeHost')
                b=true;
                return;
            end
            if strcmp(name,'ScribeHost_I')
                b=true;
                return;
            end
            if strcmp(name,'TipContainer')
                b=true;
                return;
            end
            if strcmp(name,'TipContainer_I')
                b=true;
                return;
            end
            if strcmp(name,'Rectangle')
                b=true;
                return;
            end
            if strcmp(name,'Rectangle_I')
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
            b=isChildProperty@matlab.graphics.shape.internal.TipInfo(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=GraphicsTip(varargin)






            hObj.ScribeHost_I=matlab.graphics.shape.internal.ScribeHost;

            set(hObj.ScribeHost,'Description_I','GraphicsTip ScribeHost');

            set(hObj.ScribeHost,'Internal',true);

            hObj.TipContainer_I=matlab.graphics.primitive.world.CompositeMarker;

            set(hObj.TipContainer,'Description_I','GraphicsTip TipContainer');

            set(hObj.TipContainer,'Internal',true);

            hObj.Rectangle_I=matlab.graphics.primitive.Rectangle;

            set(hObj.Rectangle,'Description_I','GraphicsTip Rectangle');

            set(hObj.Rectangle,'Internal',true);

            hObj.Text_I=matlab.graphics.primitive.Text;

            set(hObj.Text,'Description_I','GraphicsTip Text');

            set(hObj.Text,'Internal',true);


            hObj.Curvature_I=.1;

            hObj.FaceColor_I=[.98,.98,1];

            hObj.Color_I=[.25,.25,.25];

            hObj.FontAngle_I='normal';

            hObj.FontUnits_I='points';

            hObj.FontWeight_I='normal';

            hObj.Interpreter_I='tex';

            hObj.Margin_I=5;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setScribeHost_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setTipContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setRectangle_IFanoutProps(hObj)
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


    methods(Access='public',Hidden=true)
        function setPickability(hObj,val)

            hObj.ScribeHost.PeerHandle.PickableParts=val;
        end
    end
    methods(Access='public',Hidden=true)
        function doSetup(hObj)


            hObj.Text.HitTest='off';
            hObj.Rectangle.HitTest='off';

            hObj.Rectangle.XLimInclude='off';
            hObj.Rectangle.YLimInclude='off';
            hObj.Rectangle.ZLimInclude='off';


            hObj.TextFormatHelper=matlab.graphics.shape.internal.TextFormatHelper();


            hObj.Text.Layer='middle';

            hObj.ScribeHost.PositionProperty='VertexData';
            hObj.ScribeHost.PerformTransform=true;
            hObj.ScribeHost.Tag='GraphicsTip';


            hObj.addDependencyConsumed('view');


            hObj.ScribeHost.addlistener('Hit',@(s,e)hObj.notify('Hit',e));
        end
    end
    methods(Access='public',Hidden=true)
        function setFormattedTextString(hObj,hDescriptors)

            hObj.String=hObj.TextFormatHelper.formatDatatipForStandardStringStrategy(hDescriptors,hObj.FontAngle,false);
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='private',Hidden=true)

        hitCallback(hObj,src,evd)
    end




end
