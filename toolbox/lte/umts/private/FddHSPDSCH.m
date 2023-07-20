































function txChips=FddHSPDSCH(chc,bitsin)
    if~isfield(chc,'PrecodingMatrixIndex')
        chc.PrecodingMatrixIndex=-1;
    end
    if~iscell(bitsin)
        bitsin={bitsin};
    end
    if~isfield(chc,'Enable2Interleaving')
        chc.Enable2Interleaving=1;
    end
    if~isfield(chc,'TimingOffset')
        chc.TimingOffset=20;
    end
    chips_P=hspdsch(bitsin{1},chc.CodeGroup,chc.CodeOffset,chc.Modulation,chc.ConstellationVersion,chc.ScramblingCode,chc.NSubframe,chc.Enable2Interleaving,chc.TimingOffset);

    if size(bitsin,2)==2
        if chc.PrecodingMatrixIndex==-1
            error('umts:error','When two transport blocks are present (i.e. MIMO Tx), w2 index must be 0...3')
        end
        chips_S=hspdsch(bitsin{2},chc.CodeGroup,chc.CodeOffset,chc.Modulation2,chc.ConstellationVersion2,chc.ScramblingCode,chc.NSubframe,chc.Enable2Interleaving,chc.TimingOffset);
        txChips=[chips_P,chips_S]*saGenWMatrix(chc.PrecodingMatrixIndex);
    else
        if chc.PrecodingMatrixIndex~=-1
            w=saGenWMatrix(chc.PrecodingMatrixIndex);
            txChips=chips_P*w(1,:);
        else
            txChips=chips_P;
        end
    end

end

function chipsout=hspdsch(bitsin,codeGroup,codeOffset,modulationScheme,constellationVersion,scramblingCode,NSubframe,Enable2Interleaving,TimingOffset)

    ndataframepcode=480*2*(FddGetModnFromString(modulationScheme)+1);
    nsubframes=ceil(numel(bitsin)/(ndataframepcode*codeGroup));


    fdata=reshape(bitsin,[ndataframepcode,numel(bitsin)/ndataframepcode]);
    if(Enable2Interleaving)
        idata=FddPhyChInterleaving(fdata,modulationScheme);
    else
        idata=fdata;
    end


    idata=reshape(idata,[size(idata,1),codeGroup,nsubframes]);
    idata=permute(idata,[1,3,2]);
    idata=reshape(idata,[numel(idata)/codeGroup,codeGroup]);


    phych=FddConstellationRearranging(idata,modulationScheme,constellationVersion);
    symbols=FddDLModulation(phych,modulationScheme)/sqrt(2);

    chipsout=FddSpreading(symbols,16*ones(1,codeGroup),codeOffset:codeOffset+codeGroup-1,1);
    if~isvector(chipsout)
        chipsout=sum(chipsout,2);
    end

    chipsout=FddScrambling(chipsout,1,scramblingCode,TimingOffset*256+(mod(NSubframe,5))*7680)/sqrt(2);

    if size(bitsin,1)<size(bitsin,2)
        chipsout=transpose(chipsout);
    end
end

