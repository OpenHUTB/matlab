














function out=FddPCCPCH(chs,data)

    if isempty(data)
        out=[];
        return
    end

    dims=FddPCCPCHDims();


    frames=reshape(data,[dims.NDataPerFrame,numel(data)/dims.NDataPerFrame]);
    idata=FddPhyChInterleaving(frames);


    phychdata=transpose(FddPCCPCHFormat(0,idata(:)));

    out=FddDLChannel(phychdata,'QPSK',dims.SF,1,chs.ScramblingCode);

    if size(data,1)<size(data,2)
        out=transpose(out);
    end

end
