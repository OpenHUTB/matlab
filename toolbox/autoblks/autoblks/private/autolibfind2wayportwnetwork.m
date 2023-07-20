function PortNetwork=autolibfind2wayportwnetwork(NetworkBlks,PortHdls,InternalPortConnHdls)












    if isempty(NetworkBlks)||isempty(PortHdls)
        PortNetwork.Blks=[];
        PortNetwork.BlkPorts=[];
        PortNetwork.AllPorts=[];
        return;
    end

    AvailPortHdls=cell2mat(PortHdls)';
    AvailPortHdls=AvailPortHdls(:);
    InternalPortConnMap=containers.Map(num2cell(AvailPortHdls),cell(size(AvailPortHdls)));

    for i=1:length(InternalPortConnHdls)
        if~isempty(InternalPortConnHdls{i})
            for j=1:length(InternalPortConnHdls{i})
                InternalPortConnMap(InternalPortConnHdls{i}(j))=InternalPortConnHdls{i}([1:(j-1),(j+1):end]);
            end
        end
    end

    Port2BlkMap=containers.Map(num2cell(AvailPortHdls),num2cell(AvailPortHdls));
    for i=1:length(NetworkBlks)
        for j=1:length(PortHdls{i})
            Port2BlkMap(PortHdls{i}(j))=NetworkBlks(i);
        end
    end


    ConnCheckObj=autoblks.pwr.autoblksCheckSysPortConn;
    PortsNotMatched=AvailPortHdls;
    idx=1;
    ConnectedPorts={};
    while~isempty(PortsNotMatched)
        if length(PortsNotMatched)>1
            StartPort=PortsNotMatched(1);
            [ConnPorts,PortsNotMatched,ConnCheckObj]=findConnectedPorts(StartPort,PortsNotMatched(2:end),InternalPortConnMap,NetworkBlks,ConnCheckObj);
            ConnectedPorts{idx}=[StartPort;ConnPorts];
        else
            ConnectedPorts{idx}=PortsNotMatched(1);
            PortsNotMatched=[];
        end
        idx=idx+1;
    end


    for i=1:length(ConnectedPorts)
        AllBlks=zeros(size(ConnectedPorts{i}));
        for j=1:length(ConnectedPorts{i})
            AllBlks(j)=Port2BlkMap(ConnectedPorts{i}(j));
        end
        [PortNetwork(i).Blks,~,IC]=unique(AllBlks,'stable');
        PortNetwork(i).BlkPorts=cell(size(PortNetwork(i).Blks));
        PortNetwork(i).AllPorts=ConnectedPorts{i};
        for j=1:length(IC)
            PortNetwork(i).BlkPorts{IC(j)}=[PortNetwork(i).BlkPorts{IC(j)},ConnectedPorts{i}(j)];
        end
    end

end


function[ConnPorts,NotConnPorts,ConnCheckObj]=findConnectedPorts(StartPort,OtherPorts,InternalPortConnMap,NetworkBlks,ConnCheckObj)
    if~isempty(OtherPorts)

        ConnFlags=ConnCheckObj.isPortConnected(StartPort,OtherPorts,{},{},{},NetworkBlks);


        InternalConns=InternalPortConnMap(StartPort);
        for i=1:length(InternalConns)
            ConnFlags(OtherPorts==InternalConns(i))=true;
        end


        ConnPorts=OtherPorts(ConnFlags);
        NotConnPorts=OtherPorts(~ConnFlags);
        NumConnPorts=length(ConnPorts);


        for i=1:NumConnPorts
            [NewConnPorts,~,ConnCheckObj]=findConnectedPorts(ConnPorts(i),NotConnPorts,InternalPortConnMap,NetworkBlks,ConnCheckObj);
            ConnPorts=[ConnPorts;NewConnPorts];
        end


        NotConnPorts=setxor(OtherPorts,ConnPorts,'stable');
    else
        ConnPorts=[];
        NotConnPorts=[];
    end

end