classdef TriggerPort<Simulink.CMI.InPort
    methods
        function obj=TriggerPort(varargin)
            obj@Simulink.CMI.InPort(varargin{:})
            pType=Simulink.CMI.util.portType(obj);
            if~strcmp(pType,'trigger')
                ME=MException('Simulink:CMI:NotATriggerPort',...
                'Handle %g is not a handle of an trigger port',obj.Handle);
                throw(ME);
            end
        end
        function s=getIdentifierString(obj)
            s=[getHyperlink(ParentBlock(obj)),'/trigger'];
        end

        function s=getIdentifierStringNoHyperlink(obj)
            s=[getFullpathName(ParentBlock(obj)),'/trigger'];
        end
    end
end