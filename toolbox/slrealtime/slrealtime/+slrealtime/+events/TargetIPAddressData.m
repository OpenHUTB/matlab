classdef TargetIPAddressData<event.EventData




    properties
address
    end

    methods
        function data=TargetIPAddressData(address)
            data.address=address;
        end
    end
end
