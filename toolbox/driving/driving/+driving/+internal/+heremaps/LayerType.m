classdef LayerType

    enumeration
        None("")


        AdasAttributes("adas-attributes")
        ExternalReferenceAttributes("external-reference-attributes")
        RoutingAttributes("routing-attributes")
        RoutingLaneAttributes("routing-lane-attributes")
        SpeedAttributes("speed-attributes")
        TopologyGeometry("topology-geometry",true)


        LaneAttributes("lane-attributes")
        LaneGeometryPolyline("lane-geometry-polyline",true)
        LaneRoadReferences("lane-road-references")
        LaneTopology("lane-topology",true)


        LocalizationBarrier("localization-barrier")
        LocalizationSign("localization-sign")
        LocalizationPole("localization-pole")
    end

    properties

        Name(1,1)string


        IsPlottable(1,1)logical=false
    end

    methods

        function L=LayerType(layerName,isPlottable)

            L.Name=layerName;
            if nargin>1
                L.IsPlottable=isPlottable;
            end
        end

        function tf=isReadable(this)

            tf=this~=driving.internal.heremaps.LayerType.None;
        end

        function[B,I]=sort(A,varargin)





            names=string(A);
            [~,I]=sort(names,varargin{:});
            B=A(I);
        end

    end

    methods(Static)

        function L=convert(layerNames)


            layerNames=cellstr(layerNames);


            members=driving.internal.heremaps.LayerType.getProduction();


            L=repmat(driving.internal.heremaps.LayerType.None,...
            size(layerNames));


            [found,idxs]=ismember(layerNames,[members.Name]);
            L(found)=members(idxs(found));
        end

        function L=getPlottable()

            members=enumeration('driving.internal.heremaps.LayerType');
            L=members([members.IsPlottable]);
        end

        function L=getProduction()

            L=enumeration('driving.internal.heremaps.LayerType');
        end

    end

end