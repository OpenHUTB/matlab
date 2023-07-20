
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?matlab.graphics.illustration.BubbleLegend})AbstractLegend<matlab.graphics.illustration.internal.AbstractComputedLegend&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.internal.GraphicsJavaVisible&matlab.graphics.mixin.UIParentable&matlab.graphics.mixin.Background&matlab.graphics.mixin.ChartLayoutable





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Camera matlab.graphics.axis.camera.Camera2D;
    end

    methods
        function valueToCaller=get.Camera(hObj)


            valueToCaller=hObj.Camera_I;

        end

        function set.Camera(hObj,newValue)



            hObj.CameraMode='manual';


            hObj.Camera_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        CameraMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CameraMode(hObj)
            storedValue=hObj.CameraMode;
        end

        function set.CameraMode(hObj,newValue)

            oldValue=hObj.CameraMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CameraMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Camera_I;
    end

    methods
        function set.Camera_I(hObj,newValue)
            hObj.Camera_I=newValue;
            try
                hObj.setCamera_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        DataSpace matlab.graphics.axis.dataspace.DataSpace;
    end

    methods
        function valueToCaller=get.DataSpace(hObj)


            valueToCaller=hObj.DataSpace_I;

        end

        function set.DataSpace(hObj,newValue)



            hObj.DataSpaceMode='manual';


            hObj.DataSpace_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        DataSpaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.DataSpaceMode(hObj)
            storedValue=hObj.DataSpaceMode;
        end

        function set.DataSpaceMode(hObj,newValue)

            oldValue=hObj.DataSpaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.DataSpaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        DataSpace_I;
    end

    methods
        function set.DataSpace_I(hObj,newValue)
            oldValue=hObj.DataSpace_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Camera.replaceChild(hObj.DataSpace_I,newValue);
                else

                    hObj.Camera.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.DataSpace_I=newValue;
            try
                hObj.setDataSpace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        ColorSpace matlab.graphics.axis.colorspace.ColorSpace;
    end

    methods
        function valueToCaller=get.ColorSpace(hObj)


            valueToCaller=hObj.ColorSpace_I;

        end

        function set.ColorSpace(hObj,newValue)



            hObj.ColorSpaceMode='manual';


            hObj.ColorSpace_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        ColorSpaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColorSpaceMode(hObj)
            storedValue=hObj.ColorSpaceMode;
        end

        function set.ColorSpaceMode(hObj,newValue)

            oldValue=hObj.ColorSpaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColorSpaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        ColorSpace_I;
    end

    methods
        function set.ColorSpace_I(hObj,newValue)
            oldValue=hObj.ColorSpace_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DataSpace.replaceChild(hObj.ColorSpace_I,newValue);
                else

                    hObj.DataSpace.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.ColorSpace_I=newValue;
            try
                hObj.setColorSpace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        DecorationContainer matlab.graphics.primitive.world.Group;
    end

    methods
        function valueToCaller=get.DecorationContainer(hObj)


            valueToCaller=hObj.DecorationContainer_I;

        end

        function set.DecorationContainer(hObj,newValue)



            hObj.DecorationContainerMode='manual';


            hObj.DecorationContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        DecorationContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.DecorationContainerMode(hObj)
            storedValue=hObj.DecorationContainerMode;
        end

        function set.DecorationContainerMode(hObj,newValue)

            oldValue=hObj.DecorationContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.DecorationContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        DecorationContainer_I;
    end

    methods
        function set.DecorationContainer_I(hObj,newValue)
            oldValue=hObj.DecorationContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.ColorSpace.replaceChild(hObj.DecorationContainer_I,newValue);
                else

                    hObj.ColorSpace.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.DecorationContainer_I=newValue;
            try
                hObj.setDecorationContainer_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BoxEdge matlab.graphics.primitive.world.LineLoop;
    end

    methods
        function valueToCaller=get.BoxEdge(hObj)


            valueToCaller=hObj.BoxEdge_I;

        end

        function set.BoxEdge(hObj,newValue)



            hObj.BoxEdgeMode='manual';


            hObj.BoxEdge_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BoxEdgeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoxEdgeMode(hObj)
            storedValue=hObj.BoxEdgeMode;
        end

        function set.BoxEdgeMode(hObj,newValue)

            oldValue=hObj.BoxEdgeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BoxEdgeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        BoxEdge_I;
    end

    methods
        function set.BoxEdge_I(hObj,newValue)
            oldValue=hObj.BoxEdge_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.BoxEdge_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.BoxEdge_I=newValue;
            try
                hObj.setBoxEdge_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BoxFace matlab.graphics.primitive.world.Quadrilateral;
    end

    methods
        function valueToCaller=get.BoxFace(hObj)


            valueToCaller=hObj.BoxFace_I;

        end

        function set.BoxFace(hObj,newValue)



            hObj.BoxFaceMode='manual';


            hObj.BoxFace_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BoxFaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoxFaceMode(hObj)
            storedValue=hObj.BoxFaceMode;
        end

        function set.BoxFaceMode(hObj,newValue)

            oldValue=hObj.BoxFaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BoxFaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        BoxFace_I;
    end

    methods
        function set.BoxFace_I(hObj,newValue)
            oldValue=hObj.BoxFace_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.BoxFace_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.BoxFace_I=newValue;
            try
                hObj.setBoxFace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=false)

        Title matlab.graphics.illustration.legend.Text;
    end

    methods
        function valueToCaller=get.Title(hObj)



            valueToCaller=hObj.getTitleImpl(hObj.Title_I);


        end

        function set.Title(hObj,newValue)



            hObj.TitleMode='manual';



            reallyDoCopy=~isequal(hObj.Title_I,newValue);

            if reallyDoCopy
                hObj.Title_I=hObj.setTitleImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TitleMode(hObj)
            storedValue=hObj.TitleMode;
        end

        function set.TitleMode(hObj,newValue)

            oldValue=hObj.TitleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TitleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true,AffectsLegend)

        Title_I matlab.graphics.illustration.legend.Text;
    end

    methods





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

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        SelectionHandle_I;
    end

    methods
        function set.SelectionHandle_I(hObj,newValue)
            oldValue=hObj.SelectionHandle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.SelectionHandle_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.SelectionHandle_I=newValue;
            try
                hObj.setSelectionHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        TitleSeparator matlab.graphics.primitive.world.LineStrip;
    end

    methods
        function valueToCaller=get.TitleSeparator(hObj)


            valueToCaller=hObj.TitleSeparator_I;

        end

        function set.TitleSeparator(hObj,newValue)



            hObj.TitleSeparatorMode='manual';


            hObj.TitleSeparator_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TitleSeparatorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TitleSeparatorMode(hObj)
            storedValue=hObj.TitleSeparatorMode;
        end

        function set.TitleSeparatorMode(hObj,newValue)

            oldValue=hObj.TitleSeparatorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TitleSeparatorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        TitleSeparator_I;
    end

    methods
        function set.TitleSeparator_I(hObj,newValue)
            oldValue=hObj.TitleSeparator_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.TitleSeparator_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.TitleSeparator_I=newValue;
            try
                hObj.setTitleSeparator_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Axes matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Axes(hObj)


            valueToCaller=hObj.Axes_I;

        end

        function set.Axes(hObj,newValue)



            hObj.AxesMode='manual';


            hObj.Axes_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AxesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AxesMode(hObj)
            storedValue=hObj.AxesMode;
        end

        function set.AxesMode(hObj,newValue)

            oldValue=hObj.AxesMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AxesMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,ReconnectOnCopy=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Axes_I matlab.graphics.Graphics;
    end

    methods
        function storedValue=get.Axes_I(hObj)
            storedValue=hObj.getAxesImpl(hObj.Axes_I);
        end

        function set.Axes_I(hObj,newValue)
            oldValue=hObj.Axes_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Axes_I=hObj.setAxesImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        AxesListenerList event.listener=event.listener.empty;
    end

    methods
        function valueToCaller=get.AxesListenerList(hObj)


            valueToCaller=hObj.AxesListenerList_I;

        end

        function set.AxesListenerList(hObj,newValue)



            hObj.AxesListenerListMode='manual';


            hObj.AxesListenerList_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        AxesListenerListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AxesListenerListMode(hObj)
            storedValue=hObj.AxesListenerListMode;
        end

        function set.AxesListenerListMode(hObj,newValue)

            oldValue=hObj.AxesListenerListMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AxesListenerListMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        AxesListenerList_I event.listener=event.listener.empty;
    end

    methods
        function storedValue=get.AxesListenerList_I(hObj)
            storedValue=hObj.AxesListenerList_I;
        end

        function set.AxesListenerList_I(hObj,newValue)



            hObj.AxesListenerList_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Box matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.Box(hObj)


            valueToCaller=hObj.Box_I;

        end

        function set.Box(hObj,newValue)



            hObj.BoxMode='manual';


            hObj.Box_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BoxMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoxMode(hObj)
            storedValue=hObj.BoxMode;
        end

        function set.BoxMode(hObj,newValue)

            oldValue=hObj.BoxMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BoxMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Box_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.Box_I(hObj)
            storedValue=hObj.Box_I;
        end

        function set.Box_I(hObj,newValue)



            fanChild=hObj.BoxEdge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'VisibleMode'),'auto')
                    set(fanChild,'Visible_I',newValue);
                end
            end
            fanChild=hObj.BoxFace;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'VisibleMode'),'auto')
                    set(fanChild,'Visible_I',newValue);
                end
            end
            fanChild=hObj.TitleSeparator;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'VisibleMode'),'auto')
                    set(fanChild,'Visible_I',newValue);
                end
            end
            hObj.Box_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[1,1,1];
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

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[1,1,1];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.BoxFace;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.2,.2,.2];
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

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.2,.2,.2];
    end

    methods
        function storedValue=get.EdgeColor_I(hObj)
            storedValue=hObj.EdgeColor_I;
        end

        function set.EdgeColor_I(hObj,newValue)



            fanChild=hObj.BoxEdge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            fanChild=hObj.TitleSeparator;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
    end

    methods
        function valueToCaller=get.FontName(hObj)

            if strcmpi(get(hObj,'FontNameMode'),'auto')
                forceFullUpdate(hObj,'all','FontName');
            end


            valueToCaller=hObj.FontName_I;

        end

        function set.FontName(hObj,newValue)



            hObj.FontNameMode='manual';


            hObj.FontName_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontNameMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontNameMode(hObj)
            storedValue=hObj.FontNameMode;
        end

        function set.FontNameMode(hObj,newValue)

            oldValue=hObj.FontNameMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FontNameMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FontName_I matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
    end

    methods
        function storedValue=get.FontName_I(hObj)
            storedValue=hObj.FontName_I;
        end

        function set.FontName_I(hObj,newValue)



            hObj.FontName_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
    end

    methods
        function valueToCaller=get.FontSize(hObj)

            if strcmpi(get(hObj,'FontSizeMode'),'auto')
                forceFullUpdate(hObj,'all','FontSize');
            end


            valueToCaller=hObj.FontSize_I;

        end

        function set.FontSize(hObj,newValue)



            hObj.FontSizeMode='manual';


            hObj.FontSize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontSizeMode(hObj)
            storedValue=hObj.FontSizeMode;
        end

        function set.FontSizeMode(hObj,newValue)

            oldValue=hObj.FontSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FontSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
    end

    methods
        function storedValue=get.FontSize_I(hObj)
            storedValue=hObj.FontSize_I;
        end

        function set.FontSize_I(hObj,newValue)



            hObj.FontSize_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        FontUnits matlab.internal.datatype.matlab.graphics.datatype.FontUnits='points';
    end

    methods
        function valueToCaller=get.FontUnits(hObj)


            valueToCaller=hObj.FontUnits_I;

        end

        function set.FontUnits(hObj,newValue)



            hObj.FontUnitsMode='manual';


            hObj.FontUnits_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontUnitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontUnitsMode(hObj)
            storedValue=hObj.FontUnitsMode;
        end

        function set.FontUnitsMode(hObj,newValue)

            oldValue=hObj.FontUnitsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FontUnitsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FontUnits_I matlab.internal.datatype.matlab.graphics.datatype.FontUnits='points';
    end

    methods
        function storedValue=get.FontUnits_I(hObj)
            storedValue=hObj.FontUnits_I;
        end

        function set.FontUnits_I(hObj,newValue)



            hObj.FontUnits_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
    end

    methods
        function valueToCaller=get.FontAngle(hObj)

            if strcmpi(get(hObj,'FontAngleMode'),'auto')
                forceFullUpdate(hObj,'all','FontAngle');
            end


            valueToCaller=hObj.FontAngle_I;

        end

        function set.FontAngle(hObj,newValue)



            hObj.FontAngleMode='manual';


            hObj.FontAngle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontAngleMode(hObj)
            storedValue=hObj.FontAngleMode;
        end

        function set.FontAngleMode(hObj,newValue)

            oldValue=hObj.FontAngleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FontAngleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FontAngle_I matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
    end

    methods
        function storedValue=get.FontAngle_I(hObj)
            storedValue=hObj.FontAngle_I;
        end

        function set.FontAngle_I(hObj,newValue)



            hObj.FontAngle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
    end

    methods
        function valueToCaller=get.FontWeight(hObj)

            if strcmpi(get(hObj,'FontWeightMode'),'auto')
                forceFullUpdate(hObj,'all','FontWeight');
            end


            valueToCaller=hObj.FontWeight_I;

        end

        function set.FontWeight(hObj,newValue)



            hObj.FontWeightMode='manual';


            hObj.FontWeight_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontWeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FontWeightMode(hObj)
            storedValue=hObj.FontWeightMode;
        end

        function set.FontWeightMode(hObj,newValue)

            oldValue=hObj.FontWeightMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FontWeightMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FontWeight_I matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
    end

    methods
        function storedValue=get.FontWeight_I(hObj)
            storedValue=hObj.FontWeight_I;
        end

        function set.FontWeight_I(hObj,newValue)



            hObj.FontWeight_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function valueToCaller=get.Interpreter(hObj)


            valueToCaller=hObj.Interpreter_I;

        end

        function set.Interpreter(hObj,newValue)



            hObj.InterpreterMode='manual';


            hObj.Interpreter_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        InterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.InterpreterMode(hObj)
            storedValue=hObj.InterpreterMode;
        end

        function set.InterpreterMode(hObj,newValue)

            oldValue=hObj.InterpreterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.InterpreterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Interpreter_I matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function storedValue=get.Interpreter_I(hObj)
            storedValue=hObj.Interpreter_I;
        end

        function set.Interpreter_I(hObj,newValue)



            hObj.Interpreter_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        InitPositionCache logical=true;
    end

    methods
        function storedValue=get.InitPositionCache(hObj)
            storedValue=hObj.InitPositionCache;
        end

        function set.InitPositionCache(hObj,newValue)



            hObj.InitPositionCache=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        WindowMouseReleaseListener event.listener=event.listener.empty;
    end

    methods
        function valueToCaller=get.WindowMouseReleaseListener(hObj)


            valueToCaller=hObj.WindowMouseReleaseListener_I;

        end

        function set.WindowMouseReleaseListener(hObj,newValue)



            hObj.WindowMouseReleaseListenerMode='manual';


            hObj.WindowMouseReleaseListener_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        WindowMouseReleaseListenerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.WindowMouseReleaseListenerMode(hObj)
            storedValue=hObj.WindowMouseReleaseListenerMode;
        end

        function set.WindowMouseReleaseListenerMode(hObj,newValue)

            oldValue=hObj.WindowMouseReleaseListenerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.WindowMouseReleaseListenerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        WindowMouseReleaseListener_I event.listener=event.listener.empty;
    end

    methods
        function storedValue=get.WindowMouseReleaseListener_I(hObj)
            storedValue=hObj.WindowMouseReleaseListener_I;
        end

        function set.WindowMouseReleaseListener_I(hObj,newValue)



            hObj.WindowMouseReleaseListener_I=newValue;

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



            fanChild=hObj.BoxEdge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.TitleSeparator;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='private',Dependent=true,Hidden=true)

        Orientation matlab.internal.datatype.matlab.graphics.chart.datatype.LegendOrientationType='vertical';
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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        Orientation_I matlab.internal.datatype.matlab.graphics.chart.datatype.LegendOrientationType='vertical';
    end

    methods
        function storedValue=get.Orientation_I(hObj)
            storedValue=hObj.getOrientationImpl(hObj.Orientation_I);
        end

        function set.Orientation_I(hObj,newValue)
            oldValue=hObj.Orientation_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Orientation_I=hObj.setOrientationImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        PlotChildren matlab.graphics.Graphics=[];
    end

    methods
        function valueToCaller=get.PlotChildren(hObj)

            if strcmpi(get(hObj,'PlotChildrenMode'),'auto')
                forceFullUpdate(hObj,'all','PlotChildren');
            end



            valueToCaller=hObj.getPlotChildrenImpl(hObj.PlotChildren_I);


        end

        function set.PlotChildren(hObj,newValue)



            hObj.PlotChildrenMode='manual';



            reallyDoCopy=~isequal(hObj.PlotChildren_I,newValue);

            if reallyDoCopy
                hObj.PlotChildren_I=hObj.setPlotChildrenImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PlotChildrenMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PlotChildrenMode(hObj)
            storedValue=hObj.PlotChildrenMode;
        end

        function set.PlotChildrenMode(hObj,newValue)

            oldValue=hObj.PlotChildrenMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PlotChildrenMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,ReconnectOnCopy=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        PlotChildren_I matlab.graphics.Graphics=[];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Height=[];
    end

    methods
        function valueToCaller=get.Height(hObj)


            valueToCaller=hObj.Height_I;

        end

        function set.Height(hObj,newValue)



            hObj.HeightMode='manual';


            hObj.Height_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HeightMode(hObj)
            storedValue=hObj.HeightMode;
        end

        function set.HeightMode(hObj,newValue)

            oldValue=hObj.HeightMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HeightMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Height_I=[];
    end

    methods
        function storedValue=get.Height_I(hObj)
            storedValue=hObj.getHeightImpl(hObj.Height_I);
        end

        function set.Height_I(hObj,newValue)
            oldValue=hObj.Height_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Height_I=hObj.setHeightImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Width=[];
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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Width_I=[];
    end

    methods
        function storedValue=get.Width_I(hObj)
            storedValue=hObj.getWidthImpl(hObj.Width_I);
        end

        function set.Width_I(hObj,newValue)
            oldValue=hObj.Width_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Width_I=hObj.setWidthImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Position matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,1,1];
    end

    methods
        function valueToCaller=get.Position(hObj)

            if strcmpi(get(hObj,'PositionMode'),'auto')
                forceFullUpdate(hObj,'all','Position');
            end


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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Position_I matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,1,1];
    end

    methods
        function storedValue=get.Position_I(hObj)
            storedValue=hObj.getPositionImpl(hObj.Position_I);
        end

        function set.Position_I(hObj,newValue)
            oldValue=hObj.Position_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Position_I=hObj.setPositionImpl(newValue);
            end
        end
    end


    properties(SetObservable=true,SetAccess={?matlab.graphics.illustration.BubbleLegend},GetAccess={?matlab.graphics.illustration.BubbleLegend},Dependent=false,Hidden=true,Transient=true)

        SPosition;
    end

    methods
        function storedValue=get.SPosition(hObj)
            storedValue=hObj.SPosition;
        end

        function set.SPosition(hObj,newValue)



            hObj.SPosition=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        PositionCache=[];
    end

    methods
        function storedValue=get.PositionCache(hObj)
            storedValue=hObj.PositionCache;
        end

        function set.PositionCache(hObj,newValue)



            hObj.PositionCache=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        ParentSizeChangedListener event.listener=event.listener.empty;
    end

    methods
        function storedValue=get.ParentSizeChangedListener(hObj)
            storedValue=hObj.ParentSizeChangedListener;
        end

        function set.ParentSizeChangedListener(hObj,newValue)



            hObj.ParentSizeChangedListener=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        PrintAlphaSupported logical=true;
    end

    methods
        function valueToCaller=get.PrintAlphaSupported(hObj)


            valueToCaller=hObj.PrintAlphaSupported_I;

        end

        function set.PrintAlphaSupported(hObj,newValue)



            hObj.PrintAlphaSupportedMode='manual';


            hObj.PrintAlphaSupported_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PrintAlphaSupportedMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PrintAlphaSupportedMode(hObj)
            storedValue=hObj.PrintAlphaSupportedMode;
        end

        function set.PrintAlphaSupportedMode(hObj,newValue)

            oldValue=hObj.PrintAlphaSupportedMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PrintAlphaSupportedMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        PrintAlphaSupported_I logical=true;
    end

    methods
        function storedValue=get.PrintAlphaSupported_I(hObj)
            storedValue=hObj.PrintAlphaSupported_I;
        end

        function set.PrintAlphaSupported_I(hObj,newValue)



            hObj.PrintAlphaSupported_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        PreventLegendResizePrintingPosition=[];
    end

    methods
        function storedValue=get.PreventLegendResizePrintingPosition(hObj)
            storedValue=hObj.PreventLegendResizePrintingPosition;
        end

        function set.PreventLegendResizePrintingPosition(hObj,newValue)



            hObj.PreventLegendResizePrintingPosition=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        SelfListenerList event.listener=event.listener.empty;
    end

    methods
        function valueToCaller=get.SelfListenerList(hObj)


            valueToCaller=hObj.SelfListenerList_I;

        end

        function set.SelfListenerList(hObj,newValue)



            hObj.SelfListenerListMode='manual';


            hObj.SelfListenerList_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        SelfListenerListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SelfListenerListMode(hObj)
            storedValue=hObj.SelfListenerListMode;
        end

        function set.SelfListenerListMode(hObj,newValue)

            oldValue=hObj.SelfListenerListMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SelfListenerListMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        SelfListenerList_I event.listener=event.listener.empty;
    end

    methods
        function storedValue=get.SelfListenerList_I(hObj)
            storedValue=hObj.SelfListenerList_I;
        end

        function set.SelfListenerList_I(hObj,newValue)



            hObj.SelfListenerList_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.TextColor(hObj)


            valueToCaller=hObj.TextColor_I;

        end

        function set.TextColor(hObj,newValue)



            hObj.TextColorMode='manual';


            hObj.TextColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TextColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextColorMode(hObj)
            storedValue=hObj.TextColorMode;
        end

        function set.TextColorMode(hObj,newValue)

            oldValue=hObj.TextColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TextColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TextColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.TextColor_I(hObj)
            storedValue=hObj.TextColor_I;
        end

        function set.TextColor_I(hObj,newValue)



            hObj.TextColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Units matlab.internal.datatype.matlab.graphics.datatype.Units='normalized';
    end

    methods
        function valueToCaller=get.Units(hObj)


            valueToCaller=hObj.Units_I;

        end

        function set.Units(hObj,newValue)



            hObj.UnitsMode='manual';


            hObj.Units_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        UnitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.UnitsMode(hObj)
            storedValue=hObj.UnitsMode;
        end

        function set.UnitsMode(hObj,newValue)

            oldValue=hObj.UnitsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.UnitsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Units_I matlab.internal.datatype.matlab.graphics.datatype.Units='normalized';
    end

    methods
        function storedValue=get.Units_I(hObj)
            storedValue=hObj.getUnitsImpl(hObj.Units_I);
        end

        function set.Units_I(hObj,newValue)
            oldValue=hObj.Units_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Units_I=hObj.setUnitsImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        standalone matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.standalone(hObj)


            valueToCaller=hObj.standalone_I;

        end

        function set.standalone(hObj,newValue)



            hObj.standaloneMode='manual';


            hObj.standalone_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        standaloneMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.standaloneMode(hObj)
            storedValue=hObj.standaloneMode;
        end

        function set.standaloneMode(hObj,newValue)

            oldValue=hObj.standaloneMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.standaloneMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        standalone_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.standalone_I(hObj)
            storedValue=hObj.standalone_I;
        end

        function set.standalone_I(hObj,newValue)



            hObj.standalone_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Camera')
                b=true;
                return;
            end
            if strcmp(name,'Camera_I')
                b=true;
                return;
            end
            if strcmp(name,'DataSpace')
                b=true;
                return;
            end
            if strcmp(name,'DataSpace_I')
                b=true;
                return;
            end
            if strcmp(name,'ColorSpace')
                b=true;
                return;
            end
            if strcmp(name,'ColorSpace_I')
                b=true;
                return;
            end
            if strcmp(name,'DecorationContainer')
                b=true;
                return;
            end
            if strcmp(name,'DecorationContainer_I')
                b=true;
                return;
            end
            if strcmp(name,'BoxEdge')
                b=true;
                return;
            end
            if strcmp(name,'BoxEdge_I')
                b=true;
                return;
            end
            if strcmp(name,'BoxFace')
                b=true;
                return;
            end
            if strcmp(name,'BoxFace_I')
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
            if strcmp(name,'TitleSeparator')
                b=true;
                return;
            end
            if strcmp(name,'TitleSeparator_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.illustration.internal.AbstractComputedLegend(obj,name);
            return;
            b=false;
        end
    end


    events(ListenAccess='public',NotifyAccess='private')
UpdateLayout
    end








    methods(Access='public')
        [list,side]=addToLayout(hObj)
    end






    methods(Access={?tLegend_getNewLocation})
        [newPosPoints]=getNewLocation(hObj,Loc,Size,FinalSizePoints)
    end



    methods
        function hObj=AbstractLegend(varargin)






            hObj.Camera_I=matlab.graphics.axis.camera.Camera2D;

            set(hObj.Camera,'Description_I','AbstractLegend Camera');

            set(hObj.Camera,'Internal',true);

            hObj.DataSpace_I=matlab.graphics.axis.dataspace.UniformCartesianDataSpace;

            set(hObj.DataSpace,'Description_I','AbstractLegend DataSpace');

            set(hObj.DataSpace,'Internal',true);

            hObj.ColorSpace_I=matlab.graphics.axis.colorspace.MapColorSpace;

            set(hObj.ColorSpace,'Description_I','AbstractLegend ColorSpace');

            set(hObj.ColorSpace,'Internal',true);

            hObj.DecorationContainer_I=matlab.graphics.primitive.world.Group;

            set(hObj.DecorationContainer,'Description_I','AbstractLegend DecorationContainer');

            set(hObj.DecorationContainer,'Internal',true);

            hObj.BoxEdge_I=matlab.graphics.primitive.world.LineLoop;

            set(hObj.BoxEdge,'Description_I','AbstractLegend BoxEdge');

            set(hObj.BoxEdge,'Internal',true);

            hObj.BoxFace_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.BoxFace,'Description_I','AbstractLegend BoxFace');

            set(hObj.BoxFace,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','AbstractLegend SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);

            hObj.TitleSeparator_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.TitleSeparator,'Description_I','AbstractLegend TitleSeparator');

            set(hObj.TitleSeparator,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setCamera_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setDataSpace_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setColorSpace_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setDecorationContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setBoxEdge_IFanoutProps(hObj)

            try
                mode=hObj.BoxEdge.VisibleMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxEdge,'Visible_I',hObj.Box_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.BoxEdge,hObj.EdgeColor_I);


            try
                mode=hObj.BoxEdge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxEdge,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setBoxFace_IFanoutProps(hObj)

            try
                mode=hObj.BoxFace.VisibleMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxFace,'Visible_I',hObj.Box_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.BoxFace,hObj.Color_I);

        end
    end
    methods(Access=private)
        function setSelectionHandle_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setTitleSeparator_IFanoutProps(hObj)

            try
                mode=hObj.TitleSeparator.VisibleMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.TitleSeparator,'Visible_I',hObj.Box_I);
            end


            hgfilter('RGBAColorToGeometryPrimitive',hObj.TitleSeparator,hObj.EdgeColor_I);


            try
                mode=hObj.TitleSeparator.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.TitleSeparator,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end


    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access='public',Hidden=true)
        function varargout=getGraphicsAxes(hObj,ax_in)

            if isa(ax_in,'matlab.graphics.axis.AbstractAxes')
                ax_out=ax_in;
            else
                assert(false,'Input must be an AbstractAxes');
            end
            assert(isa(ax_out,'matlab.graphics.axis.AbstractAxes'),'getGraphicsAxes must return an axis.Axes');
            varargout{1}=ax_out;
        end
    end
    methods(Access='private',Hidden=true)

        initializePositionCache(hObj)
    end
    methods(Access='public',Hidden=true)
        function setAbsoluteGraphicsLayoutPosition(hObj,newValue)


            setViewportPosition(hObj,newValue);
        end
    end
    methods(Access='private',Hidden=true)
        function setViewportPosition(hObj,newValue)

            maxPixels=2147483233;
            maxPoints=1.6106e+09;
            maxNormalized=3834792;
            maxCharacters=429496647;
            maxCentimeters=56818828;
            maxInches=22369618;
            unit=hObj.Units;

            posValueTooBig=false;

            if(isequal(unit,'pixels')&&any(newValue>=maxPixels))||...
                (isequal(unit,'points')&&any(newValue>=maxPoints))||...
                (isequal(unit,'normalized')&&any(newValue>=maxNormalized))||...
                (isequal(unit,'characters')&&any(newValue>=maxCharacters))||...
                (isequal(unit,'centimeters')&&any(newValue>=maxCentimeters))||...
                (isequal(unit,'inches')&&any(newValue>=maxInches))

                posValueTooBig=true;

            end

            if posValueTooBig
                error(message('MATLAB:legend:PositionTooBig'));
            end

            hViewPort=hObj.Camera.Viewport;
            hViewPort.Position=newValue;
            set(hObj.Camera,'Viewport',hViewPort)
        end
    end
    methods(Access='public',Hidden=true)
        function scaleForPrinting(hObj,flag,~)

            if strcmpi(hObj.Location,'none')
                switch lower(flag)
                case 'modify'
                    hObj.PreventLegendResizePrintingPosition=hObj.Position;
                case 'revert'
                    if~isempty(hObj.PreventLegendResizePrintingPosition)
                        hObj.Position_I=hObj.PreventLegendResizePrintingPosition;
                        hObj.PreventLegendResizePrintingPosition=[];
                    end
                end
            end
        end
    end
    methods(Access='public',Hidden=true)

        startLabelEditing(hObj,ed)
    end
    methods(Access='private',Hidden=true)

        varargout=getEntries(hObj)
    end
    methods(Access='public',Hidden=true)

        updateTitleProperties(hObj)
    end
    methods(Access='public',Hidden=true)
        function varargout=getBackgroundColor(hObj)

            bc=hObj.Color;
            if strcmp(hObj.Box,'off')
                bc='none';
            end
            varargout{1}=bc;
        end
    end
    methods(Access='public',Hidden=true)

        varargout=doMethod(hObj,fcn,varargin)
    end
    methods(Access='private',Hidden=true)

        doSetup(hObj)
    end
    methods(Access='private',Hidden=true)

        setupBoxEdge(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=saveobj(hObj)
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        doDelete(hObj)
    end
    methods(Access='public',Hidden=true)

        doPostSetup(hObj,version)
    end
    methods(Access='public',Hidden=true)

        attachAxesListeners(hObj,hAxes)
    end
    methods(Access='public',Hidden=true)

        enableAxesDirtyListeners(hObj,trueFalse)
    end
    methods(Access='public',Hidden=true)

        varargout=getPreferredLocation(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getPreferredSize(hObj,varargin)
    end
    methods(Access='public',Hidden=true)

        varargout=getSize(hObj,varargin)
    end
    methods(Access='public',Hidden=true)

        varargout=isStretchToFill(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=getPropertyGroups(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=getDescriptiveLabelForDisplay(hObj)
    end
    methods(Access='private',Hidden=true)
        function varargout=getHeightImpl(hObj,storedValue)

            varargout{1}=hObj.Position_I(4);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setHeightImpl(hObj,newValue)

            hObj.Position_I(4)=newValue;
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getWidthImpl(hObj,storedValue)

            varargout{1}=hObj.Position_I(3);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setWidthImpl(hObj,newValue)

            hObj.Position_I(3)=newValue;
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)

        varargout=getTitleImpl(hObj,storedValue)
    end
    methods(Access='private',Hidden=true)
        function varargout=setTitleImpl(hObj,newValue)



            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getAxesImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setAxesImpl(hObj,newValue)


            if strcmp(hObj.standalone,'on')

                varargout{1}=[];
            else


                if isa(hObj,'matlab.graphics.illustration.BubbleLegend')
                    newValue.BubbleLegend=hObj;
                end




                if~isempty(hObj.Axes)
                    delete(hObj.AxesListenerList);
                    hObj.Axes.setLegendExternal([]);


                    hObj.Axes.CollectLegendableObjects='off';
                end

                if~isempty(newValue)

                    newValue=legendcolorbarlayout(newValue,'addToTree',hObj);


                    hObj.attachAxesListeners(newValue);


                    newValue.setLegendExternal(hObj);


                    newValue.CollectLegendableObjects='on';
                end

                varargout{1}=newValue;
            end

        end
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        varargout=copyElement(hObj)
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        connectCopyToTree(hObj,hCopy,hCopyParent,hContext)
    end
    methods(Access='private',Hidden=true)
        function varargout=getOrientationImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setOrientationImpl(hObj,newValue)

            hObj.WidthMode='auto';
            hObj.HeightMode='auto';
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getPositionImpl(hObj,storedValue)

            pos=hObj.Camera.Viewport.Position;
            if~isempty(hObj.Parent)&&isa(hObj.Parent,'matlab.graphics.layout.Layout')
                pos=hObj.Parent.computeRelativePosition(pos,hObj.Units);
            end
            varargout{1}=pos;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPositionImpl(hObj,newValue)

            if strcmp(hObj.standalone,'on')

                setViewportPosition(hObj,newValue);
            else













                if strcmp(hObj.PositionMode,'manual')&&~isempty(hObj.Parent)&&~isa(hObj.Parent,'matlab.graphics.layout.Layout')
                    hObj.Location_I='none';



                    fig=ancestor(hObj,'Figure');

                    if~isempty(fig)&&~isempty(hObj.Parent)
                        canvasContainer=ancestor(hObj.Parent,'matlab.ui.container.CanvasContainer','node');
                        newPosPoints=hgconvertunits(fig,newValue,hObj.Units,'points',canvasContainer);
                        currPosPoints=hgconvertunits(fig,hObj.Position_I,hObj.Units,'points',canvasContainer);


                        if abs(newPosPoints(3)-currPosPoints(3))>=0.1
                            hObj.WidthMode='manual';
                        end
                        if abs(newPosPoints(4)-currPosPoints(4))>=0.1
                            hObj.HeightMode='manual';
                        end
                    end
                end
                fig=ancestor(hObj,'Figure');
                if isempty(fig)
                    hObj.SPosition=newValue;
                else

                    setViewportPosition(hObj,newValue);
                end
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='public',Hidden=true)
        function setLayoutPosition(hObj,newValue)


            hObj.Position_I=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getUnitsImpl(hObj,storedValue)

            varargout{1}=hObj.Camera.Viewport.Units;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setUnitsImpl(hObj,newValue)


            hViewPort=hObj.Camera.Viewport;
            hViewPort.Units=newValue;
            set(hObj.Camera,'Viewport',hViewPort)

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getPlotChildrenSpecifiedImpl(hObj,storedValue)


            sv=storedValue(:);
            varargout{1}=sv(isvalid(sv));
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPlotChildrenSpecifiedImpl(hObj,newValue)


            for i=1:numel(newValue)
                assert(isa(newValue(i),'matlab.graphics.mixin.Legendable'));
            end

            varargout{1}=newValue(:);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getPlotChildrenImpl(hObj,storedValue)


            sv=storedValue(:);
            varargout{1}=sv;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPlotChildrenImpl(hObj,newValue)


            for i=1:numel(newValue)
                assert(isa(newValue(i),'matlab.graphics.mixin.Legendable'));
            end

            varargout{1}=newValue(:);
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end
    methods(Access='public',Hidden=true)

        varargout=mcodeIgnoreHandle(hObj,h)
    end



    methods
        function fireUpdateLayoutEvent(hObj,data)
            evt=event.EventData(data);
            hObj.notify('UpdateLayout',evt);
        end
    end


end
