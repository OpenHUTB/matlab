function outportHandles=getOutportHandles(this)




    dutName=this.System;


    hSubsystem=get_param(dutName,'handle');



    oph=find_system(hSubsystem,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Outport');


    outportHandleArray=zeros(1,length(oph));

    for ii=1:length(oph)
        pconn=get_param(oph(ii),'PortConnectivity');

        srcBlock=pconn(1).SrcBlock;
        srcPort=pconn(1).SrcPort;

        if isempty(srcBlock)||srcBlock==-1
            MSLException(message('TLMGenerator:SimulinkConnection:BadSrcBlk',ii,get_param(hSubsystem,'Name'))).throw();
        end
        sbphan=get_param(srcBlock,'PortHandles');

        hSrcBlkPort=sbphan.Outport(srcPort+1);

        if isempty(hSrcBlkPort)
            error(message('TLMGenerator:SimulinkConnection:BadSrcBlk',ii,get_param(hSubsystem,'Name')));
        end
        outportHandleArray(ii)=hSrcBlkPort;
    end

    outportHandles=outportHandleArray;

end








