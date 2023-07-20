classdef StatePort<Simulink.CMI.OutPort
    methods
        function obj=StatePort(varargin)
            obj@Simulink.CMI.OutPort(varargin{:});
            pType=Simulink.CMI.util.portType(obj);
            if~strcmp(pType,'state')
                ME=MException('Simulink:CMI:NotAnStatePort',...
                'Handle %g is not a handle of a state port',obj.Handle);
                throw(ME);
            end
        end
        function s=getIdentifierString(obj)
            s=[getHyperlink(ParentBlock(obj)),'/state'];
        end

        function s=getIdentifierStringNoHyperlink(obj)
            s=[getFullpathName(ParentBlock(obj)),'/state'];
        end

    end
end
