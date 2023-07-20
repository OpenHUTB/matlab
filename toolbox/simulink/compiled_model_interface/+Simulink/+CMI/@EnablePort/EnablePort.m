classdef EnablePort<Simulink.CMI.InPort
    methods
        function obj=EnablePort(varargin)
            obj@Simulink.CMI.InPort(varargin{:})
            pType=Simulink.CMI.util.portType(obj);
            if~strcmp(pType,'enable')
                ME=MException('Simulink:CMI:NotAnEnablePort',...
                'Handle %g is not a handle of an enable port',obj.Handle);
                throw(ME);
            end
        end
        function s=getIdentifierString(obj)
            s=[getHyperlink(ParentBlock(obj)),'/enable'];
        end

        function s=getIdentifierStringNoHyperlink(obj)
            s=[getFullpathName(ParentBlock(obj)),'/enable'];
        end
    end
end
