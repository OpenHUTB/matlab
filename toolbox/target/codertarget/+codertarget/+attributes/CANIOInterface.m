classdef(Sealed=true)CANIOInterface<codertarget.attributes.IOInterface







    properties
        CANVendor=struct('value','','visible',true)
        CANDevice=struct('value','','visible',true)
        CANChannel=struct('value','','visible',true)
        BusSpeed=struct('value','1000000','visible',true)
        CANIDCommand=struct('value','2','visible',true)
        CANIDResponse=struct('value','3','visible',true)
        IsCANIDExtended=struct('value','0','visible',true)
        Verbose=struct('value','false','visible',true)
    end

    methods(Access={?codertarget.attributes.ExternalModeInfo})
        function h=CANIOInterface(structVal)
            if isstruct(structVal)
                h.initializeIOInterface(structVal);
                if isfield(structVal,'canvendor')
                    h.CANVendor=structVal.canvendor;
                end
                if isfield(structVal,'candevice')
                    h.CANDevice=structVal.candevice;
                end
                if isfield(structVal,'canchannel')
                    h.CANChannel=structVal.canchannel;
                end
                if isfield(structVal,'busspeed')
                    h.BusSpeed=structVal.busspeed;
                end
                if isfield(structVal,'canidcommand')
                    h.CANIDCommand=structVal.canidcommand;
                end
                if isfield(structVal,'canidresponse')
                    h.CANIDResponse=structVal.canidresponse;
                end
                if isfield(structVal,'iscanidextened')
                    h.IsCANIDExtended=structVal.iscanidextened;
                end
                if isfield(structVal,'verbose')
                    h.Verbose=structVal.verbose;
                end
            end
        end
    end
    methods
        function set.CANVendor(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'CANVendor');
            obj.CANVendor=val;
        end
        function set.CANDevice(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'CANDevice');
            obj.CANDevice=val;
        end
        function set.CANChannel(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'CANChannel');
            obj.CANChannel=val;
        end
        function set.BusSpeed(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'BusSpeed');
            obj.BusSpeed=val;
        end
        function set.CANIDCommand(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'CANIDCommand');
            obj.CANIDCommand=val;
        end
        function set.CANIDResponse(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'CANIDResponse');
            obj.CANIDResponse=val;
        end
        function set.IsCANIDExtended(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'IsCANIDExtended');
            val.value=~isequal(val.value,'false')&&~isequal(val.value,'0');
            obj.IsCANIDExtended=val;
        end
        function set.Verbose(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'Verbose');
            val.value=~isequal(val.value,'false')&&~isequal(val.value,'0');
            obj.Verbose=val;
        end
    end
end