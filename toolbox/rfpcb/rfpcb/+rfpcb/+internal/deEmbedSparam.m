function dSparams=deEmbedSparam(obj,freq,spar1)

    spar=spar1;

    W=obj.PortLineWidth;
    H=obj.Height;
    L1=obj.PortLineLength(1);
    L2=obj.PortLineLength(1);
    EpsilonR=obj.Substrate.EpsilonR(1);

    if W/H<1
        EpsilonR_eff=((EpsilonR+1)/2)+((EpsilonR-1)/2)*((1/(sqrt(1+12*(H/W))))+0.04*(1-(W/H))^2);
        Zo_Calc=(60/(sqrt(EpsilonR_eff)))*log(8*(H/W)+0.25*(W/H));%#ok<NASGU>
    else
        EpsilonR_eff=((EpsilonR+1)/2+((EpsilonR-1)/(2*sqrt(1+12*(H/W)))));
        Zo_Calc=120*pi/((sqrt(EpsilonR_eff))*(W/H+1.393+2/3*log(W/H+1.444)));%#ok<NASGU>
    end

    c=3e8;
    lambda=c./freq;
    ko=(2*pi)./lambda;
    De_emb_Mline11=-ko*sqrt(EpsilonR_eff).*(2*L1);
    De_emb_Mline21=-ko*sqrt(EpsilonR_eff).*(L1+L2);
    De_emb_Mline22=-ko*sqrt(EpsilonR_eff).*(2*L2);
    De_emb11=De_emb_Mline11';
    De_emb21=De_emb_Mline21';%#ok<NASGU>
    De_emb22=De_emb_Mline22';%#ok<NASGU>

    Sparam_De=zeros(2,2,numel(freq));
    for m=1:numel(freq)
        Sparam_De(:,:,m)=spar.Parameters(:,:,m)*exp(-1j*De_emb11(m));
    end
    dSparams=Sparam_De;
end