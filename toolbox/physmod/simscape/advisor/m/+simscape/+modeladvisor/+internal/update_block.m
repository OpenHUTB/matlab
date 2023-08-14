function update_block(blk)






    blkH=get_param(blk,'Handle');


    originalPortConf=get_param(blkH,'InternalSimscapePortConfiguration');
    out=jsondecode(originalPortConf);

    portName=lgetPortNames(out);
    pc=get_param(blkH,'PortConnectivity');

    portConnectionMap=containers.Map;
    for j=1:numel(portName)
        type=lgetPortType(blkH,portName{j});
        for i=1:numel(pc)
            if(isequal(pc(i).Type,type))
                if(~isempty(pc(i).DstPort))
                    portConnectionMap(portName{j})=pc(i).DstPort(1);
                end
            end
        end
    end


    portHandles=lgetPortHandles(blkH);
    for i=1:numel(portHandles)
        if(get(portHandles(i),'Line')~=-1)
            delete_line(get(portHandles(i),'Line'));
        end
    end


    set_param(blkH,'InternalSimscapePortConfiguration','');


    portHandles=lgetPortHandles(blkH);
    for i=1:numel(portHandles)
        nP=builtin('_simscape_gl_sli_get_port_name',blkH,portHandles(i));
        if(isKey(portConnectionMap,nP))
            add_line(get_param(blk,'Parent'),portHandles(i),portConnectionMap(nP),'AutoRouting','on');
        end
    end
end


function type=lgetPortType(blkH,portName)

    portHandle=gl.sli.getPortHandle(blkH,portName);
    type=[];
    ph=get_param(blkH,'PortHandles');
    foundLConn=ph.LConn==portHandle;
    foundRConn=ph.RConn==portHandle;

    if any(foundLConn)
        type=['LConn',num2str(find(foundLConn))];
    elseif any(foundRConn)
        type=['RConn',num2str(find(foundRConn))];
    else
        assert(isempty(type));
    end
end

function ids=lextractIds(portStructs)

    ids={};
    for i=1:numel(portStructs)
        ids=[ids;{portStructs(i).id}];
    end
end

function portName=lgetPortNames(out)

    portName=[];
    if(~isempty(out.Bottom))
        portName=[portName;lextractIds(out.Bottom)];
    end
    if(~isempty(out.Left))
        portName=[portName;lextractIds(out.Left)];
    end
    if(~isempty(out.Right))
        portName=[portName;lextractIds(out.Right)];
    end
    if(~isempty(out.Top))
        portName=[portName;lextractIds(out.Top)];
    end
end

function portHandles=lgetPortHandles(blkH)
    ph=get_param(blkH,'PortHandles');
    portHandles=[ph.LConn,ph.RConn];
end
