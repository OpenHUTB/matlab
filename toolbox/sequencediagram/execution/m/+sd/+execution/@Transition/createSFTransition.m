function dt=createSFTransition(obj,parent)

    if(~isempty(obj.dest.cachedSFState))

        dt=Stateflow.Transition(parent);
        dt.DestinationEndPoint=[obj.destinationEndPointX,obj.destinationEndPointY];
        dt.Destination=obj.dest.cachedSFState;

        if(~isempty(obj.source))
            dt.SourceEndPoint=[obj.sourceEndPointX,obj.sourceEndPointY];
            dt.Source=obj.source.cachedSFState;

            if(obj.source==obj.dest)

                midpoint=dt.MidPoint;
                switch obj.destEdge
                case sd.execution.NodeEdge.TOP
                    dt.Midpoint=[midpoint(1),obj.destinationEndPointY-50];
                case sd.execution.NodeEdge.BOTTOM
                    dt.Midpoint=[midpoint(1),obj.destinationEndPointY+50];
                case sd.execution.NodeEdge.LEFT
                    dt.Midpoint=[obj.destinationEndPointX-50,midpoint(2)];
                case sd.execution.NodeEdge.RIGHT
                    dt.Midpoint=[obj.destinationEndPointX+50,midpoint(2)];
                end
            end
        else

            switch obj.destEdge
            case sd.execution.NodeEdge.TOP
                dt.SourceEndPoint=[obj.destinationEndPointX,obj.destinationEndPointY-50];
                dt.MidPoint=[obj.destinationEndPointX,obj.destinationEndPointY-50];
            otherwise
                dt.SourceEndPoint=[obj.destinationEndPointX+obj.width*obj.destOffset,obj.destEndPointY-50];
            end
        end


        dt.LabelString=char(obj.getLabel);
    end

