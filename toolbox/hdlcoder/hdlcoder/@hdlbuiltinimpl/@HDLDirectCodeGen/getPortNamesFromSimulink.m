function[inPortNames,outPortNames]=getPortNamesFromSimulink(~,blockHandle)




    container=blockHandle;

    phan=get_param(blockHandle,'PortHandles');
    numIn=length(phan.Inport);
    numOut=length(phan.Outport);
    inPortNames=cell(1,numIn);
    outPortNames=cell(1,numOut);


    for n=1:numIn
        iport=get(get_param(phan.Inport(n),'Object'),'PortNumber');
        pstr=num2str(iport);
        lowerport=find_system(container,'SearchDepth',1,'LookUnderMasks','all',...
        'FollowLinks','on','BlockType','Inport','Port',pstr);
        if isempty(lowerport)
            inPortNames{n}=['inport',pstr];
        else
            inPortNames{n}=get_param(lowerport,'Name');
        end
    end


    for n=1:numOut
        oport=get(get_param(phan.Outport(n),'Object'),'PortNumber');
        pstr=num2str(oport);
        lowerport=find_system(container,'SearchDepth',1,'LookUnderMasks','all',...
        'FollowLinks','on','BlockType','Outport','Port',pstr);
        if isempty(lowerport)
            outPortNames{n}=['outport',pstr];
        else
            outPortNames{n}=get_param(lowerport,'Name');
        end
    end

end
