classdef instrument<instrument.internal.InstrumentBaseClass














    properties(Hidden,SetAccess='public',GetAccess='public')

jobject
constructor

        store={};
    end

    methods
        function obj=instrument(validname)
            obj=obj@instrument.internal.InstrumentBaseClass(validname);
            if(nargin==0||~any(strcmp(validname,{'serial','Bluetooth','i2c','gpib','visa','tcpip','udp','icdevice'})))


                if isempty(which('gpib'))
                    error(message('instrument:instrument:instrument:invalidSyntaxSerial'));
                else
                    error(message('instrument:instrument:instrument:invalidSyntax'))
                end
            end


            if~usejava('jvm')
                error(message('instrument:instrument:instrument:nojvm'));
            end





            str=computer;
            if strcmpi(validname,'Bluetooth')
                if strcmpi(str,'GLNXA64')
                    msg=getString(message('instrument:Bluetooth:Bluetooth:noBluetoothSupportInLinux'));
                    e=MException('instrument:Bluetooth:Bluetooth:noBluetoothSupportInLinux',msg);
                    throwAsCaller(e);
                end
            end

            obj.constructor=class(obj);
        end
    end

    methods(Hidden)
        function p=properties(obj)

            p=fieldnames(obj);
        end
    end
end
