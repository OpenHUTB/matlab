classdef TransportFactory<handle





    properties(Access=private)



TestTransport
RealTransport
    end

    methods(Static,Access=public)
        function obj=getInstance()
            persistent transport;

            if isempty(transport)
                transport=matlabshared.blelib.internal.TransportFactory;
            end
            obj=transport;
        end
    end

    methods(Access=public)
        function output=get(obj)

            s=settings;
            if s.matlab.hardware.hasGroup('ble')&&s.matlab.hardware.ble.hasSetting('IsTest')&&s.matlab.hardware.ble.IsTest.ActiveValue
                output=obj.TestTransport;
            else
                output=obj.RealTransport;
            end
        end
    end

    methods(Access=private)
        function obj=TransportFactory()
            s=settings;
            if s.matlab.hardware.hasGroup('ble')&&s.matlab.hardware.ble.hasSetting('IsTest')&&s.matlab.hardware.ble.IsTest.ActiveValue
                return
            end
            switch computer('arch')
            case 'win64'
                obj.RealTransport=matlabshared.blelib.internal.WindowsTransport;
            case 'maci64'
                obj.RealTransport=matlabshared.blelib.internal.MacTransport;
            case 'glnxa64'
                obj.RealTransport=matlabshared.blelib.internal.LinuxTransport;
            end
        end
    end

    methods(Access=?matlabshared.blelib.internal.TestAccessor)
        function set(obj,input)

            obj.TestTransport=input;
        end
    end
end