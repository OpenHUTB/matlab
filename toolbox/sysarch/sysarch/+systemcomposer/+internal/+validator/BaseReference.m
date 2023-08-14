classdef BaseReference<systemcomposer.internal.validator.BaseComponentBlockType



    methods

        function this=BaseReference(handleOrPath)
            if nargin==0

                return;
            end
            this.handleOrPath=handleOrPath;
        end

        function[canConvert,allowed]=canAddVariant(this)
            canConvert=true;
            allowed=true;
        end

        function[canConvert,allowed]=canInline(this)
            refName=systemcomposer.internal.getReferenceName(this.handleOrPath);
            try
                mdlInfo=Simulink.MDLInfo(refName);
                interface=mdlInfo.Interface;
                parentSubDomain=systemcomposer.internal.getSubDomain(bdroot(this.handleOrPath));
                childSubDomain=interface.SimulinkSubDomainType;

                if isempty(childSubDomain)
                    childSubDomain='Simulink';
                end





                canConvert=strcmpi(parentSubDomain,childSubDomain)||...
                (~strcmpi(parentSubDomain,'Simulink')&&strcmpi(childSubDomain,'Simulink'));
                allowed=canConvert;
            catch ME
                switch ME.identifier
                case 'Simulink:LoadSave:FileNotFound'
                    canConvert=false;
                    allowed=canConvert;
                otherwise
                    rethrow(ME)
                end
            end
        end
    end
end