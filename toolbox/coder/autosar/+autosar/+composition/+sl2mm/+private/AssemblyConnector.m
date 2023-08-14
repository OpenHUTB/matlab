classdef AssemblyConnector<handle




    properties
        ProviderCompPrototypeName;
        ProviderPortPrototypeQName;
        RequesterCompPrototypeName;
        RequesterPortPrototypeQName;
        SLLineDescription;
    end

    methods
        function this=AssemblyConnector(providerComp,providerPort,...
            requesterComp,requesterPort,slLineDescription)
            this.ProviderCompPrototypeName=arblk.convertPortNameToArgName(providerComp);
            this.ProviderPortPrototypeQName=providerPort;
            this.RequesterCompPrototypeName=arblk.convertPortNameToArgName(requesterComp);
            this.RequesterPortPrototypeQName=requesterPort;

            if nargin>4
                this.SLLineDescription=slLineDescription;
            else
                this.SLLineDescription='';
            end
        end

        function name=calculateConnectorName(this,maxShortNameLength)
            [~,pport]=autosar.utils.splitQualifiedName(this.ProviderPortPrototypeQName);
            [~,rport]=autosar.utils.splitQualifiedName(this.RequesterPortPrototypeQName);
            name=[this.ProviderCompPrototypeName,'_',pport,'_',this.RequesterCompPrototypeName,'_',rport];
            name=arxml.arxml_private('p_create_aridentifier',name,maxShortNameLength);
        end
    end
end


