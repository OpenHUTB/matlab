classdef ControlPort<flexibleportplacement.connector.Port




    properties(SetAccess=private)
        DefaultBlockSide=ConnectorPlacement.RectSide.TOP;
    end

    properties(Dependent,SetAccess=private)
Identifier
    end

    methods
        function obj=ControlPort(ph)
            obj=obj@flexibleportplacement.connector.Port(ph);
        end

        function id=get.Identifier(obj)
            id=['In',num2str(obj.PortNumber)];
        end
    end
end

