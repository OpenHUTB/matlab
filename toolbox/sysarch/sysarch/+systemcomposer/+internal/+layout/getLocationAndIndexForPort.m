function[location,idx]=getLocationAndIndexForPort(port)
    try
        port=getSourcePortFromRedefined(port);
        slPortHandle=systemcomposer.utils.getSimulinkPeer(port);
        if slPortHandle==-1

            load_system(port.getTopLevelArchitecture.getName);
            slPortHandle=systemcomposer.utils.getSimulinkPeer(port);
        end
        slPortObj=get_param(slPortHandle,'Object');
    catch



        location=diagram.editor.model.Location.Left.double;
        idx=0;
        return
    end
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
    [side,idx]=getSizeAndIndexForConnId(port,connId);
    if strcmpi(side,'left')
        location=diagram.editor.model.Location.Left;
    elseif strcmpi(side,'right')
        location=diagram.editor.model.Location.Right;
    elseif strcmpi(side,'top')
        location=diagram.editor.model.Location.Top;
    elseif strcmpi(side,'bottom')
        location=diagram.editor.model.Location.Bottom;
    end
    location=location.double;
end

function schema=getPortSchema(port)
    comp=port.getComponent;
    blockHandle=systemcomposer.utils.getSimulinkPeer(comp);
    schema=get_param(blockHandle,'PortSchema');
    if~isempty(schema)
        schema=jsondecode(schema);
    end
end

function[side,idx]=getSizeAndIndexForConnId(port,connId)

    schema=getPortSchema(port);

    side='';
    idx=0;

    if isempty(schema)
        return;
    end

    s=schema.entries.content.sides;

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

function srcPort=getSourcePortFromRedefined(port)

    redefPort=port.p_Redefines;
    if isempty(redefPort)
        srcPort=port;
    else
        srcPort=getSourcePortFromRedefined(redefPort);
    end

end
