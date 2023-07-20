
















function scpichchips=FddSCPICH(chs,nframes)

    ant1=zeros(20*15*nframes,1);
    ant2=repmat([0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0],1,ceil(15*nframes/2));
    ant2=ant2(1:20*15*nframes);

    scpichchips=FddDLChannel(ant1,'QPSK',256,chs.SpreadingCode,chs.ScramblingCode);
    if isfield(chs,'TxDiversity')
        if(chs.TxDiversity)
            scpichchips(:,2)=FddDLChannel(ant2','QPSK',256,chs.SpreadingCode,chs.ScramblingCode);
        end
    end
end

