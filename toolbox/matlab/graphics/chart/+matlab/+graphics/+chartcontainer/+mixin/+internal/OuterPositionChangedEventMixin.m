classdef(Hidden)OuterPositionChangedEventMixin<matlab.graphics.mixin.Mixin




    properties(Access='private',Hidden,Transient,NonCopyable)
        CleanedListener event.listener=event.listener.empty
        OuterPositionChangedEvent(1,1)matlab.graphics.chart.internal.OuterPositionChangedEventData
        DataHasChanged(1,1)logical
        OuterPositionInPixels(4,1)int64
    end

    events(Hidden)
OuterPositionChanged
    end

    methods(Access=protected)
        function obj=OuterPositionChangedEventMixin()
            obj.OuterPositionInPixels=[-1;-1;-1;-1];
            obj.DataHasChanged=false;
            obj.OuterPositionChangedEvent=matlab.graphics.chart.internal.OuterPositionChangedEventData();
            obj.CleanedListener=event.listener(obj,'MarkedClean',@(~,~)obj.markedCleanForUpdateEvent());
        end

        function setState(obj,pixelval,SourceMethod,PositionConstraint)
            pixelval=pixelval(:);

            if isempty(pixelval)
                return;
            end

            if(all(obj.OuterPositionInPixels==pixelval))
                return;
            end

            obj.OuterPositionInPixels=pixelval;
            obj.OuterPositionChangedEvent.SourceMethod=SourceMethod;
            obj.OuterPositionChangedEvent.PositionConstraint=PositionConstraint;
            obj.DataHasChanged=true;
        end

        function firePostSetOuterPositionEvent(hObj,pos)

            units=hObj.Units;


            vp=hObj.getUnitPositionObject();

            positionConstraint=string(hObj.ActivePositionProperty);

            outerPosPixels=matlab.graphics.internal.convertUnits(...
            vp,'pix',units,pos);


            hObj.setState(outerPosPixels,...
            "setOuterPositionImpl",...
            positionConstraint);

            if(hObj.shouldFire())
                notify(hObj,'OuterPositionChanged',hObj.OuterPositionChangedEvent);
                hObj.resetAfterFiringEvent();
            end
        end
    end

    methods(Access=private)
        function markedCleanForUpdateEvent(hObj)

            if(hObj.shouldFire())
                notify(hObj,'OuterPositionChanged',hObj.OuterPositionChangedEvent);
                hObj.resetAfterFiringEvent();
            end
        end

        function tf=shouldFire(obj)
            tf=obj.DataHasChanged;
        end

        function resetAfterFiringEvent(obj)
            obj.DataHasChanged=false;
        end
    end

    methods(Abstract,Access=protected)
        vp=getUnitPositionObject(obj);
    end
end
