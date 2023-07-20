classdef(Sealed=true)CustomIOInterface<codertarget.attributes.IOInterface



    properties
        MEXArgs=struct('value','','visible','false')
    end
    methods(Access={?codertarget.attributes.ExternalModeInfo})
        function h=CustomIOInterface(structVal)
            if isstruct(structVal)
                h.initializeIOInterface(structVal);
                if isfield(structVal,'mexargs')
                    h.MEXArgs=structVal.mexargs;
                end
            end
        end
    end
    methods
        function obj=set.MEXArgs(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'MEXArgs');
            obj.MEXArgs=val;
        end
    end
end