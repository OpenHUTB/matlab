classdef(Sealed=true)SerialIOInterface<codertarget.attributes.IOInterface



    properties
        COMPort=struct('value','COM1','visible','true')
        Baudrate=struct('value','115200','visible','true')
        Verbose=struct('value','false','visible','true')
        AvailableCOMPorts={}
        AvailableBaudrates={}
    end
    methods(Access={?codertarget.attributes.ExternalModeInfo})
        function h=SerialIOInterface(structVal)
            if isstruct(structVal)
                h.initializeIOInterface(structVal)
                if isfield(structVal,'comport')
                    h.COMPort=structVal.comport;
                end
                if isfield(structVal,'baudrate')
                    h.Baudrate=structVal.baudrate;
                end
                if isfield(structVal,'verbose')
                    h.Verbose=structVal.verbose;
                end
                if isfield(structVal,'availablecomports')
                    h.AvailableCOMPorts=structVal.availablecomports;
                end
                if isfield(structVal,'availablebaudrates')
                    h.AvailableBaudrates=structVal.availablebaudrates;
                end
            end
        end
    end
    methods
        function obj=set.COMPort(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'COMPort');
            obj.COMPort=val;
        end
        function obj=set.Baudrate(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'Baudrate');
            obj.Baudrate=val;
        end
        function obj=set.Verbose(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'Verbose');
            val.value=~isequal(val.value,'false')&&~isequal(val.value,'0');
            obj.Verbose=val;
        end
        function obj=set.AvailableCOMPorts(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','AvailableCOMPorts');
            end
            obj.AvailableCOMPorts=cellstr(val);
        end
        function obj=set.AvailableBaudrates(obj,val)
            if~iscell(val)&&~ischar(val)&&~isnumeric(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','AvailableBaudrates');
            elseif iscell(val)
                val=str2double(val);
            end
            obj.AvailableBaudrates=val;
        end
    end
end