
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?MyClass1,?MyClass2})Legend<matlab.graphics.illustration.internal.AbstractExpandableLegend&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.internal.GraphicsJavaVisible&matlab.graphics.mixin.UIParentable&matlab.graphics.mixin.Background&matlab.graphics.mixin.ChartLayoutable





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

        EntryContainer matlab.graphics.primitive.world.Group;
    end

    methods
        function valueToCaller=get.EntryContainer(hObj)


            valueToCaller=hObj.EntryContainer_I;

        end

        function set.EntryContainer(hObj,newValue)



            hObj.EntryContainerMode='manual';


            hObj.EntryContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        EntryContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EntryContainerMode(hObj)
            storedValue=hObj.EntryContainerMode;
        end

        function set.EntryContainerMode(hObj,newValue)

            oldValue=hObj.EntryContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EntryContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        EntryContainer_I;
    end

    methods
        function set.EntryContainer_I(hObj,newValue)
            oldValue=hObj.EntryContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.ColorSpace.replaceChild(hObj.EntryContainer_I,newValue);
                else

                    hObj.ColorSpace.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.EntryContainer_I=newValue;
            try
                hObj.setEntryContainer_IFanoutProps();
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AutoUpdate matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.AutoUpdate(hObj)



            valueToCaller=hObj.getAutoUpdateImpl(hObj.AutoUpdate_I);


        end

        function set.AutoUpdate(hObj,newValue)



            hObj.AutoUpdateMode='manual';



            reallyDoCopy=~isequal(hObj.AutoUpdate_I,newValue);

            if reallyDoCopy
                hObj.AutoUpdate_I=hObj.setAutoUpdateImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AutoUpdateMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AutoUpdateMode(hObj)
            storedValue=hObj.AutoUpdateMode;
        end

        function set.AutoUpdateMode(hObj,newValue)

            oldValue=hObj.AutoUpdateMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AutoUpdateMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AutoUpdate_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods





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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        CLim matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1];
    end

    methods
        function storedValue=get.CLim(hObj)




            passObj=hObj.ColorSpace;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.CLim;
        end

        function set.CLim(hObj,newValue)






            hObj.CLimMode='manual';
            hObj.CLim_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CLimMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CLimMode(hObj)
            passObj=hObj.ColorSpace;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.CLimMode;
        end

        function set.CLimMode(hObj,newValue)


            passObj=hObj.ColorSpace;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.CLimMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CLim_I matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1];
    end

    methods
        function storedValue=get.CLim_I(hObj)
            passObj=hObj.ColorSpace;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.CLim_I;
        end

        function set.CLim_I(hObj,newValue)


            passObj=hObj.ColorSpace;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.CLim_I=newValue;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ItemHitFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=@defaultItemHitCallback;
    end

    methods
        function valueToCaller=get.ItemHitFcn(hObj)


            valueToCaller=hObj.ItemHitFcn_I;

        end

        function set.ItemHitFcn(hObj,newValue)



            hObj.ItemHitFcnMode='manual';


            hObj.ItemHitFcn_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ItemHitFcnMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ItemHitFcnMode(hObj)
            storedValue=hObj.ItemHitFcnMode;
        end

        function set.ItemHitFcnMode(hObj,newValue)

            oldValue=hObj.ItemHitFcnMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ItemHitFcnMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end





















    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,NonCopyable=true)

        ItemHitFcn_I matlab.internal.datatype.matlab.graphics.datatype.Callback=@defaultItemHitCallback;
    end

    methods
        function storedValue=get.ItemHitFcn_I(hObj)
            storedValue=hObj.ItemHitFcn_I;
        end

        function set.ItemHitFcn_I(hObj,newValue)



            reallyDoCopy=~isequal(hObj.ItemHitFcn_I,newValue);
            if~reallyDoCopy&&isa(hObj.ItemHitFcn_I,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(hObj.ItemHitFcn_I==newValue);
            end

            if reallyDoCopy
                hObj.ItemHitFcn_I=newValue;
            end

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        ItemTokenSize(:,1)double=[30,18];
    end

    methods
        function valueToCaller=get.ItemTokenSize(hObj)


            valueToCaller=hObj.ItemTokenSize_I;

        end

        function set.ItemTokenSize(hObj,newValue)



            hObj.ItemTokenSizeMode='manual';


            hObj.ItemTokenSize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ItemTokenSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ItemTokenSizeMode(hObj)
            storedValue=hObj.ItemTokenSizeMode;
        end

        function set.ItemTokenSizeMode(hObj,newValue)

            oldValue=hObj.ItemTokenSizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ItemTokenSizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ItemTokenSize_I(:,1)double=[30,18];
    end

    methods
        function storedValue=get.ItemTokenSize_I(hObj)
            storedValue=hObj.ItemTokenSize_I;
        end

        function set.ItemTokenSize_I(hObj,newValue)



            hObj.ItemTokenSize_I=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Location matlab.internal.datatype.matlab.graphics.datatype.LegendLocationType='northeast';
    end

    methods
        function valueToCaller=get.Location(hObj)


            valueToCaller=hObj.Location_I;

        end

        function set.Location(hObj,newValue)



            hObj.LocationMode='manual';


            hObj.Location_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LocationMode(hObj)
            storedValue=hObj.LocationMode;
        end

        function set.LocationMode(hObj,newValue)

            oldValue=hObj.LocationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LocationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Location_I matlab.internal.datatype.matlab.graphics.datatype.LegendLocationType='northeast';
    end

    methods
        function storedValue=get.Location_I(hObj)
            storedValue=hObj.getLocationImpl(hObj.Location_I);
        end

        function set.Location_I(hObj,newValue)
            oldValue=hObj.Location_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Location_I=hObj.setLocationImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        NumRowsInternal matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=1;
    end

    methods
        function storedValue=get.NumRowsInternal(hObj)
            storedValue=hObj.NumRowsInternal;
        end

        function set.NumRowsInternal(hObj,newValue)



            hObj.NumRowsInternal=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        NumColumnsInternal matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=1;
    end

    methods
        function storedValue=get.NumColumnsInternal(hObj)
            storedValue=hObj.NumColumnsInternal;
        end

        function set.NumColumnsInternal(hObj,newValue)



            hObj.NumColumnsInternal=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        NumColumns matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=1;
    end

    methods
        function valueToCaller=get.NumColumns(hObj)


            valueToCaller=hObj.NumColumns_I;

        end

        function set.NumColumns(hObj,newValue)



            hObj.NumColumnsMode='manual';


            hObj.NumColumns_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        NumColumnsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NumColumnsMode(hObj)
            storedValue=hObj.NumColumnsMode;
        end

        function set.NumColumnsMode(hObj,newValue)

            oldValue=hObj.NumColumnsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NumColumnsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        NumColumns_I matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=1;
    end

    methods
        function storedValue=get.NumColumns_I(hObj)
            storedValue=hObj.NumColumns_I;
        end

        function set.NumColumns_I(hObj,newValue)



            hObj.NumColumns_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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

        PlotChildrenExcluded matlab.graphics.Graphics=[];
    end

    methods
        function valueToCaller=get.PlotChildrenExcluded(hObj)



            valueToCaller=hObj.getPlotChildrenExcludedImpl(hObj.PlotChildrenExcluded_I);


        end

        function set.PlotChildrenExcluded(hObj,newValue)



            hObj.PlotChildrenExcludedMode='manual';



            reallyDoCopy=~isequal(hObj.PlotChildrenExcluded_I,newValue);

            if reallyDoCopy
                hObj.PlotChildrenExcluded_I=hObj.setPlotChildrenExcludedImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PlotChildrenExcludedMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PlotChildrenExcludedMode(hObj)
            storedValue=hObj.PlotChildrenExcludedMode;
        end

        function set.PlotChildrenExcludedMode(hObj,newValue)

            oldValue=hObj.PlotChildrenExcludedMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PlotChildrenExcludedMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,ReconnectOnCopy=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        PlotChildrenExcluded_I matlab.graphics.Graphics=[];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        PlotChildrenSpecified matlab.graphics.Graphics=[];
    end

    methods
        function valueToCaller=get.PlotChildrenSpecified(hObj)



            valueToCaller=hObj.getPlotChildrenSpecifiedImpl(hObj.PlotChildrenSpecified_I);


        end

        function set.PlotChildrenSpecified(hObj,newValue)



            hObj.PlotChildrenSpecifiedMode='manual';



            reallyDoCopy=~isequal(hObj.PlotChildrenSpecified_I,newValue);

            if reallyDoCopy
                hObj.PlotChildrenSpecified_I=hObj.setPlotChildrenSpecifiedImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PlotChildrenSpecifiedMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PlotChildrenSpecifiedMode(hObj)
            storedValue=hObj.PlotChildrenSpecifiedMode;
        end

        function set.PlotChildrenSpecifiedMode(hObj,newValue)

            oldValue=hObj.PlotChildrenSpecifiedMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PlotChildrenSpecifiedMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,ReconnectOnCopy=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        PlotChildrenSpecified_I matlab.graphics.Graphics=[];
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


    properties(SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true)

        SPosition=[];
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


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        CanvasCache=[];
    end

    methods
        function storedValue=get.CanvasCache(hObj)
            storedValue=hObj.CanvasCache;
        end

        function set.CanvasCache(hObj,newValue)



            hObj.CanvasCache=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LimitMaxLegendEntries logical=false;
    end

    methods
        function valueToCaller=get.LimitMaxLegendEntries(hObj)


            valueToCaller=hObj.LimitMaxLegendEntries_I;

        end

        function set.LimitMaxLegendEntries(hObj,newValue)



            hObj.LimitMaxLegendEntriesMode='manual';


            hObj.LimitMaxLegendEntries_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LimitMaxLegendEntriesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LimitMaxLegendEntriesMode(hObj)
            storedValue=hObj.LimitMaxLegendEntriesMode;
        end

        function set.LimitMaxLegendEntriesMode(hObj,newValue)

            oldValue=hObj.LimitMaxLegendEntriesMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LimitMaxLegendEntriesMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LimitMaxLegendEntries_I logical=false;
    end

    methods
        function storedValue=get.LimitMaxLegendEntries_I(hObj)
            storedValue=hObj.LimitMaxLegendEntries_I;
        end

        function set.LimitMaxLegendEntries_I(hObj,newValue)



            hObj.LimitMaxLegendEntries_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        HasWarnedAboutMaxEntryCapping logical=false;
    end

    methods
        function valueToCaller=get.HasWarnedAboutMaxEntryCapping(hObj)


            valueToCaller=hObj.HasWarnedAboutMaxEntryCapping_I;

        end

        function set.HasWarnedAboutMaxEntryCapping(hObj,newValue)



            hObj.HasWarnedAboutMaxEntryCappingMode='manual';


            hObj.HasWarnedAboutMaxEntryCapping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HasWarnedAboutMaxEntryCappingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HasWarnedAboutMaxEntryCappingMode(hObj)
            storedValue=hObj.HasWarnedAboutMaxEntryCappingMode;
        end

        function set.HasWarnedAboutMaxEntryCappingMode(hObj,newValue)

            oldValue=hObj.HasWarnedAboutMaxEntryCappingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HasWarnedAboutMaxEntryCappingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        HasWarnedAboutMaxEntryCapping_I logical=false;
    end

    methods
        function storedValue=get.HasWarnedAboutMaxEntryCapping_I(hObj)
            storedValue=hObj.HasWarnedAboutMaxEntryCapping_I;
        end

        function set.HasWarnedAboutMaxEntryCapping_I(hObj,newValue)



            hObj.HasWarnedAboutMaxEntryCapping_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        PrintSettingsCache struct=struct();
    end

    methods
        function storedValue=get.PrintSettingsCache(hObj)
            storedValue=hObj.PrintSettingsCache;
        end

        function set.PrintSettingsCache(hObj,newValue)



            hObj.PrintSettingsCache=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false,Transient=true)

        String;
    end

    methods
        function valueToCaller=get.String(hObj)

            if strcmpi(get(hObj,'StringMode'),'auto')
                forceFullUpdate(hObj,'all','String');
            end


            valueToCaller=hObj.String_I;

        end

        function set.String(hObj,newValue)



            hObj.StringMode='manual';


            hObj.String_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        String_I;
    end

    methods
        function storedValue=get.String_I(hObj)
            storedValue=hObj.getStringImpl(hObj.String_I);
        end

        function set.String_I(hObj,newValue)
            hObj.String_I=hObj.setStringImpl(newValue);
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='private',Dependent=true,Hidden=true)

        SerializableString;
    end

    methods
        function valueToCaller=get.SerializableString(hObj)


            valueToCaller=hObj.SerializableString_I;

        end

        function set.SerializableString(hObj,newValue)



            hObj.SerializableStringMode='manual';


            hObj.SerializableString_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        SerializableStringMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SerializableStringMode(hObj)
            storedValue=hObj.SerializableStringMode;
        end

        function set.SerializableStringMode(hObj,newValue)

            oldValue=hObj.SerializableStringMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SerializableStringMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        SerializableString_I;
    end

    methods
        function storedValue=get.SerializableString_I(hObj)
            storedValue=hObj.getSerializableStringImpl(hObj.SerializableString_I);
        end

        function set.SerializableString_I(hObj,newValue)
            oldValue=hObj.SerializableString_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.SerializableString_I=hObj.setSerializableStringImpl(newValue);
            end
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


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        version matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.version(hObj)
            storedValue=hObj.version;
        end

        function set.version(hObj,newValue)



            hObj.version=newValue;

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


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ItemTokens;
    end

    methods
        function storedValue=get.ItemTokens(hObj)
            storedValue=hObj.ItemTokens;
        end

        function set.ItemTokens(hObj,newValue)



            hObj.ItemTokens=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ItemText;
    end

    methods
        function storedValue=get.ItemText(hObj)
            storedValue=hObj.ItemText;
        end

        function set.ItemText(hObj,newValue)



            hObj.ItemText=newValue;

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
            if strcmp(name,'EntryContainer')
                b=true;
                return;
            end
            if strcmp(name,'EntryContainer_I')
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
            b=isChildProperty@matlab.graphics.illustration.internal.AbstractExpandableLegend(obj,name);
            return;
            b=false;
        end
    end


    events(ListenAccess='public',NotifyAccess='private')
