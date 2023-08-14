

















function out=FddSCCPCH(chs,data,tfci)

    if isempty(data)
        out=[];
        return
    end
    if~isfield(chs,'TimingOffset')
        chs.TimingOffset=0;
    end
    validateUMTSParameter('TimingOffset',chs);

    dims=FddSCCPCHDims(chs.SlotFormat);


    ndataframecode=dims.NDataPerFrame;
    frames=reshape(data,[ndataframecode,numel(data)/ndataframecode]);
    idata=FddPhyChInterleaving(frames);


    phychdata=transpose(FddSCCPCHFormat(chs.SlotFormat,idata(:),tfci));

    out=FddDLChannel(phychdata,'QPSK',dims.SF,chs.SpreadingCode,chs.ScramblingCode,chs.TimingOffset*256);

    if size(data,1)<size(data,2)
        out=transpose(out);
    end

end

