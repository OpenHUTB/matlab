


classdef SubPortEmpty<hdlturnkey.data.SubPort


    methods(Access=public)

        function obj=SubPortEmpty(portID)

            obj=obj@hdlturnkey.data.SubPort(portID);
        end

        function portIDStr=getPortIDDispStr(obj)

            portIDStr=obj.PortID;
        end

    end

end