ItemHit
    end
    events(ListenAccess='public',NotifyAccess='private')
UpdateLayout
    end








    methods(Access='public')
        [list,side]=addToLayout(hObj)
    end






    methods(Access={?tLegend_recalculateLegendPosition})
        [widthchanged,heightchanged,newPosPoints]=recalculateLegendPosition(hObj,currPosPoints,minSizePoints,orientationChanged,widthMode,heightMode)
    end






    methods(Access={?tLegend_getNewLocation})
        [newPosPoints]=getNewLocation(hObj,Loc,Size,FinalSizePoints)
    end



    methods
        function hObj=Legend(varargin)






            hObj.Camera_I=matlab.graphics.axis.camera.Camera2D;

            set(hObj.Camera,'Description_I','Legend Camera');

            set(hObj.Camera,'Internal',true);

            hObj.DataSpace_I=matlab.graphics.axis.dataspace.UniformCartesianDataSpace;

            set(hObj.DataSpace,'Description_I','Legend DataSpace');

            set(hObj.DataSpace,'Internal',true);

            hObj.ColorSpace_I=matlab.graphics.axis.colorspace.MapColorSpace;

            set(hObj.ColorSpace,'Description_I','Legend ColorSpace');

            set(hObj.ColorSpace,'Internal',true);

            hObj.EntryContainer_I=matlab.graphics.primitive.world.Group;

            set(hObj.EntryContainer,'Description_I','Legend EntryContainer');

            set(hObj.EntryContainer,'Internal',true);

            hObj.DecorationContainer_I=matlab.graphics.primitive.world.Group;

            set(hObj.DecorationContainer,'Description_I','Legend DecorationContainer');

            set(hObj.DecorationContainer,'Internal',true);

            hObj.BoxEdge_I=matlab.graphics.primitive.world.LineLoop;

            set(hObj.BoxEdge,'Description_I','Legend BoxEdge');

            set(hObj.BoxEdge,'Internal',true);

            hObj.BoxFace_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.BoxFace,'Description_I','Legend BoxFace');

            set(hObj.BoxFace,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','Legend SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);

            hObj.TitleSeparator_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.TitleSeparator,'Description_I','Legend TitleSeparator');

            set(hObj.TitleSeparator,'Internal',true);


            hObj.CLim_I=[0,1];


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
        function setEntryContainer_IFanoutProps(hObj)
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
    methods(Access={?tmatlab_graphics_illustration_Legend_Impl},Hidden=true)
        function varargout=getNumColumnsInternal(hObj)

            varargout{1}=hObj.NumColumnsInternal;
        end
    end
    methods(Access={?tmatlab_graphics_illustration_Legend_Impl},Hidden=true)
        function varargout=getNumRowsInternal(hObj)

            varargout{1}=hObj.NumRowsInternal;
        end
    end
    methods(Access='private',Hidden=true)

        initializePositionCache(hObj)
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
        function scaleForPrinting(hObj,flag,scaleFactor)






            switch lower(flag)
            case 'modify'


                settings.ItemTokenSize=hObj.ItemTokenSize_I;


                hObj.ItemTokenSize_I=hObj.ItemTokenSize/scaleFactor;






                settings.ScaleFactor=scaleFactor;







                if strcmpi(hObj.Location,'none')
                    settings.LockPositionForPrinting=true;
                    settings.Position=hObj.Position;
                end
                hObj.PrintSettingsCache=settings;
            case 'revert'

                settings=hObj.PrintSettingsCache;
                if isfield(settings,'ItemTokenSize')
                    hObj.ItemTokenSize_I=settings.ItemTokenSize;
                end
                if isfield(settings,'Position')
                    hObj.Position_I=settings.Position;
                end
                hObj.PrintSettingsCache=struct();
            end
        end
    end
    methods(Access='public',Hidden=true)

        startLabelEditing(hObj,ed)
    end
    methods(Access='protected',Static=true,Hidden=true)

        autoUpdateCallback(hAxes,ed)
    end
    methods(Access='private',Hidden=true)

        addEntry(hObj,newEntry)
    end
    methods(Access='private',Hidden=true)

        removeEntry(hObj,legendableObject)
    end
    methods(Access='public',Hidden=true)

        removeAllEntries(hObj)
    end
    methods(Access={?tmatlab_graphics_illustration_Legend_Impl},Hidden=true)

        varargout=findEntry(hObj,LegendableObject)
    end
    methods(Access='private',Hidden=true)

        varargout=getEntries(hObj)
    end
    methods(Access='private',Hidden=true)

        varargout=getNamesForLayout(hObj)
    end
    methods(Access={?layouthelpers.LegendTester},Hidden=true)

        updateTitleProperties(hObj)
    end
    methods(Access={?tLegendPlotChildrenExcludedProp,?tmatlab_graphics_illustration_Legend_autoUpdateCallback},Hidden=true)
        function varargout=getPlotChildrenExcluded(hObj)

            varargout{1}=hObj.PlotChildrenExcluded;
        end
    end
    methods(Access={?tLegendPlotChildrenSpecified},Hidden=true)
        function varargout=getPlotChildrenSpecified(hObj)

            varargout{1}=hObj.PlotChildrenSpecified;
        end
    end
    methods(Access='public',Hidden=true)

        varargout=doGetChildren(hObj)
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


                if~isempty(newValue)&&isa(newValue.Parent,'matlab.graphics.layout.Layout')
                    hObj.Layout=newValue.Layout;
                    hObj.Layout.TileMode='auto';
                end

                varargout{1}=newValue;
            end

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getLocationImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setLocationImpl(hObj,newValue)



            if strcmp(newValue,'none')
                hObj.PositionMode='manual';
            else
                hObj.PositionMode='auto';
            end


            if~isempty(hObj.Axes)
                legendcolorbarlayout(hObj.Axes,'addToLayout',hObj);
            end

            if strcmp(hObj.LocationMode,'manual')&&~strcmp(newValue,'layout')
                if~isempty(hObj.Parent)&&isa(hObj.Parent,'matlab.graphics.layout.Layout')
                    hObj.Layout.TileMode='auto';
                end
            end

            varargout{1}=newValue;
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
    methods(Access='public',Hidden=true)
        function varargout=getAbsoluteCanvasPosition(hObj)

            varargout{1}=hObj.Camera.Viewport.Position;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPositionImpl(hObj,newValue)

            if strcmp(hObj.standalone,'on')

                setViewportPosition(hObj,newValue);
            else










                if strcmp(hObj.PositionMode,'manual')&&isempty(hObj.SPosition)
                    hObj.Location_I='none';



                    fig=ancestor(hObj,'Figure');

                    if~isempty(fig)&&~isempty(hObj.Parent)
                        canvasContainer=ancestor(hObj.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node');
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

                if~isempty(hObj.Parent)&&isa(hObj.Parent,'matlab.graphics.layout.Layout')
                    newValue=hObj.Parent.computeAbsolutePosition(newValue,hObj.Units);
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
    methods(Access='public',Hidden=true)
        function setAbsoluteGraphicsLayoutPosition(hObj,newValue)


            setViewportPosition(hObj,newValue);
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
        function varargout=getAutoUpdateImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setAutoUpdateImpl(hObj,newValue)


            if strcmp(newValue,'off')
                if isappdata(hObj,'PlotChildrenSpecifiedProxyValues')
                    rmappdata(hObj,'PlotChildrenSpecifiedProxyValues');
                end
            end





            if~isempty(hObj.Axes)
                dummyEvent.LegendableObjects=flip(findobj(hObj.Axes,'-isa','matlab.graphics.mixin.Legendable'))';
                matlab.graphics.illustration.Legend.autoUpdateCallback(hObj.Axes,dummyEvent);
            end

            varargout{1}=newValue;
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


            hObj.removeAllEntries();

            varargout{1}=newValue(:);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getPlotChildrenExcludedImpl(hObj,storedValue)


            sv=storedValue(:);
            varargout{1}=sv(isvalid(sv));
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPlotChildrenExcludedImpl(hObj,newValue)


            for i=1:numel(newValue)
                assert(isa(newValue(i),'matlab.graphics.mixin.Legendable'));
            end

            varargout{1}=newValue(:);
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
        function varargout=getStringImpl(hObj,storedValue)




            strings={};
            entries=getEntries(hObj);
            for i=1:numel(entries)



                str=entries(i).Label.String;
                if iscell(str)
                    str=strjoin(str,'\n');
                end
                strings{end+1}=str;
            end

            if~isempty(strings)
                strings=reshape(strings,1,numel(strings));
                strings=deblank(strings);
            end

            varargout{1}=strings;

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=setStringImpl(hObj,newValue)




            hObj.StringMode='auto';

            val={};
            if isempty(newValue)

                val=hObj.String_I;
            else


                if~iscell(newValue)
                    newValue=cellstr(newValue);
                end





                if strcmp(hObj.AutoUpdate,'on')
                    pc=hObj.PlotChildren;
                else
                    pc=hObj.PlotChildren_I;
                end
                numPC=numel(pc);
                numStrings=numel(newValue);
                for k=1:numPC
                    if k<=numStrings
                        pc(k).DisplayName=newValue{k};
                        val{k}=newValue{k};
                    else
                        hObj.removeEntry(pc(k));
                    end
                end
            end
            varargout{1}=val;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getSerializableStringImpl(hObj,storedValue)

            entries=flipud(hObj.EntryContainer.Children);
            if isempty(entries)&&~isempty(hObj.PlotChildren_I)
                objects=hObj.PlotChildren_I;
                objects=objects(isvalid(objects));
                displayNames=strings(1,numel(objects));
                for i=1:numel(objects)
                    displayNames(i)=objects(i).getDisplayNameForInterpreter(hObj.Interpreter);
                end
            else
                displayNames=strings(1,numel(entries));
                for i=1:numel(entries)
                    entry=entries(i);
                    displayNames(i)=entry.Object.getDisplayNameForInterpreter(hObj.Interpreter);
                end
            end

            varargout{1}=cellstr(deblank(displayNames));

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=setSerializableStringImpl(hObj,newValue)

            hObj.String_I=newValue;
            varargout{1}=newValue;
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end
    methods(Access='public',Hidden=true)

        varargout=mcodeIgnoreHandle(hObj,h)
    end



    methods
        function fireItemHitEvent(hObj,data)
            evt=matlab.graphics.eventdata.ItemHitEventData(data);
            hObj.notify('ItemHit',evt);
        end
    end
    methods
        function fireUpdateLayoutEvent(hObj,data)
            evt=event.EventData(data);
            hObj.notify('UpdateLayout',evt);
        end
    end


end
