classdef PortDisplay<matlab.mixin.CustomDisplay&handle
    methods(Access=protected,Sealed=true)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                pType=Simulink.CMI.util.portType(obj);
                propList=struct('Type',pType,...
                'Identifier',getIdentifierString(obj));
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end

    methods
        function s=getIdentifierString(obj)
            s=[getHyperlink(ParentBlock(obj)),'/',int2str(obj.Index+1)];
        end

        function s=getIdentifierStringNoHyperlink(obj)
            s=[getFullpathName(ParentBlock(obj)),'/',int2str(obj.Index+1)];
        end
    end
end
