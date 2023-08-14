function BlkConn=autoblksgetblockconn(BlkHdl)








































    PortHdls=get_param(BlkHdl,'PortHandles');
    BlkConn.Inports=GetPortStruct(BlkHdl,PortHdls,'Inport');
    BlkConn.Outports=GetPortStruct(BlkHdl,PortHdls,'Outport');
    BlkConn.LConns=GetPortStruct(BlkHdl,PortHdls,'LConn');
    BlkConn.RConns=GetPortStruct(BlkHdl,PortHdls,'RConn');

end


function PortStruct=GetPortStruct(BlkHdl,PortHdls,PortType)

    NumPorts=length(PortHdls.(PortType));
    InitCell=cell(NumPorts,1);
    PortNames=autoblksgetblkportnames(BlkHdl,PortHdls,PortType);
    PortNames=PortNames(:);

    PortStruct=struct('Name',PortNames,'ConnBlkHdl',InitCell,'ConnBlkName',InitCell,'ConnPortHdl',InitCell,'LineHdl',InitCell,'LinePoints',InitCell,'isConnPort',InitCell);
    switch PortType
    case 'Inport'
        ConnType='Src';
        OtherConnType='Dst';
        BlkPortType='Inport';
    case 'Outport'
        ConnType='Dst';
        OtherConnType='Src';
        BlkPortType='Outport';
    case 'LConn'
        ConnType='Src';
        OtherConnType='Dst';
        BlkPortType='PMIOPort';
    case 'RConn'
        ConnType='Dst';
        OtherConnType='Src';
        BlkPortType='PMIOPort';
    end

    for i=1:NumPorts
        PortStruct(i).LineHdl=get_param(PortHdls.(PortType)(i),'Line');

        if PortStruct(i).LineHdl~=-1

            PortStruct(i).ConnBlkHdl=get_param(PortStruct(i).LineHdl,[ConnType,'BlockHandle']);
            if PortStruct(i).ConnBlkHdl==BlkHdl;
                PortStruct(i).ConnBlkHdl=get_param(PortStruct(i).LineHdl,[OtherConnType,'BlockHandle']);
                ConnType=OtherConnType;
            end
            PortStruct(i).LinePoints=get_param(PortStruct(i).LineHdl,'Points');

            if PortStruct(i).ConnBlkHdl~=-1
                PortStruct(i).ConnPortHdl=get_param(PortStruct(i).LineHdl,[ConnType,'PortHandle']);
                PortStruct(i).ConnBlkName=get_param(PortStruct(i).ConnBlkHdl,'Name');
                if strcmp(get_param(PortStruct(i).ConnBlkHdl,'BlockType'),BlkPortType)

                    PortStruct(i).isConnPort=true;
                else
                    PortStruct(i).isConnPort=false;
                end
            else
                PortStruct(i).ConnPortHdl=-1;
                PortStruct(i).isConnPort=false;
                PortStruct(i).ConnBlkName='';
            end

        else
            PortStruct(i).ConnBlkHdl=-1;
            PortStruct(i).ConnPortHdl=-1;
            PortStruct(i).isConnPort=false;
            PortStruct(i).ConnBlkName='';
        end
    end

end
