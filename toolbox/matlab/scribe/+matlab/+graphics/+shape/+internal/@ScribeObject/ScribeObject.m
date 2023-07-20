
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Hidden=true)ScribeObject<matlab.graphics.primitive.world.Group&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable





    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=true,Hidden=false)

        Afsize(1,1)double=6;
    end

    methods
        function valueToCaller=get.Afsize(hObj)


            valueToCaller=hObj.Afsize_I;

        end

        function set.Afsize(hObj,newValue)



            hObj.AfsizeMode='manual';


            hObj.Afsize_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AfsizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AfsizeMode(hObj)
            storedValue=hObj.AfsizeMode;
        end

        function set.AfsizeMode(hObj,newValue)

            oldValue=hObj.AfsizeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AfsizeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        Afsize_I(1,1)double=6;
    end

    methods
        function storedValue=get.Afsize_I(hObj)
            storedValue=hObj.Afsize_I;
        end

        function set.Afsize_I(hObj,newValue)



            hObj.Afsize_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.Color(hObj)



            valueToCaller=hObj.getColorImpl(hObj.Color_I);


        end

        function set.Color(hObj,newValue)



            hObj.ColorMode='manual';



            reallyDoCopy=~isequal(hObj.Color_I,newValue);

            if reallyDoCopy
                hObj.Color_I=hObj.setColorImpl(newValue);
            end

            hObj.MarkDirty('all');



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


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=true,Hidden=false)

        ColorProps={};
    end

    methods
        function valueToCaller=get.ColorProps(hObj)


            valueToCaller=hObj.ColorProps_I;

        end

        function set.ColorProps(hObj,newValue)



            hObj.ColorPropsMode='manual';


            hObj.ColorProps_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ColorPropsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColorPropsMode(hObj)
            storedValue=hObj.ColorPropsMode;
        end

        function set.ColorPropsMode(hObj,newValue)

            oldValue=hObj.ColorPropsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColorPropsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        ColorProps_I={};
    end

    methods
        function storedValue=get.ColorProps_I(hObj)
            storedValue=hObj.ColorProps_I;
        end

        function set.ColorProps_I(hObj,newValue)



            hObj.ColorProps_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        MoveStyle matlab.internal.datatype.matlab.graphics.chart.datatype.ScribeMoveModeType='none';
    end

    methods
        function valueToCaller=get.MoveStyle(hObj)


            valueToCaller=hObj.MoveStyle_I;

        end

        function set.MoveStyle(hObj,newValue)



            hObj.MoveStyleMode='manual';


            hObj.MoveStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MoveStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MoveStyleMode(hObj)
            storedValue=hObj.MoveStyleMode;
        end

        function set.MoveStyleMode(hObj,newValue)

            oldValue=hObj.MoveStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MoveStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MoveStyle_I matlab.internal.datatype.matlab.graphics.chart.datatype.ScribeMoveModeType='none';
    end

    methods
        function storedValue=get.MoveStyle_I(hObj)
            storedValue=hObj.MoveStyle_I;
        end

        function set.MoveStyle_I(hObj,newValue)



            hObj.MoveStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='protected',Dependent=true,Hidden=false)

        NormalizedPosition matlab.internal.datatype.matlab.graphics.chart.datatype.ScribePosition=[0.3,0.3,0.1,0.1];
    end

    methods
        function valueToCaller=get.NormalizedPosition(hObj)



            valueToCaller=hObj.getNormalizedPositionImpl(hObj.NormalizedPosition_I);


        end

        function set.NormalizedPosition(hObj,newValue)



            hObj.NormalizedPositionMode='manual';



            reallyDoCopy=~isequal(hObj.NormalizedPosition_I,newValue);

            if reallyDoCopy
                hObj.NormalizedPosition_I=hObj.setNormalizedPositionImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NormalizedPositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NormalizedPositionMode(hObj)
            storedValue=hObj.NormalizedPositionMode;
        end

        function set.NormalizedPositionMode(hObj,newValue)

            oldValue=hObj.NormalizedPositionMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NormalizedPositionMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        NormalizedPosition_I matlab.internal.datatype.matlab.graphics.chart.datatype.ScribePosition=[0.3,0.3,0.1,0.1];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        Pin(:,1)matlab.graphics.shape.internal.ScribePin=matlab.graphics.shape.internal.ScribePin.empty;
    end

    methods
        function valueToCaller=get.Pin(hObj)



            valueToCaller=hObj.getPinImpl(hObj.Pin_I);


        end

        function set.Pin(hObj,newValue)



            hObj.PinMode='manual';



            reallyDoCopy=~isequal(hObj.Pin_I,newValue);

            if reallyDoCopy
                hObj.Pin_I=hObj.setPinImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PinMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PinMode(hObj)
            storedValue=hObj.PinMode;
        end

        function set.PinMode(hObj,newValue)

            oldValue=hObj.PinMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PinMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Pin_I(:,1)matlab.graphics.shape.internal.ScribePin=matlab.graphics.shape.internal.ScribePin.empty;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true)

        PinAff(:,1)int8;
    end

    methods
        function valueToCaller=get.PinAff(hObj)


            valueToCaller=hObj.PinAff_I;

        end

        function set.PinAff(hObj,newValue)



            hObj.PinAffMode='manual';


            hObj.PinAff_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PinAffMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PinAffMode(hObj)
            storedValue=hObj.PinAffMode;
        end

        function set.PinAffMode(hObj,newValue)

            oldValue=hObj.PinAffMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PinAffMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        PinAff_I(:,1)int8;
    end

    methods
        function storedValue=get.PinAff_I(hObj)
            storedValue=hObj.PinAff_I;
        end

        function set.PinAff_I(hObj,newValue)



            hObj.PinAff_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        PinMarkerContainer(:,1)matlab.graphics.primitive.world.Marker=matlab.graphics.primitive.world.Marker.empty;
    end

    methods
        function storedValue=get.PinMarkerContainer(hObj)
            storedValue=hObj.PinMarkerContainer;
        end

        function set.PinMarkerContainer(hObj,newValue)



            hObj.PinMarkerContainer=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        PinUpdating matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.PinUpdating(hObj)
            storedValue=hObj.PinUpdating;
        end

        function set.PinUpdating(hObj,newValue)



            hObj.PinUpdating=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Position matlab.internal.datatype.matlab.graphics.chart.datatype.ScribePosition=[0.3,0.3,0.1,0.1];
    end

    methods
        function valueToCaller=get.Position(hObj)



            valueToCaller=hObj.getPositionImpl(hObj.Position_I);


        end

        function set.Position(hObj,newValue)



            hObj.PositionMode='manual';



            reallyDoCopy=~isequal(hObj.Position_I,newValue);

            if reallyDoCopy
                hObj.Position_I=hObj.setPositionImpl(newValue);
            end

            hObj.MarkDirty('all');



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


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Position_I matlab.internal.datatype.matlab.graphics.chart.datatype.ScribePosition=[0.3,0.3,0.1,0.1];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Srect(:,1)matlab.graphics.primitive.world.Marker;
    end

    methods
        function valueToCaller=get.Srect(hObj)


            valueToCaller=hObj.Srect_I;

        end

        function set.Srect(hObj,newValue)



            hObj.SrectMode='manual';


            hObj.Srect_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        SrectMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SrectMode(hObj)
            storedValue=hObj.SrectMode;
        end

        function set.SrectMode(hObj,newValue)

            oldValue=hObj.SrectMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SrectMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        Srect_I(:,1)matlab.graphics.primitive.world.Marker;
    end

    methods
        function storedValue=get.Srect_I(hObj)
            storedValue=hObj.Srect_I;
        end

        function set.Srect_I(hObj,newValue)



            hObj.Srect_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Units matlab.internal.datatype.matlab.graphics.datatype.Units='normalized';
    end

    methods
        function valueToCaller=get.Units(hObj)



            valueToCaller=hObj.getUnitsImpl(hObj.Units_I);


        end

        function set.Units(hObj,newValue)



            hObj.UnitsMode='manual';



            reallyDoCopy=~isequal(hObj.Units_I,newValue);

            if reallyDoCopy
                hObj.Units_I=hObj.setUnitsImpl(newValue);
            end



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





    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=true,Hidden=true)

        PinExists;
    end

    methods
        function valueToCaller=get.PinExists(hObj)


            valueToCaller=hObj.PinExists_I;

        end

        function set.PinExists(hObj,newValue)



            hObj.PinExistsMode='manual';


            hObj.PinExists_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        PinExistsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.PinExistsMode(hObj)
            storedValue=hObj.PinExistsMode;
        end

        function set.PinExistsMode(hObj,newValue)

            oldValue=hObj.PinExistsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.PinExistsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        PinExists_I;
    end

    methods
        function storedValue=get.PinExists_I(hObj)
            storedValue=hObj.PinExists_I;
        end

        function set.PinExists_I(hObj,newValue)



            hObj.PinExists_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end








    methods(Access='protected')
        [hFig,hContainer]=getContainers(hObj)
    end



    methods
        function hObj=ScribeObject(varargin)








            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end



    methods(Access='protected',Hidden=true)
        function varargout=getAffordanceLocation(hObj,affNum,position)
            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getColorImpl(hObj,storedValue)

            varargout{1}=storedValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setColorImpl(hObj,newValue)

            colorProps=hObj.ColorProps;
            for i=1:numel(colorProps)
                if strcmpi(get(hObj,[colorProps{i},'Mode']),'auto')
                    set(hObj,[colorProps{i},'_I'],newValue);
                end
            end
            varargout{1}=newValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getNormalizedPositionImpl(hObj,storedValue)

            if strcmp(hObj.Units,'normalized')
                varargout{1}=hObj.Position;
            else
                [hFig,hContainer]=getContainers(hObj);
                if isempty(hContainer)


                    varargout{1}=storedValue;
                    return;
                end

                varargout{1}=hgconvertunits(hFig,hObj.Position,hObj.Units,'normalized',hContainer);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setNormalizedPositionImpl(hObj,newValue)

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getPositionImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setPositionImpl(hObj,newValue)
            varargout{1}=newValue;
            if strcmpi(hObj.PinUpdating,'on')
                return;
            end

            [hFig,hContainer]=getContainers(hObj);
            if isempty(hContainer)
                return;
            end
            hPins=hObj.Pin;
            for i=1:numel(hPins)
                currPin=hPins(i);
                pinAff=currPin.UserData;
                vd=hObj.getAffordanceLocation(pinAff,hgconvertunits(hFig,newValue,hObj.Units,'normalized',hContainer));
                pinPoint=hgconvertunits(hFig,[vd(1:2),0,0],'normalized','pixels',hContainer);
                pinPoint=pinPoint(1:2);
                currPin.repin(pinPoint,hContainer);
                if isempty(currPin.Axes)
                    hObj.unpinAtAffordance(pinAff);
                end
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getUnitsImpl(hObj,storedValue)
            varargout{1}=storedValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setUnitsImpl(hObj,newValue)

            varargout{1}=newValue;

            oldUnits=get(hObj,'Units');
            oldPos=get(hObj,'Position');
            [hFig,hContainer]=getContainers(hObj);
            if~isempty(hContainer)

                newPos=hgconvertunits(hFig,oldPos,oldUnits,newValue,hContainer);

                hObj.Position_I=newPos;
            end

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPinImpl(hObj,storedValue)

            varargout{1}=storedValue;

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=setPinImpl(hObj,newValue)

            varargout{1}=newValue;

        end
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.addDependencyConsumed('ref_frame');
        end
    end
    methods(Access='protected',Hidden=true)
        function updatePins(hObj,updateState)

            hPins=hObj.Pin;
            hPinMarkers=hObj.PinMarkerContainer;

            for i=1:numel(hPinMarkers)
                delete(hPinMarkers(i));
            end
            hPinMarkers=matlab.graphics.primitive.world.Marker.empty;
            for i=1:numel(hPins)


                if isempty(hPins(i).MovePosition)
                    hObj.PinUpdating='on';







                    if isempty(hPins(i).DataCoords)
                        vertexData=hObj.getSelectionMarkerPos(updateState);
                        hObj.pinAtAffordance(hPins(i).UserData,vertexData(:,hPins(i).UserData)');
                    end

                    hObj.updatePositionFromPin(hPins(i),updateState);

                    hObj.PinUpdating='off';
                end
            end

            if~(strcmpi(hObj.Selected,'off')||strcmpi(hObj.SelectionHighlight,'off'))

                hPins=hObj.Pin;
                [~,hContainer]=getContainers(hObj);
                for i=numel(hPins):-1:1
                    hPinMarkers(i)=matlab.graphics.primitive.world.Marker;
                    pixelPoint=hPins(i).getPixelLocation(hContainer);

                    normPoint=updateState.convertUnits('camera','normalized','pixels',pixelPoint);
                    iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                    iter.XData=normPoint(1);
                    iter.YData=normPoint(2);
                    vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
                    set(hPinMarkers(i),'FaceColorData',uint8([0;0;0;255]),...
                    'FaceColorBinding','object',...
                    'EdgeColorData',uint8([255;255;0;255]),...
                    'EdgeColorBinding','object',...
                    'HandleVisibility','off',...
                    'LineWidth',0.01,...
                    'Style','square',...
                    'Size',8,...
                    'Serializable','off',...
                    'Description','ScribePinObject',...
                    'VertexData',vertexData,...
                    'Copyable',false);
                    hObj.addNode(hPinMarkers(i));
                end
                hObj.PinMarkerContainer=hPinMarkers;
            end
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=findMoveMode(hObj,evd)

            moveMode='none';

            hFig=hObj.getTargetParent(hObj);


            if isempty(hFig)
                hObj.MoveStyle=moveMode;
                varargout{1}=moveMode;
                return;
            end

            hitObj=evd.HitObject;
            if~isequal(hitObj,hObj)
                hObj.MoveStyle=moveMode;
                varargout{1}=moveMode;
                return;
            end

            moveMode='mouseover';



            hitPrimitive=evd.HitPrimitive;
            if~isempty(hitPrimitive)
                hitPinContainer=hObj.PinMarkerContainer(hObj.PinMarkerContainer==hitPrimitive);
                if~isempty(hitPinContainer)
                    for k=1:length(hObj.Srect)
                        if isequal(hitPinContainer.VertexData,hObj.Srect(k).VertexData)

                            evd=struct('HitObject',evd.HitObject,'HitPrimitive',hObj.Srect(k),'Point',evd.Point);
                            break;
                        end
                    end
                end
            end


            hAff=hObj.Srect;
            if~isempty(evd.HitPrimitive)&&any(hAff==evd.HitPrimitive)

                moveMode=evd.HitPrimitive.Description;
            end


            hObj.MoveStyle=moveMode;
            varargout{1}=moveMode;
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getParentImpl(hObj,hParentIn)

            varargout{1}=hParentIn;
            if~isempty(hParentIn)
                parent=ancestor(hParentIn,'annotationpane');
                if~isempty(parent)
                    varargout{1}=parent;
                end
            end
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getTargetParent(hObj,hTarget)

            varargout{1}=ancestor(hTarget(1),'matlab.ui.internal.mixin.CanvasHostMixin');
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=mayMove(hObj,delta)


            [hFig,hContainer]=getContainers(hObj);

            if isempty(hContainer)
                varargout{1}=true;
                return;
            end


            delta(1)=delta(1)+4*sign(delta(1));
            delta(2)=delta(2)+4*sign(delta(2));


            delta=hgconvertunits(hFig,[delta,0,0],'pixels','normalized',hContainer);
            delta=delta(1:2);


            selRects=hObj.Srect;
            selData=zeros(numel(selRects),2);
            for i=1:numel(selRects)
                vd=selRects(i).VertexData;
                selData(i,:)=double(vd(1:2)).';
            end


            delta=repmat(delta,length(selRects),1);
            selData=selData+delta;



            clippedData=[~(selData(:,1)<0),~(selData(:,1)>1),...
            ~(selData(:,2)<0),~(selData(:,2)>1)];



            varargout{1}=any(min(clippedData,[],2));
        end
    end
    methods(Access='public',Hidden=true)
        function move(hObj,delta)

            [hFig,hContainer]=getContainers(hObj);
            if isempty(hContainer)
                return;
            end

            pixPos=hgconvertunits(hFig,hObj.Position,hObj.Units,'pixels',hContainer);
            pixPos(1:2)=pixPos(1:2)+delta;

            hObj.Position=hgconvertunits(hFig,pixPos,'pixels',hObj.Units,hContainer);
        end
    end
    methods(Access='public',Hidden=true)
        function resize(hObj,currPoint)
            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='public',Hidden=true)
        function unpinAtAffordance(hObj,affNum)
            hPins=hObj.Pin;
            if isempty(hPins)
                return;
            end


            hPins=hPins(isvalid(hPins));
            for i=1:length(hPins)
                if hPins(i).UserData==affNum
                    delete(hPins(i));
                    hPins(i)=[];
                    break;
                end
            end

            hObj.Pin=hPins;
        end
    end
    methods(Access='protected',Hidden=true)
        function updatePositionFromPin(hObj,hPin,updateState)

            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getScribeMenus(hObj)

            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPinMenus(hObj)

            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPlotEditToolbarProp(hObj,toolbarProp)

            if strcmpi(toolbarProp,'edgecolor')
                varargout{1}={'Color'};
                varargout{2}='Color';
            else
                varargout{1}={};
                varargout{2}='';
            end
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=handleScribeButtonUp(hObj)

            varargout{1}=false;
        end
    end
    methods(Access='private',Hidden=true)
        function addPinListeners(hObj,hPin,affNum)





            if~isprop(hObj,'PinDestroyedListeners')
                p=addprop(hObj,'PinDestroyedListeners');
                p.Transient=true;
                p.Hidden=true;
            end
            objectBeingDestroyedListenerUpdated=false;
            for k=1:length(hObj.PinDestroyedListeners)
                if isequal(hObj.PinDestroyedListeners(k).Source{1},hPin)
                    hObj.PinDestroyedListeners(k)=event.listener(hPin,'ObjectBeingDestroyed',@(obj,evd)(unpinAtAffordance(hObj,affNum)));
                    objectBeingDestroyedListenerUpdated=true;
                    break;
                end
            end
            if~objectBeingDestroyedListenerUpdated
                if isempty(hObj.PinDestroyedListeners)
                    hObj.PinDestroyedListeners=event.listener(hPin,'ObjectBeingDestroyed',@(obj,evd)(unpinAtAffordance(hObj,affNum)));
                else
                    hObj.PinDestroyedListeners(end+1)=event.listener(hPin,'ObjectBeingDestroyed',@(obj,evd)(unpinAtAffordance(hObj,affNum)));
                end
            end
            if~isprop(hObj,'PinChangedListeners')
                p=addprop(hObj,'PinChangedListeners');
                p.Hidden=true;
                p.Transient=true;
            end
            objectChangedListenerUpdated=false;
            for k=1:length(hObj.PinChangedListeners)
                if isequal(hObj.PinChangedListeners(k).Source{1},hPin)
                    hObj.PinChangedListeners(k)=event.listener(hPin,'PinChanged',@(obj,evd)(MarkDirty(hObj,'all')));
                    objectChangedListenerUpdated=true;
                    break;
                end
            end
            if~objectChangedListenerUpdated
                if isempty(hObj.PinChangedListeners)
                    hObj.PinChangedListeners=event.listener(hPin,'PinChanged',@(obj,evd)(MarkDirty(hObj,'all')));
                else
                    hObj.PinChangedListeners(end+1)=event.listener(hPin,'PinChanged',@(obj,evd)(MarkDirty(hObj,'all')));
                end
            end
        end
    end
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)

            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);






            if~isempty(hObj.PinExists)
                pinAffs=find(hObj.PinExists);
                par=hObj.getTargetParent(hObj);
                for i=pinAffs
                    hPin=matlab.graphics.shape.internal.ScribePin(par);
                    hPin.UserData=i;
                    hObj.Pin(end+1)=hPin;
                end
            end

            for k=1:length(hObj.Pin)
                affNum=hObj.Pin(k).UserData;
                hObj.addPinListeners(hObj.Pin(k),affNum);
            end
            varargout{1}=hObj;
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getSelectionMarkerPos(hObj,updateState)

            error(message('MATLAB:scribe:purevirtual'));
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end




end
