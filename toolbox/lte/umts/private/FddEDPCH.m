






























function out=FddEDPCH(chs,dcoded,ccoded)

    if isempty(dcoded)&&isempty(ccoded)
        out=[];
        return
    end
    rowvec=1;
    if~isfield(chs,'EDPDCHPower')
        chs.EDPDCHPower=-Inf;
    end
    if~isfield(chs,'EDPCCHPower')
        chs.EDPCCHPower=-Inf;
    end

    if~isequal(chs.EDPDCHPower,-Inf)


        info=FddEDPDCHInfo(chs);
        nchannels=length(chs.CodeCombination);


        bitspersymbol=1;
        if(isnumeric(chs.Modulation)&&chs.Modulation==3)||strcmpi(chs.Modulation,'4PAM')
            bitspersymbol=2;
        end
        ndatatticode=(7680*chs.TTI/2./chs.CodeCombination)*bitspersymbol;
        ntti=floor(numel(dcoded)/sum(ndatatticode));



        if~isrow(dcoded)
            rowvec=0;
            dcoded=transpose(dcoded);
        end
        segmented=mat2cell(dcoded,1,repmat(info.phyChCapacities,1,ntti));
        idata=FddPhyChInterleaving(segmented,chs.Modulation);


        idatach=cell(1,nchannels);
        for ii=1:ntti
            for jj=1:nchannels
                idatach{1,jj}(:,ii)=idata{1,(ii-1)*nchannels+jj};
            end
        end
        for jj=1:length(chs.CodeCombination)
            idatach{1,jj}=idatach{1,jj}(:);
        end


        md=FddULModulation(idatach,chs.Modulation,info.iqMap);

        sd=FddSpreading(md,chs.CodeCombination,info.SpreadingCode,1);
        sd=sum(sd,2)*db2mag(chs.EDPDCHPower)/sqrt(2);
    else
        sd=[];
    end

    if(nargin==3)&&~isempty(ccoded)&&~isequal(chs.EDPCCHPower,-Inf)


        cdmd=FddULModulation(ccoded,0,1);

        scdata=FddSpreading(cdmd,256,1)*db2mag(chs.EDPCCHPower)/sqrt(2);
        if size(sd)~=size(scdata)
            scdata=transpose(scdata);
        end
        if isempty(sd)
            sd=scdata;
        else
            sd=sd+scdata;
        end
    end

    out=FddScrambling(sd,0,chs.ScramblingCode);
    if rowvec
        out=transpose(out);
    end

end




