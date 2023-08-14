















function pcpichchips=FddPCPICH(chs,nframes)

    ant1=zeros(20*15*nframes,1);
    ant2=repmat([0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0],1,ceil(15*nframes/2));
    ant2=ant2(1:20*15*nframes);

    pcpichchips=FddDLChannel(ant1,'QPSK',256,0,chs.ScramblingCode);
    if isfield(chs,'TxDiversity')
        if(chs.TxDiversity)
            pcpichchips(:,2)=FddDLChannel(ant2','QPSK',256,0,chs.ScramblingCode);
        end
    end
end