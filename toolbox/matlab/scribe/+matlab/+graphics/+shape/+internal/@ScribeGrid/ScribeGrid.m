
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed,Hidden=true)ScribeGrid<matlab.graphics.primitive.world.Group&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
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

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.LineHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LineHandle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.LineHandle(hObj)


            valueToCaller=hObj.LineHandle_I;

        end

        function set.LineHandle(hObj,newValue)



            hObj.LineHandleMode='manual';


            hObj.LineHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineHandleMode(hObj)
            storedValue=hObj.LineHandleMode;
        end

        function set.LineHandleMode(hObj,newValue)

            oldValue=hObj.LineHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        LineHandle_I;
    end

    methods
        function set.LineHandle_I(hObj,newValue)
            hObj.LineHandle_I=newValue;
            try
                hObj.setLineHandle_IFanoutProps();
            catch
            end
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



            fanChild=hObj.LineHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=1;
    end

    methods
        function storedValue=get.LineWidth(hObj)




            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.LineWidth(hObj,newValue)






            hObj.LineWidthMode='manual';
            hObj.LineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)


            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=1;
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)


            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XSpace matlab.internal.datatype.matlab.graphics.datatype.Positive=20;
    end

    methods
        function valueToCaller=get.XSpace(hObj)


            valueToCaller=hObj.XSpace_I;

        end

        function set.XSpace(hObj,newValue)



            hObj.XSpaceMode='manual';


            hObj.XSpace_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XSpaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XSpaceMode(hObj)
            storedValue=hObj.XSpaceMode;
        end

        function set.XSpaceMode(hObj,newValue)

            oldValue=hObj.XSpaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XSpaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XSpace_I matlab.internal.datatype.matlab.graphics.datatype.Positive=20;
    end

    methods
        function storedValue=get.XSpace_I(hObj)
            storedValue=hObj.XSpace_I;
        end

        function set.XSpace_I(hObj,newValue)



            hObj.XSpace_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YSpace matlab.internal.datatype.matlab.graphics.datatype.Positive=20;
    end

    methods
        function valueToCaller=get.YSpace(hObj)


            valueToCaller=hObj.YSpace_I;

        end

        function set.YSpace(hObj,newValue)



            hObj.YSpaceMode='manual';


            hObj.YSpace_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YSpaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YSpaceMode(hObj)
            storedValue=hObj.YSpaceMode;
        end

        function set.YSpaceMode(hObj,newValue)

            oldValue=hObj.YSpaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YSpaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YSpace_I matlab.internal.datatype.matlab.graphics.datatype.Positive=20;
    end

    methods
        function storedValue=get.YSpace_I(hObj)
            storedValue=hObj.YSpace_I;
        end

        function set.YSpace_I(hObj,newValue)



            hObj.YSpace_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'LineHandle')
                b=true;
                return;
            end
            if strcmp(name,'LineHandle_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.primitive.world.Group(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=ScribeGrid(varargin)






            hObj.LineHandle_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.LineHandle,'Description_I','ScribeGrid LineHandle');

            set(hObj.LineHandle,'Internal',true);


            hObj.LineWidth_I=1;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setLineHandle_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.LineHandle,hObj.Color_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,hObj.LineStyle_I);

        end
    end


    methods(Access='public',Hidden=true)
        function doSetup(hObj)

            hObj.HitTest='off';


            hObj.PickableParts='none';


            hObj.Type='hggroup';



            hObj.addDependencyConsumed('ref_frame');


            hBehavior=hggetbehavior(hObj,'Print');
            set(hBehavior,'PrePrintCallback',@printCallback);
            set(hBehavior,'PostPrintCallback',@printCallback);
            function printCallback(h,callbackName)



                if strcmp(callbackName,'PrePrintCallback')
                    setappdata(h,'restoreScribeGridVisible',...
                    get(h,'Visible'))
                    set(h,'Visible','off');
                else
                    restoreVal=getappdata(h,'restoreScribeGridVisible');
                    if~isempty(restoreVal)
                        if strcmp(restoreVal,'on')
                            set(h,'Visible','on');
                        end
                        rmappdata(h,'restoreScribeGridVisible');
                    end
                end
            end
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)


            hCamera=updateState.Camera;
            viewport=hCamera.Viewport;

            device_ppos=viewport.RefFrame;

            ppos=updateState.convertUnits('canvas','pixels','devicepixels',device_ppos);


            xV=0:hObj.XSpace:ppos(3);
            xV=xV./ppos(3);
            numPoints=numel(xV);
            xV=[xV;xV];
            xV=xV(:).';
            yV=repmat([0,1],1,numPoints);


            yH=0:hObj.YSpace:ppos(4);
            yH=yH./ppos(4);
            numPoints=numel(yH);
            yH=[yH;yH];
            yH=yH(:).';
            xH=repmat([0,1],1,numPoints);


            hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            hIter.XData=[xV,xH];
            hIter.YData=[yV,yH];
            vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,hIter);

            hLine=hObj.LineHandle;
            hLine.VertexData=vertexData;

            hLine.StripData=[];
        end
    end




end
