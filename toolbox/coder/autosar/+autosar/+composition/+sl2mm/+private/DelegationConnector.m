classdef DelegationConnector<handle




    properties
        InnerCompPrototypeName;
        InnerPortPrototypeQName;
        OuterPortPrototypeName;
        InnerCompM3IPort;
        IsInbound;
        SLLineDescription;
    end

    methods
        function this=DelegationConnector(innerComp,innerPort,outerPort,...
            isInbound,innerCompM3IPort,slLineDescription)
            this.InnerCompPrototypeName=arblk.convertPortNameToArgName(innerComp);
            this.InnerPortPrototypeQName=innerPort;
            this.OuterPortPrototypeName=arblk.convertPortNameToArgName(outerPort);
            this.IsInbound=isInbound;
            this.InnerCompM3IPort=innerCompM3IPort;

            if nargin>5
                this.SLLineDescription=slLineDescription;
            else
                this.SLLineDescription='';
            end
        end

        function name=calculateConnectorName(this,maxShortNameLength)
            [~,innerPort]=autosar.utils.splitQualifiedName(this.InnerPortPrototypeQName);
            if this.IsInbound
                name=[this.OuterPortPrototypeName,'_',this.InnerCompPrototypeName,'_',innerPort];
            else
                name=[this.InnerCompPrototypeName,'_',innerPort,'_',this.OuterPortPrototypeName];
            end
            name=arxml.arxml_private('p_create_aridentifier',name,maxShortNameLength);
        end
    end
end


