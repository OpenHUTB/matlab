classdef IfActionPort<Simulink.CMI.InPort
    methods
        function obj=IfActionPort(varargin)
            obj@Simulink.CMI.InPort(varargin{:})
            pType=Simulink.CMI.util.portType(obj);
            if~strcmp(pType,'ifaction')
                ME=MException('Simulink:CMI:NotAnIfactionPort',...
                'Handle %g is not a handle of an If Action port',obj.Handle);
                throw(ME);
            end
        end

        function s=getIdentifierString(obj)
            s=[getHyperlink(ParentBlock(obj)),'/ifaction'];
        end

        function s=getIdentifierStringNoHyperlink(obj)
            s=[getFullpathName(ParentBlock(obj)),'/ifaction'];
        end
    end
end
