function[corrMatRatFitStr,freqs,isHerm]=...
    simrfV2corrnoise(cacheData,auxData,scale,block)

    if isfield(auxData,'Spars')&&isfield(auxData.Spars,'Frequencies')
        dataFreqs=auxData.Spars.Frequencies(:)';
    else
        dataFreqs=[];
    end

    freqs=unique([0,logspace(0,11,1101),dataFreqs]);
    freqsLen=length(freqs);


    ratmod=cacheData.RationalModel;
    Poles=ratmod.A;
    Residues=ratmod.C;
    DF=ratmod.D;
    nports=cacheData.NumPorts;

    if isempty(Poles)

        Poles(1:nports^2,1)={1+1i};
        Residues(1:nports^2,1)={0};
    end
    if isempty(DF)
        DF(1:nports^2,1)={0};
    end
    if~iscell(DF)
        DF=num2cell(DF);
    end

    DFshape=reshape(DF,nports,[]).';

    spars=zeros(nports,nports,freqsLen);
    [row_idx,col_idx]=ind2sub([nports,nports],1:nports^2);
    for idx=1:nports^2
        hRatMod=rfmodel.rational('A',Poles{idx},'C',Residues{idx},...
        'D',DFshape{idx});
        spars(row_idx(idx),col_idx(idx),:)=freqresp(hRatMod,freqs);
    end

    [corrMatRatFitStr,isHerm]=simrfV2corrnoise_freq_domain(spars,scale,...
    block);