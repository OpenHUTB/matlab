classdef(Sealed,Hidden)ConnectionsSection<simscape.battery.internal.sscinterface.Section




    properties(Constant)
        Type="ConnectionsSection";
    end

    properties(Constant,Access=protected)
        SectionIdentifier="connections"
    end

    methods
        function obj=ConnectionsSection()

        end

        function obj=addConnection(obj,sourcePort,destinationPorts)

            obj.SectionContent(end+1)=simscape.battery.internal.sscinterface.Connection(sourcePort,destinationPorts);
        end
    end
end
