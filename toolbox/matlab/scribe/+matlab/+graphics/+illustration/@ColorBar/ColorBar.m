
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)ColorBar<matlab.graphics.primitive.world.Group&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.internal.GraphicsJavaVisible&matlab.graphics.mixin.UIParentable&matlab.graphics.mixin.ChartLayoutable





    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        Camera matlab.graphics.axis.camera.Camera;
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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        MapContainer matlab.graphics.primitive.world.Group;
    end

    methods
        function valueToCaller=get.MapContainer(hObj)


            valueToCaller=hObj.MapContainer_I;

        end

        function set.MapContainer(hObj,newValue)



            hObj.MapContainerMode='manual';


            hObj.MapContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MapContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MapContainerMode(hObj)
            storedValue=hObj.MapContainerMode;
        end

        function set.MapContainerMode(hObj,newValue)

            oldValue=hObj.MapContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MapContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        MapContainer_I;
    end

    methods
        function set.MapContainer_I(hObj,newValue)
            oldValue=hObj.MapContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DataSpace.replaceChild(hObj.MapContainer_I,newValue);
                else

                    hObj.DataSpace.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.MapContainer_I=newValue;
            try
                hObj.setMapContainer_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        DecorationContainer_I;
    end

    methods
        function set.DecorationContainer_I(hObj,newValue)
            oldValue=hObj.DecorationContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DataSpace.replaceChild(hObj.DecorationContainer_I,newValue);
                else

                    hObj.DataSpace.addNode(newValue);
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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        Ruler matlab.graphics.axis.decorator.Ruler;
    end

    methods
        function valueToCaller=get.Ruler(hObj)


            valueToCaller=hObj.Ruler_I;

        end

        function set.Ruler(hObj,newValue)



            hObj.RulerMode='manual';


            hObj.Ruler_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        RulerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RulerMode(hObj)
            storedValue=hObj.RulerMode;
        end

        function set.RulerMode(hObj,newValue)

            oldValue=hObj.RulerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RulerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Ruler_I;
    end

    methods
        function set.Ruler_I(hObj,newValue)
            oldValue=hObj.Ruler_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.Ruler_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Ruler_I=newValue;
            try
                hObj.setRuler_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        CDataMapping matlab.internal.datatype.matlab.graphics.datatype.ColorbarCDataMapping='scaled';
    end

    methods
        function valueToCaller=get.CDataMapping(hObj)


            valueToCaller=hObj.CDataMapping_I;

        end

        function set.CDataMapping(hObj,newValue)



            hObj.CDataMappingMode='manual';


            hObj.CDataMapping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CDataMappingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CDataMappingMode(hObj)
            storedValue=hObj.CDataMappingMode;
        end

        function set.CDataMappingMode(hObj,newValue)

            oldValue=hObj.CDataMappingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CDataMappingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        CDataMapping_I matlab.internal.datatype.matlab.graphics.datatype.ColorbarCDataMapping='scaled';
    end

    methods
        function storedValue=get.CDataMapping_I(hObj)
            storedValue=hObj.CDataMapping_I;
        end

        function set.CDataMapping_I(hObj,newValue)



            hObj.CDataMapping_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=false,Transient=true)

        Label matlab.graphics.Graphics;
    end

    methods
        function storedValue=get.Label(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            if strcmpi(get(hObj,'LabelMode'),'auto')

                forceFullUpdate(passObj,'all','Label');
            end

            storedValue=passObj.Label;
        end

        function set.Label(hObj,newValue)






            hObj.LabelMode='manual';
            hObj.Label_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        LabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LabelMode(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LabelMode;
        end

        function set.LabelMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LabelMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true)

        Label_I matlab.graphics.Graphics;
    end

    methods
        function storedValue=get.Label_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Label_I;
        end

        function set.Label_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Label_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        XLabel;
    end

    methods
        function valueToCaller=get.XLabel(hObj)

            valueToCaller=hObj.Label;
        end

        function set.XLabel(hObj,newValue)

            hObj.Label=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        YLabel;
    end

    methods
        function valueToCaller=get.YLabel(hObj)

            valueToCaller=hObj.Label;
        end

        function set.YLabel(hObj,newValue)

            hObj.Label=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        Title matlab.graphics.primitive.Text;
    end

    methods
        function valueToCaller=get.Title(hObj)


            valueToCaller=hObj.Title_I;

        end

        function set.Title(hObj,newValue)



            hObj.TitleMode='manual';


            hObj.Title_I=newValue;

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

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Title_I;
    end

    methods
        function set.Title_I(hObj,newValue)
            oldValue=hObj.Title_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.Title_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Title_I=newValue;
            try
                hObj.setTitle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        SelectionHandle matlab.graphics.interactor.ListOfPointsHighlight;
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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        BoxHandle matlab.graphics.axis.decorator.BoxFrame;
    end

    methods
        function valueToCaller=get.BoxHandle(hObj)


            valueToCaller=hObj.BoxHandle_I;

        end

        function set.BoxHandle(hObj,newValue)



            hObj.BoxHandleMode='manual';


            hObj.BoxHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BoxHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoxHandleMode(hObj)
            storedValue=hObj.BoxHandleMode;
        end

        function set.BoxHandleMode(hObj,newValue)

            oldValue=hObj.BoxHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BoxHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        BoxHandle_I;
    end

    methods
        function set.BoxHandle_I(hObj,newValue)
            oldValue=hObj.BoxHandle_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.BoxHandle_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.BoxHandle_I=newValue;
            try
                hObj.setBoxHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        Face matlab.graphics.primitive.world.Quadrilateral;
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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(AffectsObject,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Face_I;
    end

    methods
        function set.Face_I(hObj,newValue)
            oldValue=hObj.Face_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.MapContainer.replaceChild(hObj.Face_I,newValue);
                else

                    hObj.MapContainer.addNode(newValue);
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Axes;
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

        Axes_I;
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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        AxesListenerList cell={};
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


    properties(AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true)

        AxesListenerList_I cell={};
    end

    methods
        function storedValue=get.AxesListenerList_I(hObj)
            storedValue=hObj.AxesListenerList_I;
        end

        function set.AxesListenerList_I(hObj,newValue)



            hObj.AxesListenerList_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        BaseColormap=[];
    end

    methods
        function valueToCaller=get.BaseColormap(hObj)


            valueToCaller=hObj.BaseColormap_I;

        end

        function set.BaseColormap(hObj,newValue)



            hObj.BaseColormapMode='manual';


            hObj.BaseColormap_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BaseColormapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BaseColormapMode(hObj)
            storedValue=hObj.BaseColormapMode;
        end

        function set.BaseColormapMode(hObj,newValue)

            oldValue=hObj.BaseColormapMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BaseColormapMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BaseColormap_I=[];
    end

    methods
        function storedValue=get.BaseColormap_I(hObj)
            storedValue=hObj.BaseColormap_I;
        end

        function set.BaseColormap_I(hObj,newValue)



            hObj.BaseColormap_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Box matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.Box(hObj)




            passObj=hObj.BoxHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Visible;
        end

        function set.Box(hObj,newValue)






            hObj.BoxMode='manual';
            hObj.Box_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BoxMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoxMode(hObj)
            passObj=hObj.BoxHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.VisibleMode;
        end

        function set.BoxMode(hObj,newValue)


            passObj=hObj.BoxHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.VisibleMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Box_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.Box_I(hObj)
            passObj=hObj.BoxHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Visible_I;
        end

        function set.Box_I(hObj,newValue)


            passObj=hObj.BoxHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Visible_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Colormap matlab.internal.datatype.matlab.graphics.datatype.ColorMap=parula(64);
    end

    methods
        function valueToCaller=get.Colormap(hObj)


            valueToCaller=hObj.Colormap_I;

        end

        function set.Colormap(hObj,newValue)



            hObj.ColormapMode='manual';


            hObj.Colormap_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ColormapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColormapMode(hObj)
            storedValue=hObj.ColormapMode;
        end

        function set.ColormapMode(hObj,newValue)

            oldValue=hObj.ColormapMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColormapMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Colormap_I matlab.internal.datatype.matlab.graphics.datatype.ColorMap=parula(64);
    end

    methods
        function storedValue=get.Colormap_I(hObj)
            storedValue=hObj.Colormap_I;
        end

        function set.Colormap_I(hObj,newValue)



            hObj.Colormap_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        ColormapMoveInitialMap=[];
    end

    methods
        function valueToCaller=get.ColormapMoveInitialMap(hObj)


            valueToCaller=hObj.ColormapMoveInitialMap_I;

        end

        function set.ColormapMoveInitialMap(hObj,newValue)



            hObj.ColormapMoveInitialMapMode='manual';


            hObj.ColormapMoveInitialMap_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ColormapMoveInitialMapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColormapMoveInitialMapMode(hObj)
            storedValue=hObj.ColormapMoveInitialMapMode;
        end

        function set.ColormapMoveInitialMapMode(hObj,newValue)

            oldValue=hObj.ColormapMoveInitialMapMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColormapMoveInitialMapMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ColormapMoveInitialMap_I=[];
    end

    methods
        function storedValue=get.ColormapMoveInitialMap_I(hObj)
            storedValue=hObj.ColormapMoveInitialMap_I;
        end

        function set.ColormapMoveInitialMap_I(hObj,newValue)



            hObj.ColormapMoveInitialMap_I=newValue;

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

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.Ruler;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ColorMode'),'auto')
                    set(fanChild,'Color_I',newValue);
                end
            end
            fanChild=hObj.BoxHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'XColorMode'),'auto')
                    set(fanChild,'XColor_I',newValue);
                end
            end
            fanChild=hObj.BoxHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'YColorMode'),'auto')
                    set(fanChild,'YColor_I',newValue);
                end
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        EdgeColor;
    end

    methods
        function valueToCaller=get.EdgeColor(hObj)

            valueToCaller=hObj.Color;
        end

        function set.EdgeColor(hObj,newValue)

            hObj.Color=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XColor;
    end

    methods
        function valueToCaller=get.XColor(hObj)

            valueToCaller=hObj.Color;
        end

        function set.XColor(hObj,newValue)

            hObj.Color=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YColor;
    end

    methods
        function valueToCaller=get.YColor(hObj)

            valueToCaller=hObj.Color;
        end

        function set.YColor(hObj,newValue)

            hObj.Color=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Direction matlab.internal.datatype.matlab.graphics.datatype.AxisDirection='normal';
    end

    methods
        function valueToCaller=get.Direction(hObj)


            valueToCaller=hObj.Direction_I;

        end

        function set.Direction(hObj,newValue)



            hObj.DirectionMode='manual';


            hObj.Direction_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        DirectionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.DirectionMode(hObj)
            storedValue=hObj.DirectionMode;
        end

        function set.DirectionMode(hObj,newValue)

            oldValue=hObj.DirectionMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.DirectionMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Direction_I matlab.internal.datatype.matlab.graphics.datatype.AxisDirection='normal';
    end

    methods
        function storedValue=get.Direction_I(hObj)
            storedValue=hObj.Direction_I;
        end

        function set.Direction_I(hObj,newValue)



            hObj.Direction_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XDir;
    end

    methods
        function valueToCaller=get.XDir(hObj)

            valueToCaller=hObj.Direction;
        end

        function set.XDir(hObj,newValue)

            hObj.Direction=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YDir;
    end

    methods
        function valueToCaller=get.YDir(hObj)

            valueToCaller=hObj.Direction;
        end

        function set.YDir(hObj,newValue)

            hObj.Direction=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Editing matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.Editing(hObj)


            valueToCaller=hObj.Editing_I;

        end

        function set.Editing(hObj,newValue)



            hObj.EditingMode='manual';


            hObj.Editing_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EditingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EditingMode(hObj)
            storedValue=hObj.EditingMode;
        end

        function set.EditingMode(hObj,newValue)

            oldValue=hObj.EditingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EditingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Editing_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Editing_I(hObj)
            storedValue=hObj.Editing_I;
        end

        function set.Editing_I(hObj,newValue)



            hObj.Editing_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
    end

    methods
        function storedValue=get.FontAngle(hObj)




            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontAngleMode;
        end

        function set.FontAngleMode(hObj,newValue)


            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontAngle_I;
        end

        function set.FontAngle_I(hObj,newValue)


            passObj=hObj.Ruler;
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




            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontNameMode;
        end

        function set.FontNameMode(hObj,newValue)


            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontName_I;
        end

        function set.FontName_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontName_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
    end

    methods
        function storedValue=get.FontSize(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            if strcmpi(get(hObj,'FontSizeMode'),'auto')

                forceFullUpdate(passObj,'all','FontSize');
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontSizeMode;
        end

        function set.FontSizeMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontSizeMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
    end

    methods
        function storedValue=get.FontSize_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontSize_I;
        end

        function set.FontSize_I(hObj,newValue)


            passObj=hObj.Ruler;
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




            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontWeightMode;
        end

        function set.FontWeightMode(hObj,newValue)


            passObj=hObj.Ruler;
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
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.FontWeight_I;
        end

        function set.FontWeight_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.FontWeight_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Limits matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1];
    end

    methods
        function valueToCaller=get.Limits(hObj)

            if strcmpi(get(hObj,'LimitsMode'),'auto')
                forceFullUpdate(hObj,'all','Limits');
            end


            valueToCaller=hObj.Limits_I;

        end

        function set.Limits(hObj,newValue)



            hObj.LimitsMode='manual';


            hObj.Limits_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        LimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LimitsMode(hObj)
            storedValue=hObj.LimitsMode;
        end

        function set.LimitsMode(hObj,newValue)

            oldValue=hObj.LimitsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LimitsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Limits_I matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1];
    end

    methods
        function storedValue=get.Limits_I(hObj)
            storedValue=hObj.Limits_I;
        end

        function set.Limits_I(hObj,newValue)



            hObj.Limits_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XLim;
    end

    methods
        function valueToCaller=get.XLim(hObj)

            valueToCaller=hObj.Limits;
        end

        function set.XLim(hObj,newValue)

            hObj.Limits=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XLimMode;
    end

    methods
        function valueToCaller=get.XLimMode(hObj)

            valueToCaller=hObj.LimitsMode;
        end

        function set.XLimMode(hObj,newValue)

            hObj.LimitsMode=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YLim;
    end

    methods
        function valueToCaller=get.YLim(hObj)

            valueToCaller=hObj.Limits;
        end

        function set.YLim(hObj,newValue)

            hObj.Limits=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YLimMode;
    end

    methods
        function valueToCaller=get.YLimMode(hObj)

            valueToCaller=hObj.LimitsMode;
        end

        function set.YLimMode(hObj,newValue)

            hObj.LimitsMode=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        ScaleColormapWithLimits(1,1)logical=true;
    end

    methods
        function valueToCaller=get.ScaleColormapWithLimits(hObj)


            valueToCaller=hObj.ScaleColormapWithLimits_I;

        end

        function set.ScaleColormapWithLimits(hObj,newValue)



            hObj.ScaleColormapWithLimitsMode='manual';


            hObj.ScaleColormapWithLimits_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ScaleColormapWithLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ScaleColormapWithLimitsMode(hObj)
            storedValue=hObj.ScaleColormapWithLimitsMode;
        end

        function set.ScaleColormapWithLimitsMode(hObj,newValue)

            oldValue=hObj.ScaleColormapWithLimitsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ScaleColormapWithLimitsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ScaleColormapWithLimits_I(1,1)logical=true;
    end

    methods
        function storedValue=get.ScaleColormapWithLimits_I(hObj)
            storedValue=hObj.ScaleColormapWithLimits_I;
        end

        function set.ScaleColormapWithLimits_I(hObj,newValue)



            hObj.ScaleColormapWithLimits_I=newValue;

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



            fanChild=hObj.Ruler;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.BoxHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Location matlab.internal.datatype.matlab.graphics.datatype.ColorbarLocationType='eastoutside';
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

        Location_I matlab.internal.datatype.matlab.graphics.datatype.ColorbarLocationType='eastoutside';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        NClickPoint=[];
    end

    methods
        function valueToCaller=get.NClickPoint(hObj)


            valueToCaller=hObj.NClickPoint_I;

        end

        function set.NClickPoint(hObj,newValue)



            hObj.NClickPointMode='manual';


            hObj.NClickPoint_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NClickPointMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NClickPointMode(hObj)
            storedValue=hObj.NClickPointMode;
        end

        function set.NClickPointMode(hObj,newValue)

            oldValue=hObj.NClickPointMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NClickPointMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        NClickPoint_I=[];
    end

    methods
        function storedValue=get.NClickPoint_I(hObj)
            storedValue=hObj.NClickPoint_I;
        end

        function set.NClickPoint_I(hObj,newValue)



            hObj.NClickPoint_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Orientation matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarOrientationType='vertical';
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

        Orientation_I matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarOrientationType='vertical';
    end

    methods
        function storedValue=get.Orientation_I(hObj)
            storedValue=hObj.Orientation_I;
        end

        function set.Orientation_I(hObj,newValue)



            hObj.Orientation_I=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AxisLocation matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarAxisLocationType='out';
    end

    methods
        function valueToCaller=get.AxisLocation(hObj)

            if strcmpi(get(hObj,'AxisLocationMode'),'auto')
                forceFullUpdate(hObj,'all','AxisLocation');
            end


            valueToCaller=hObj.AxisLocation_I;

        end

        function set.AxisLocation(hObj,newValue)



            hObj.AxisLocationMode='manual';


            hObj.AxisLocation_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        AxisLocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AxisLocationMode(hObj)
            storedValue=hObj.AxisLocationMode;
        end

        function set.AxisLocationMode(hObj,newValue)

            oldValue=hObj.AxisLocationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AxisLocationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AxisLocation_I matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarAxisLocationType='out';
    end

    methods
        function storedValue=get.AxisLocation_I(hObj)
            storedValue=hObj.AxisLocation_I;
        end

        function set.AxisLocation_I(hObj,newValue)



            hObj.AxisLocation_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        RulerLocation matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarRulerLocationType='right';
    end

    methods
        function valueToCaller=get.RulerLocation(hObj)

            if strcmpi(get(hObj,'RulerLocationMode'),'auto')
                forceFullUpdate(hObj,'all','RulerLocation');
            end


            valueToCaller=hObj.RulerLocation_I;

        end

        function set.RulerLocation(hObj,newValue)



            hObj.RulerLocationMode='manual';


            hObj.RulerLocation_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        RulerLocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RulerLocationMode(hObj)
            storedValue=hObj.RulerLocationMode;
        end

        function set.RulerLocationMode(hObj,newValue)

            oldValue=hObj.RulerLocationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RulerLocationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        RulerLocation_I matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarRulerLocationType='right';
    end

    methods
        function storedValue=get.RulerLocation_I(hObj)
            storedValue=hObj.RulerLocation_I;
        end

        function set.RulerLocation_I(hObj,newValue)



            hObj.RulerLocation_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XAxisLocation;
    end

    methods
        function valueToCaller=get.XAxisLocation(hObj)

            valueToCaller=hObj.RulerLocation;
        end

        function set.XAxisLocation(hObj,newValue)

            hObj.RulerLocation=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YAxisLocation;
    end

    methods
        function valueToCaller=get.YAxisLocation(hObj)

            valueToCaller=hObj.RulerLocation;
        end

        function set.YAxisLocation(hObj,newValue)

            hObj.RulerLocation=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TickDirection matlab.internal.datatype.matlab.graphics.datatype.TickDir='in';
    end

    methods
        function storedValue=get.TickDirection(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.TickDirection;
        end

        function set.TickDirection(hObj,newValue)






            hObj.TickDirectionMode='manual';
            hObj.TickDirection_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickDirectionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TickDirectionMode(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickDirectionMode;
        end

        function set.TickDirectionMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickDirectionMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickDirection_I matlab.internal.datatype.matlab.graphics.datatype.TickDir='in';
    end

    methods
        function storedValue=get.TickDirection_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickDirection_I;
        end

        function set.TickDirection_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickDirection_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TickLabelInterpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function storedValue=get.TickLabelInterpreter(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            if strcmpi(get(hObj,'TickLabelInterpreterMode'),'auto')

                forceFullUpdate(passObj,'all','TickLabelInterpreter');
            end

            storedValue=passObj.TickLabelInterpreter;
        end

        function set.TickLabelInterpreter(hObj,newValue)






            hObj.TickLabelInterpreterMode='manual';
            hObj.TickLabelInterpreter_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickLabelInterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TickLabelInterpreterMode(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickLabelInterpreterMode;
        end

        function set.TickLabelInterpreterMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickLabelInterpreterMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickLabelInterpreter_I matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function storedValue=get.TickLabelInterpreter_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickLabelInterpreter_I;
        end

        function set.TickLabelInterpreter_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickLabelInterpreter_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TickLabels matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='';
    end

    methods
        function storedValue=get.TickLabels(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            if strcmpi(get(hObj,'TickLabelsMode'),'auto')

                forceFullUpdate(passObj,'all','TickLabels');
            end

            storedValue=passObj.TickLabels;
        end

        function set.TickLabels(hObj,newValue)






            hObj.TickLabelsMode='manual';
            hObj.TickLabels_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        TickLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TickLabelsMode(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickLabelsMode;
        end

        function set.TickLabelsMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickLabelsMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickLabels_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='';
    end

    methods
        function storedValue=get.TickLabels_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickLabels_I;
        end

        function set.TickLabels_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickLabels_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XTickLabel;
    end

    methods
        function valueToCaller=get.XTickLabel(hObj)

            valueToCaller=hObj.TickLabels;
        end

        function set.XTickLabel(hObj,newValue)

            hObj.TickLabels=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XTickLabelMode;
    end

    methods
        function valueToCaller=get.XTickLabelMode(hObj)

            valueToCaller=hObj.TickLabelsMode;
        end

        function set.XTickLabelMode(hObj,newValue)

            hObj.TickLabelsMode=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YTickLabel;
    end

    methods
        function valueToCaller=get.YTickLabel(hObj)

            valueToCaller=hObj.TickLabels;
        end

        function set.YTickLabel(hObj,newValue)

            hObj.TickLabels=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YTickLabelMode;
    end

    methods
        function valueToCaller=get.YTickLabelMode(hObj)

            valueToCaller=hObj.TickLabelsMode;
        end

        function set.YTickLabelMode(hObj,newValue)

            hObj.TickLabelsMode=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TickLength matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarTickLength=.01;
    end

    methods
        function valueToCaller=get.TickLength(hObj)


            valueToCaller=hObj.TickLength_I;

        end

        function set.TickLength(hObj,newValue)



            hObj.TickLengthMode='manual';


            hObj.TickLength_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        TickLengthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TickLengthMode(hObj)
            storedValue=hObj.TickLengthMode;
        end

        function set.TickLengthMode(hObj,newValue)

            oldValue=hObj.TickLengthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TickLengthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TickLength_I matlab.internal.datatype.matlab.graphics.chart.datatype.ColorbarTickLength=.01;
    end

    methods
        function storedValue=get.TickLength_I(hObj)
            storedValue=hObj.TickLength_I;
        end

        function set.TickLength_I(hObj,newValue)



            hObj.TickLength_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Ticks matlab.internal.datatype.matlab.graphics.datatype.Tick=[];
    end

    methods
        function storedValue=get.Ticks(hObj)




            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            if strcmpi(get(hObj,'TicksMode'),'auto')

                forceFullUpdate(passObj,'all','Ticks');
            end

            storedValue=passObj.TickValues;
        end

        function set.Ticks(hObj,newValue)






            hObj.TicksMode='manual';
            hObj.Ticks_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        TicksMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TicksMode(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickValuesMode;
        end

        function set.TicksMode(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickValuesMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Ticks_I matlab.internal.datatype.matlab.graphics.datatype.Tick=[];
    end

    methods
        function storedValue=get.Ticks_I(hObj)
            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.TickValues_I;
        end

        function set.Ticks_I(hObj,newValue)


            passObj=hObj.Ruler;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.TickValues_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XTick;
    end

    methods
        function valueToCaller=get.XTick(hObj)

            valueToCaller=hObj.Ticks;
        end

        function set.XTick(hObj,newValue)

            hObj.Ticks=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XTickMode;
    end

    methods
        function valueToCaller=get.XTickMode(hObj)

            valueToCaller=hObj.TicksMode;
        end

        function set.XTickMode(hObj,newValue)

            hObj.TicksMode=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YTick;
    end

    methods
        function valueToCaller=get.YTick(hObj)

            valueToCaller=hObj.Ticks;
        end

        function set.YTick(hObj,newValue)

            hObj.Ticks=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YTickMode;
    end

    methods
        function valueToCaller=get.YTickMode(hObj)

            valueToCaller=hObj.TicksMode;
        end

        function set.YTickMode(hObj,newValue)

            hObj.TicksMode=newValue;
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


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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
            if strcmp(name,'MapContainer')
                b=true;
                return;
            end
            if strcmp(name,'MapContainer_I')
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
            if strcmp(name,'Ruler')
                b=true;
                return;
            end
            if strcmp(name,'Ruler_I')
                b=true;
                return;
            end
            if strcmp(name,'Title')
                b=true;
                return;
            end
            if strcmp(name,'Title_I')
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
            if strcmp(name,'BoxHandle')
                b=true;
                return;
            end
            if strcmp(name,'BoxHandle_I')
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
            b=isChildProperty@matlab.graphics.primitive.world.Group(obj,name);
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



    methods
        function hObj=ColorBar(varargin)






            hObj.Camera_I=matlab.graphics.axis.camera.Camera2D;

            set(hObj.Camera,'Description_I','ColorBar Camera');

            set(hObj.Camera,'Internal',true);

            hObj.DataSpace_I=matlab.graphics.axis.dataspace.CartesianDataSpace;

            set(hObj.DataSpace,'Description_I','ColorBar DataSpace');

            set(hObj.DataSpace,'Internal',true);

            hObj.MapContainer_I=matlab.graphics.primitive.world.Group;

            set(hObj.MapContainer,'Description_I','ColorBar MapContainer');

            set(hObj.MapContainer,'Internal',true);

            hObj.DecorationContainer_I=matlab.graphics.primitive.world.Group;

            set(hObj.DecorationContainer,'Description_I','ColorBar DecorationContainer');

            set(hObj.DecorationContainer,'Internal',true);

            hObj.Ruler_I=matlab.graphics.axis.decorator.NumericRuler;

            set(hObj.Ruler,'Description_I','ColorBar Ruler');

            set(hObj.Ruler,'Internal',true);

            hObj.Title_I=matlab.graphics.primitive.Text;

            set(hObj.Title,'Description_I','ColorBar Title');

            set(hObj.Title,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','ColorBar SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);

            hObj.BoxHandle_I=matlab.graphics.axis.decorator.BoxFrame;

            set(hObj.BoxHandle,'Description_I','ColorBar BoxHandle');

            set(hObj.BoxHandle,'Internal',true);

            hObj.Face_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.Face,'Description_I','ColorBar Face');

            set(hObj.Face,'Internal',true);


            hObj.Box_I='on';

            hObj.FontAngle_I='normal';

            hObj.FontName_I='Helvetica';

            hObj.FontSize_I=9;

            hObj.FontWeight_I='normal';

            hObj.TickDirection_I='in';

            hObj.TickLabelInterpreter_I='tex';

            hObj.TickLabels_I='';

            hObj.Ticks_I=[];


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
        function setMapContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setDecorationContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setRuler_IFanoutProps(hObj)

            try
                mode=hObj.Ruler.ColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Ruler,'Color_I',hObj.Color_I);
            end


            try
                mode=hObj.Ruler.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Ruler,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setTitle_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setSelectionHandle_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setBoxHandle_IFanoutProps(hObj)

            try
                mode=hObj.BoxHandle.XColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxHandle,'XColor_I',hObj.Color_I);
            end


            try
                mode=hObj.BoxHandle.YColorMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxHandle,'YColor_I',hObj.Color_I);
            end


            try
                mode=hObj.BoxHandle.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.BoxHandle,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end
    methods(Access=private)
        function setFace_IFanoutProps(hObj)
        end
    end


    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=doGetChildren(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=doMethod(hObj,fcn,varargin)
    end
    methods(Access='private',Hidden=true)

        doSetup(hObj)
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        doDelete(hObj)
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
    methods(Access='public',Hidden=true)

        varargout=checkDirtyChildren(hObj,child)
    end
    methods(Access='protected',Hidden=true)

        varargout=getPropertyGroups(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=getDescriptiveLabelForDisplay(hObj)
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



            if strcmp(hObj.PositionMode,'manual')
                hObj.Location_I='manual';
            end


            hViewPort=hObj.Camera.Viewport;
            hViewPort.Position=newValue;
            set(hObj.Camera,'ViewPort',hViewPort)

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


            hViewPort=hObj.Camera.Viewport;
            hViewPort.Position=newValue;
            set(hObj.Camera,'ViewPort',hViewPort)
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
            set(hObj.Camera,'ViewPort',hViewPort)

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getLocationImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        connectCopyToTree(hObj,hCopy,hCopyParent,hContext)
    end
    methods(Access='private',Hidden=true)
        function varargout=setLocationImpl(hObj,newValue)



            if strcmp(newValue,'manual')
                hObj.PositionMode='manual';
            else
                hObj.PositionMode='auto';
            end


            switch newValue
            case 'eastoutside'
                hObj.Orientation_I='vertical';
            case 'east'
                hObj.Orientation_I='vertical';
            case 'westoutside'
                hObj.Orientation_I='vertical';
            case 'west'
                hObj.Orientation_I='vertical';
            case 'northoutside'
                hObj.Orientation_I='horizontal';
            case 'north'
                hObj.Orientation_I='horizontal';
            case 'southoutside'
                hObj.Orientation_I='horizontal';
            case 'south'
                hObj.Orientation_I='horizontal';
            case 'manual'




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
    methods(Access='private',Hidden=true)
        function varargout=getAxesImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setAxesImpl(hObj,newValue)


            if~isempty(hObj.Axes)
                for i=1:length(hObj.AxesListenerList)
                    delete(hObj.AxesListenerList{i});
                end
                hObj.Axes.setColorbarExternal([]);
            end

            if~isempty(newValue)

                newValue=legendcolorbarlayout(newValue,'addToTree',hObj);


                hObj.attachAxesListeners(newValue);


                newValue.setColorbarExternal(hObj);
            end


            if~isempty(newValue)&&isa(newValue.Parent,'matlab.graphics.layout.Layout')
                hObj.Layout=newValue.Layout;
                hObj.Layout.TileMode='auto';
            end

            varargout{1}=newValue;
        end
    end
    methods(Access='public',Hidden=true)

        varargout=setParentImpl(hObj,proposedValue)
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end
    methods(Access='public',Hidden=true)

        varargout=mcodeIgnoreHandle(hObj,hOther)
    end
    methods(Access={?t_colorbar_determine_cdatamapping},Static=true,Hidden=true)

        varargout=determine_cdatamapping(ax)
    end
    methods(Access={?t_colorbar_determine_range},Static=true,Hidden=true)

        varargout=determine_range(ax,cdatamapping)
    end



    methods
        function fireUpdateLayoutEvent(hObj,data)
            evt=event.EventData(data);
            hObj.notify('UpdateLayout',evt);
        end
    end


end
