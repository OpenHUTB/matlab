classdef ConnectionMap

    properties(Access=private)
ConnectedDevices
    end

    methods(Static,Access=public)
        function obj=getInstance()
            persistent map;

            if isempty(map)
                map=matlab.bluetooth.internal.ConnectionMap;
            end
            obj=map;
        end
    end

    methods(Access=private)
        function obj=ConnectionMap


            obj.ConnectedDevices=containers.Map;
        end
    end

    methods(Access=public)
        function channel=get(obj,address)


            if isKey(obj.ConnectedDevices,address)
                channel=obj.ConnectedDevices(address);
            else
                channel=[];
            end
        end

        function add(obj,address,channel)

            obj.ConnectedDevices(address)=channel;
        end

        function remove(obj,address)

            if isKey(obj.ConnectedDevices,address)
                remove(obj.ConnectedDevices,address);
            end
        end
    end
end