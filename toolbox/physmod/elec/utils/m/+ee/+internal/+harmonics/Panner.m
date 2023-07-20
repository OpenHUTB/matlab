classdef Panner<handle




    properties
Axes
Polyshape
ButtonDownX
ButtonDownPolyshapeX
        IsButtonDown=false;
    end

    properties(SetObservable)
XSelected
    end

    properties(Dependent)
IsMouseWithinPatch
    end

    events
PreValueChanged
ValueChanged
PostValueChanged
    end

    methods
        function obj=Panner(axes,tIntervalToPan)

            obj.Axes=axes;
            hold(obj.Axes,'on');
            obj.Axes.XLim=[min(obj.Axes.Children.XData),max(obj.Axes.Children.XData)];
            obj.Axes.Children(end).Color=[0,0.4470,0.741];
            obj.createPanner(tIntervalToPan);
        end

        function createPanner(obj,tIntervalToPan)


            minXValue=tIntervalToPan(1);
            maxXValue=tIntervalToPan(2);
            minYValue=min(obj.Axes.Children(end).YData);
            maxYValue=max(obj.Axes.Children(end).YData);

            createPolyshape=polyshape([minXValue,maxXValue,maxXValue,minXValue],...
            [minYValue,minYValue,maxYValue,maxYValue]);

            obj.Polyshape=plot(obj.Axes,createPolyshape);
            obj.Polyshape.FaceColor=[0.85,0.325,0.098];
            obj.Axes.XLimMode='manual';
            disableDefaultInteractivity(obj.Axes);

            obj.XSelected=[min(obj.Polyshape.Shape.Vertices(:,1)),max(obj.Polyshape.Shape.Vertices(:,1))];

            obj.Axes.Parent.Parent.WindowButtonDownFcn=@(src,evnt)obj.ButtonDownCallback(src,evnt);
            obj.Axes.Parent.Parent.WindowButtonUpFcn=@(src,evnt)obj.ButtonUpCallback(src,evnt);
            obj.Axes.Parent.Parent.WindowButtonMotionFcn=@(src,evnt)obj.ButtonMotionCallback(src,evnt);
        end

        function ButtonDownCallback(obj,~,~)


            if obj.IsMouseWithinPatch
                obj.IsButtonDown=true;
                obj.ButtonDownX=obj.Axes.CurrentPoint(1,1);
                obj.ButtonDownPolyshapeX=obj.Polyshape.Shape.Vertices(:,1);
                notify(obj,'PreValueChanged');
            end
        end

        function ButtonUpCallback(obj,~,~)


            if obj.IsButtonDown
                obj.IsButtonDown=false;
                notify(obj,'PostValueChanged');
            end
        end

        function ButtonMotionCallback(obj,~,~)


            if obj.IsButtonDown
                currentX=obj.Axes.CurrentPoint(1,1);
                deltaX=currentX-obj.ButtonDownX;
                proposedPosition=obj.ButtonDownPolyshapeX+deltaX;

                if any(proposedPosition<obj.Axes.XLim(1))
                    deltaX=obj.Axes.XLim(1)-min(obj.ButtonDownPolyshapeX);
                    proposedPosition=obj.ButtonDownPolyshapeX+deltaX;
                elseif any(proposedPosition>obj.Axes.XLim(2))
                    deltaX=obj.Axes.XLim(2)-max(obj.ButtonDownPolyshapeX);
                    proposedPosition=obj.ButtonDownPolyshapeX+deltaX;
                end
                obj.Polyshape.Shape.Vertices(:,1)=proposedPosition;
                obj.XSelected=[min(obj.Polyshape.Shape.Vertices(:,1)),max(obj.Polyshape.Shape.Vertices(:,1))];
                notify(obj,'ValueChanged');
            end
        end

        function value=get.IsMouseWithinPatch(obj)
            currentPoint=obj.Axes.CurrentPoint(1,1:2);
            value=inpolygon(currentPoint(1),currentPoint(2),obj.Polyshape.Shape.Vertices(:,1),obj.Polyshape.Shape.Vertices(:,2));
        end
    end
end