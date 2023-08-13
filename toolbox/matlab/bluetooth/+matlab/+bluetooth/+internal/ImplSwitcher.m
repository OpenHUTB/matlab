classdef ImplSwitcher<handle

    properties(SetAccess=?matlab.bluetooth.test.TestAccessor)
ListTransportImpl
ChannelImpl
    end

    methods
        function obj=ImplSwitcher
            obj.ListTransportImpl=matlab.bluetooth.internal.ListTransportImpl;
            obj.ChannelImpl=matlab.bluetooth.internal.AsyncIOChannelImpl;
        end
    end
end