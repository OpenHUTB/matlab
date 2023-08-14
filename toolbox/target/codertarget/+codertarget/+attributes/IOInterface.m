classdef(Abstract)IOInterface<matlab.mixin.SetGet



    properties
Name
Type
IOInterfaceName
    end
    methods(Access={?codertarget.attributes.ExternalModeInfo,?codertarget.attributes.IOInterface})
        function h=IOInterface
        end
    end
    methods(Access='protected')
        function initializeIOInterface(h,structVal)
            if isstruct(structVal)&&isfield(structVal,'name')&&isfield(structVal,'type')
                h.Name=structVal.name;
                h.Type=structVal.type;
                if isfield(structVal,'iointerfacename')
                    h.IOInterfaceName=structVal.iointerfacename;
                else
                    h.IOInterfaceName=structVal.name;
                end
            end
        end
    end
    methods(Static,Access='protected')
        function value=refineTransportSubField(value,name)
            p=isstruct(value)&&isfield(value,'value')&&isfield(value,'visible');
            if~p
                DAStudio.error('codertarget:targetapi:StructureInputInvalid',name,'''value'' and ''visible''');
            end
            if isfield(value,'visible')
                val=value.visible;
                if isempty(val)
                    val=true;
                elseif ischar(val)
                    val=~isequal(val,'false')&&~isequal(val,'0');
                end
                value.visible=val;
            end
        end
    end

    methods
        function obj=set.Name(obj,val)%#ok<MCHV3>
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','Name');
            end
            obj.Name=val;
        end
        function obj=set.Type(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','Type');
            elseif~ismember(lower(val),{'serial','tcp/ip','can','custom'})
                DAStudio.error('codertarget:targetapi:InvalidExtModeTransport');
            end
            obj.Type=lower(val);
        end
        function obj=set.IOInterfaceName(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','IOInterfaceName');
            end
            obj.IOInterfaceName=val;
        end
    end
end