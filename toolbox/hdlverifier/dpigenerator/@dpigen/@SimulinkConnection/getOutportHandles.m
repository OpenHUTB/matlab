function outportHandles=getOutportHandles(this)




    dutName=this.System;


    hSubsystem=get_param(dutName,'handle');


    if get_param(bdroot(hSubsystem),'handle')~=get_param(hSubsystem,'handle')&&strcmp(get_param(hSubsystem,'Variant'),'on')


        oph=find_system(hSubsystem,...
        'SearchDepth',1,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'BlockType','Outport');

        pconn=get_param(oph(1),'PortConnectivity');
        srcBlock=pconn(1).SrcBlock;
        hSubsystem=get_param(srcBlock,'handle');
    end




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




        if srcBlock~=-1&&~strcmpi(get_param(srcBlock,'Commented'),'off')
            error(message('HDLLink:SimulinkConnection:SrcBlockFromPortIsCommented',get_param(srcBlock,'Name')));
        end

        if isempty(srcBlock)||srcBlock==-1
            error(message('HDLLink:SimulinkConnection:BadSrcBlk',ii,get_param(hSubsystem,'Name')));
        end
        sbphan=get_param(srcBlock,'PortHandles');

        hSrcBlkPort=sbphan.Outport(srcPort+1);

        if isempty(hSrcBlkPort)
            error(message('HDLLink:SimulinkConnection:BadSrcBlk',ii,get_param(hSubsystem,'Name')));
        end
        outportHandleArray(ii)=hSrcBlkPort;
    end

    outportHandles=outportHandleArray;

end








