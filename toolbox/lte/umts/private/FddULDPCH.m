






























function out=FddULDPCH(chs,data,tfci,tpc,fbi)

    if isempty(data)
        out=data;
        return
    end

    validateUMTSParameter('CodeCombination',chs.CodeCombination);
    SF=chs.CodeCombination(1);
    nchannels=length(chs.CodeCombination);
    if nchannels>1&&any(chs.CodeCombination~=4)
        error('umts:error','For multiple DPDCHs, the CodeCombination cannot have any value other than 4');
    end
    if~isfield(chs,'DPDCHPower')
        chs.DPDCHPower=-Inf;
    end


    ndataframecode=38400/SF;
    nframes=floor(numel(data)/(ndataframecode*nchannels));
    out=zeros(nframes*38400,1);
    if~isequal(chs.DPDCHPower,-Inf)
        frames=reshape(data(1:ndataframecode*nframes*nchannels),[ndataframecode,nframes*nchannels]);
        idata=FddPhyChInterleaving(frames);


        idata=reshape(idata,[size(idata,1),nchannels,nframes]);
        idata=permute(idata,[1,3,2]);
        idata=reshape(idata,[numel(idata)/nchannels,nchannels]);


        md=FddULModulation(idata,0,[1,1i,1,1i,1,1i]);

        if(SF==4)
            codes=[1,1,3,3,2,2];
            codes=codes(1:nchannels);
        else

            codes=(SF/4);
        end
        sd=FddSpreading(md,SF*ones(1,nchannels),codes);
        out=out+sum(sd,2)*db2mag(chs.DPDCHPower)/sqrt(2);
    end

    if~isfield(chs,'DPCCHPower')
        chs.DPCCHPower=-Inf;
    end
    if~isequal(chs.DPCCHPower,-Inf)
        [cdata,cdims]=FddULDPCCHFormat(chs.SlotFormat,nframes*15,tpc,tfci,fbi);


        cmd=FddULModulation(cdata,0,1i);

        scdata=FddSpreading(cmd,cdims.SF,0);
        out=out+transpose(scdata)*db2mag(chs.DPCCHPower)/sqrt(2);
    end


    out=FddScrambling(out,0,chs.ScramblingCode);

    if size(data,1)<size(data,2)
        out=transpose(out);
    end

end





