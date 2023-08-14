classdef Inport<flexibleportplacement.connector.Port




    properties(SetAccess=private)
        DefaultBlockSide=ConnectorPlacement.RectSide.LEFT;
    end

    properties(Dependent,SetAccess=private)
DisplayName
Identifier
    end

    methods
        function obj=Inport(ph)
            obj=obj@flexibleportplacement.connector.Port(ph);
        end

        function id=get.Identifier(obj)
            id=['In',num2str(obj.PortNumber)];
        end

        function name=get.DisplayName(obj)
            name=obj.getPortLabelBasedDisplayName(true);
        end
    end
end

