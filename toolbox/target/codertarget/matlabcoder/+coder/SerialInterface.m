classdef(Sealed=true)SerialInterface<coder.internal.IOInterface



















    properties(Access='public')


        DefaultBaudrate=115200;


        AvailableBaudrates=115200;


        DefaultPort='';


        AvailablePorts={};
    end
    methods(Access='public')
        function h=SerialInterface(interfaceName)
            h.Name=interfaceName;
        end
    end
end
