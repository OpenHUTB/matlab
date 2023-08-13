classdef Factory<handle

    properties(Constant,Access=?matlab.bluetooth.test.TestAccessor)

        Switcher=matlab.bluetooth.internal.ImplSwitcher
    end

    methods(Static,Access=public)
        function output=getListTransport()

            impl=matlab.bluetooth.internal.Factory.Switcher.ListTransportImpl;
            output=get(impl);
        end

        function output=getChannelInfo()

            impl=matlab.bluetooth.internal.Factory.Switcher.ChannelImpl;
            output=get(impl);
        end
    end
end