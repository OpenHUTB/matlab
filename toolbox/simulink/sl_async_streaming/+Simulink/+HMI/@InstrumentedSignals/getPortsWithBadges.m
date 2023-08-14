function ports=getPortsWithBadges(this,~)




    ports=[];
    len=this.Count;
    for idx=1:len
        try
            sig=get(this,idx);
            bpath=getAlignedBlockPath(sig);
            ph=get_param(bpath,'PortHandles');
            hPort=ph.Outport(sig.OutputPortIndex);
        catch me %#ok<NASGU>
            continue
        end
        ports(end+1)=hPort;%#ok<AGROW>
    end
    ports=unique(ports,'rows');
end
