function[connection]=findConnection(blockName,location)



    if~exist('location','var')
        location='nearest';
    end

    parentName=get_param(blockName,'Parent');
    sys=find_system(parentName,'SearchDepth',1,'Type','block');
    sys=setdiff(sys,blockName);
    portConnectivity=get_param(sys,'PortConnectivity');
    if~iscell(portConnectivity)
        portConnectivity={portConnectivity};
    end

    portParent={};
    portTypes={};
    portPositions=[];
    for blockIdx=1:length(portConnectivity)
        thisBlock=portConnectivity{blockIdx};
        for portIdx=1:length(thisBlock)
            thisPort=thisBlock(portIdx);
            if strncmp('LConn',thisPort.Type,5)||strncmp('RConn',thisPort.Type,5)
                portParent{end+1,1}=sys{blockIdx};%#ok<AGROW>
                portTypes{end+1,1}=thisPort.Type(1:5);%#ok<AGROW>
                portPositions(end+1,:)=thisPort.Position;%#ok<AGROW>
            end
        end
    end

    switch location
    case 'nearest'
        blockPortConnectivity=get_param(blockName,'PortConnectivity');
        blockPortPosition=blockPortConnectivity.Position;
        xy=blockPortPosition-portPositions;
        z=sqrt(xy(:,1).^2+xy(:,2).^2);
        [~,idx]=min(z);
    case 'north'
        [~,idx]=min(portPositions(:,2));
    case 'east'
        [~,idx]=max(portPositions(1,:));
    case 'south'
        [~,idx]=max(portPositions(:,2));
    case 'west'
        [~,idx]=min(portPositions(1,:));
    otherwise
        fprintf('ee.internal.assistant.utils.findConnection: %s not yet implemented\n',location);
    end
    connection.portType=portTypes{idx};
    connection.portPosition=portPositions(idx,:);
    connection.portParent=portParent{idx};
    connection.parentOrientation=get_param(connection.portParent,'Orientation');
end

