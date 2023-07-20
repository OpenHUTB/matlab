function srcPortHandle=returnSourceBlockOutportHandle(blkPortHdl)

    portType=get_param(blkPortHdl,'PortType');

    if(strcmpi(portType,'outport'))
        srcPortHandle=blkPortHdl;
        return;
    end


    lh=get_param(blkPortHdl,'Line');
    if~isempty(lh)&&lh~=-1
        srcPortHandle=get_param(lh,'srcporthandle');
    else

        srcPortHandle=-1;
    end

end

