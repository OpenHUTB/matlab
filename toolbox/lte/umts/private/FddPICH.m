






















function pichchips=FddPICH(config,pqin)
    if~isfield(config,'TimingOffset')
        config.TimingOffset=0;
    end
    validateUMTSParameter('TimingOffset',config);
    NDataPerFrame=288;
    if strcmpi(config.DataSource,'PagingData')

        nframes=numel(pqin)/config.Np;
        pq=reshape(repmat(transpose(pqin),NDataPerFrame/config.Np,1),NDataPerFrame,nframes);
    else


        nframes=numel(pqin)/NDataPerFrame;
        pq=reshape(pqin,NDataPerFrame,nframes);
    end

    pichbits=ones(300,nframes)*-1;

    pichbits(1:NDataPerFrame,:)=pq;

    pichchips=FddDLChannel(pichbits(:),'QPSK',256,config.SpreadingCode,config.ScramblingCode,config.TimingOffset*256);


    if size(pqin,1)<size(pqin,2)
        pichchips=transpose(pichchips);
    end
end

