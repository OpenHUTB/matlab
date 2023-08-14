classdef RConn<flexibleportplacement.connector.Port




    properties(SetAccess=private)
        DefaultBlockSide=ConnectorPlacement.RectSide.RIGHT;
    end

    properties(Dependent,SetAccess=private)
DisplayName
Identifier
    end

    methods
        function obj=RConn(ph)
            obj=obj@flexibleportplacement.connector.Port(ph);
        end

        function id=get.Identifier(obj)
            portNum=get_param(obj.Handle,'PortNumber');
            id=['RConn',num2str(portNum)];
        end

        function name=get.DisplayName(obj)
            name=obj.Identifier;
        end
    end

    methods(Access=protected)
        function portNum=getPortNumberImpl(obj)
            block=get_param(obj.Handle,'Parent');
            portCounts=get_param(block,'Ports');
            nOutports=portCounts(2);

            portNum=get_param(obj.Handle,'PortNumber')+nOutports;
        end
    end
end

