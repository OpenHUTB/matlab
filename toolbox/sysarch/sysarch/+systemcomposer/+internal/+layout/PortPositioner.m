classdef PortPositioner



    properties
        Entity;
        SLBlockHandle;
        Schema;
        EntityPortMap;
    end

    properties(Constant,Hidden)
        LeftIdx=1;
        RightIdx=2;
        TopIdx=3;
        BottomIdx=4;
    end

    methods(Static)
        function positionPorts(entity,comp)
            try
                if isa(comp,'systemcomposer.architecture.model.views.BaseOccurrence')
                    obj=systemcomposer.internal.layout.PortPositioner(entity,comp);
                    if~isempty(obj.Schema)
                        obj.doPositionPorts;
                    end
                elseif isa(comp,'systemcomposer.architecture.model.views.ViewComponent')||...
                    isa(comp,'systemcomposer.architecture.model.views.LinkedViewComponent')
                    ports=comp.getPorts;
                    dPorts=entity.ports.toArray;

                    for i=1:numel(ports)
                        for j=1:numel(dPorts)
                            if strcmp(ports(i).getName,dPorts(j).title)
                                systemcomposer.internal.layout.PortPositioner.positionPort(dPorts(j),ports(i));
                                break;
                            end
                        end
                    end
                elseif isa(comp,'systemcomposer.architecture.model.design.BaseComponent')
                    obj=systemcomposer.internal.layout.PortPositioner(entity,comp);
                    if~isempty(obj.Schema)
                        obj.doPositionPorts;
                    end
                end
            catch

            end
        end

        function positionPort(dPort,port)
            try
                if isa(port,'systemcomposer.architecture.model.views.ViewComponentPort')
                    occurPort=port.getDelegateOccurrencePort;
                    compPort=occurPort.getDesignComponentPort;
                    obj=systemcomposer.internal.layout.PortPositioner(dPort.parent,compPort.getComponent);
                    if~isempty(obj.Schema)
                        obj.doPositionPort(dPort,compPort);
                    end
                end
            catch

            end
        end
    end

    methods
        function obj=PortPositioner(entity,comp)


            obj.Entity=entity;
            if isa(comp,'systemcomposer.architecture.model.views.BaseOccurrence')
                if(isa(comp.getComponent,'systemcomposer.architecture.model.design.Component'))
                    compWrapper=systemcomposer.internal.getWrapperForImpl(comp.getComponent);
                    compWrapper.Architecture;
                end
                obj.SLBlockHandle=systemcomposer.utils.getSimulinkPeer(comp.getComponent);
            else
                assert(isa(comp,'systemcomposer.architecture.model.design.BaseComponent'));
                if(isa(comp,'systemcomposer.architecture.model.design.Component'))
                    compWrapper=systemcomposer.internal.getWrapperForImpl(comp);
                    compWrapper.Architecture;
                end
                obj.SLBlockHandle=systemcomposer.utils.getSimulinkPeer(comp);
            end
            schema=get_param(obj.SLBlockHandle,'PortSchema');
            if~isempty(schema)
                obj.Schema=jsondecode(schema);
            else
                obj.Schema=schema;
            end
            obj=obj.buildEntityPortMap;
        end
    end

    methods(Access=public)

        function doPositionPorts(obj)
            for side=1:4
                connIds=obj.getConnectorIdsOnSide(side);

                for idx=1:numel(connIds)
                    connId=connIds{idx};
                    compPort=obj.getComponentPortFromConnectorId(connId);
                    diagPort=obj.EntityPortMap(compPort.getName);
                    switch(side)
                    case 1
                        diagPort.location=diagram.editor.model.Location.Left;
                    case 2
                        diagPort.location=diagram.editor.model.Location.Right;
                    case 3
                        diagPort.location=diagram.editor.model.Location.Top;
                    case 4
                        diagPort.location=diagram.editor.model.Location.Bottom;
                    end
                    diagPort.portIndex=idx;
                end
            end
        end

        function doPositionPort(obj,dPort,port)
            [location,idx]=obj.getLocationAndIndexForPort(port);
            dPort.location=location;
            dPort.portIndex=idx;
        end

        function[location,idx]=getLocationAndIndexForPort(obj,port)
            slPortHandle=systemcomposer.utils.getSimulinkPeer(port);
            slPortObj=get_param(slPortHandle,'Object');
            connId='In';
            if strcmpi(slPortObj.PortType,'outport')
                connId='Out';
            elseif strcmpi(slPortObj.PortType,'connection')
                if port.isComponentPort

                    slPortHandle=systemcomposer.utils.getSimulinkPeer(port.getArchitecturePort);
                end
                if strcmp(get_param(slPortHandle,'Side'),'Right')
                    connId='RConn';
                else
                    connId='LConn';
                end
            end
            connId=[connId,num2str(slPortObj.PortNumber)];
            [side,idx]=obj.getSizeAndIndexForConnId(connId);
            if strcmpi(side,'left')
                location=diagram.editor.model.Location.Left;
            elseif strcmpi(side,'right')
                location=diagram.editor.model.Location.Right;
            elseif strcmpi(side,'top')
                location=diagram.editor.model.Location.Top;
            elseif strcmpi(side,'bottom')
                location=diagram.editor.model.Location.Bottom;
            end
        end

        function[side,idx]=getSizeAndIndexForConnId(obj,connId)
            s=obj.Schema.entries.content.sides;
            side='';
            idx=0;
            for i=1:numel(s)
                info=s(i).content;
                connIds=info.connectorIds;
                for j=1:numel(connIds)
                    if strcmpi(connIds{j},connId)
                        if~isfield(info,'side')
                            side='LEFT';
                        else
                            side=info.side;
                        end
                        idx=j;
                        return
                    end
                end
            end
        end

        function connIds=getConnectorIdsOnSide(obj,side)
            s=obj.Schema.entries.content.sides;
            connIds={};
            for i=1:numel(s)
                info=s(i).content;
                if(~isfield(info,'side')&&side==obj.LeftIdx)
                    connIds=info.connectorIds;
                    return;
                elseif(isfield(info,'side')&&strcmpi(info.side,'right')&&side==obj.RightIdx)
                    connIds=info.connectorIds;
                    return;
                elseif(isfield(info,'side')&&strcmpi(info.side,'top')&&side==obj.TopIdx)
                    connIds=info.connectorIds;
                    return;
                elseif(isfield(info,'side')&&strcmpi(info.side,'bottom')&&side==obj.BottomIdx)
                    connIds=info.connectorIds;
                    return;
                end
            end
        end

        function compPort=getComponentPortFromConnectorId(obj,connId)
            ph=get_param(obj.SLBlockHandle,'PortHandles');
            if contains(connId,'In')
                idx=str2double(connId(3:end));
                portHandle=ph.Inport(idx);
            elseif contains(connId,'Out')
                idx=str2double(connId(4:end));
                portHandle=ph.Outport(idx);
            elseif contains(connId,'LConn')
                idx=str2double(connId(6:end));
                portHandle=ph.LConn(idx);
            elseif contains(connId,'RConn')
                idx=str2double(connId(6:end));
                portHandle=ph.RConn(idx);
            else
                assert(false,'Invalid connId');
            end
            compPort=systemcomposer.utils.getArchitecturePeer(portHandle);
        end

        function obj=buildEntityPortMap(obj)
            obj.EntityPortMap=containers.Map();
            ports=obj.Entity.ports.toArray;
            for port=ports
                obj.EntityPortMap(port.title)=port;
            end
        end
    end
end

