classdef Outport<flexibleportplacement.connector.Port




    properties(SetAccess=private)
        DefaultBlockSide=ConnectorPlacement.RectSide.RIGHT;
    end

    properties(Dependent,SetAccess=private)
DisplayName
Identifier
    end

    methods
        function obj=Outport(ph)
            obj=obj@flexibleportplacement.connector.Port(ph);
        end

        function id=get.Identifier(obj)
            id=['Out',num2str(obj.PortNumber)];
        end

        function name=get.DisplayName(obj)
            name=obj.getPortLabelBasedDisplayName(false);
        end
    end
end

