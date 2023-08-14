function[kC,PMopt,wc,Gdata]=tuneGain(Gdata,PMreq,wc)












    TargetBW=Gdata.TargetBW;

    if isempty(wc)
        Gdata=getLoopCharacteristics(Gdata,TargetBW);
    else
        Gdata=getLoopCharacteristics(Gdata,wc);
    end
    mu0=Gdata.mu0;
    wG=Gdata.Frequency;
    magG=Gdata.Magnitude;
    phG=Gdata.Phase;



    if isempty(wc)
        TargetPhase=(2*mu0-1)*pi+PMreq;
        ph=phG-TargetPhase;
        idxc=find(sign(ph(1:end-1))~=sign(ph(2:end)));
        t=-ph(idxc)./(ph(idxc+1)-ph(idxc));
        w=wG(idxc).^(1-t).*wG(idxc+1).^t;

        [dTargetBW,is]=sort(abs(log10(w/TargetBW)));
        for ct=1:length(w)
            if dTargetBW(ct)<2
                wc0=w(is(ct));
                [mag0,ph0]=magphaseresp(Gdata,wc0);
                PM=checkOL(wG,magG/mag0,phG,wc0,ph0,mu0);
                if PM>.99*PMreq
                    wc=wc0;break
                end
            end
        end
    end


    if isempty(wc)
        logBW=log10(TargetBW);
        w=logspace(logBW-2,logBW+2,21);
        [~,is]=sort(abs(log10(w/TargetBW)));
        w=w(is);
        nw=length(w);
        PMs=zeros(1,nw);
        for ct=1:nw
            wc0=w(ct);
            [mag0,ph0]=magphaseresp(Gdata,wc0);
            PMs(ct)=checkOL(wG,magG/mag0,phG,wc0,ph0,mu0);
        end
        maxPM=min(max(PMs),PMreq);


        wc=w(find(PMs>=maxPM,1));
    end


    [mag_wc,ph_wc]=magphaseresp(Gdata,wc);
    if mag_wc==0||isinf(mag_wc)
        kC=1;PMopt=0;
    else
        kC=1/mag_wc;
        PMopt=checkOL(wG,kC*magG,phG,wc,ph_wc,mu0);
    end

