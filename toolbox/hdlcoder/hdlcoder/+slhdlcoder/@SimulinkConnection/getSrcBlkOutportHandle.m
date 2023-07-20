function hSrcBlkPort=getSrcBlkOutportHandle(~,hSubsystem,n)



    pconn=get_param(hSubsystem,'portConnectivity');

    srcBlock=pconn(n).SrcBlock;
    srcPort=pconn(n).SrcPort;

    if isempty(srcBlock)||srcBlock==-1
        error('hdlcoder:engine:badSrcBlock',MSLDiagnostic(message('hdlcoder:engine:badSrcBlock',n,get_param(hSubsystem,'Name'))).message);
    end
    sbphan=get_param(srcBlock,'portHandles');
    hSrcBlkPort=sbphan.Outport(srcPort+1);


    if isempty(hSrcBlkPort)
        error('hdlcoder:engine:badSrcBlock',MSLDiagnostic(message('hdlcoder:engine:badSrcBlock',n,get_param(hSubsystem,'Name'))).message);
    end
