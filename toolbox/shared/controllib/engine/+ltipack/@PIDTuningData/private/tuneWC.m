function[zC,pC,kC,zC2,pC2,kC2,PM,wc,Gdata]=tuneWC(Gdata0,PMreq,wcTarget,MaxPhaseLead,TuningFcn,get2DOF)



















    wc=wcTarget;
    Gdata=getLoopCharacteristics(Gdata0,wc);
    [zC,pC,kC,zC2,pC2,kC2,PM,Fmin]=TuningFcn(Gdata,wc,PMreq,get2DOF);


    if Fmin>0.1

        w=Gdata.Frequency;
        ph=Gdata.Phase;
        mu0=Gdata.mu0;
        phaseMin=(2*mu0-1)*pi+PMreq-MaxPhaseLead;
        phaseMax=(2*mu0+1)*pi-PMreq;
        idx=find(ph>=phaseMin&ph<=phaseMax);
        if isempty(idx)


            wcmin=min(10*wcTarget,sqrt(wcTarget*w(end)));
            wcmax=min(1e3*wcTarget,0.999*w(end));
        else

            wcmin=w(idx(1));
            wcmax=w(idx(find([diff(idx);Inf]>1,1)));
            if wcTarget<wcmin
                wcmax=min(wcmax,100*wcmin);
            elseif wcTarget>wcmax
                wcmin=max(wcmin,wcmax/100);
            else
                wcmin=max(wcmin,wcTarget/100);
                wcmax=min(wcmax,100*wcTarget);
            end
        end
        wcmax=min(wcmax,0.5*pi/Gdata0.Ts);

        wcGrid=logspace(log10(wcmin),log10(wcmax),1+round(5*log10(wcmax/wcmin)))';
        npts=length(wcGrid);
        Designs=struct('z',cell(npts,1),'p',[],'k',[],'PM',[],'F',[]);
        for j=1:npts
            [Designs(j).z,Designs(j).p,Designs(j).k,Designs(j).z2,Designs(j).p2,Designs(j).k2,Designs(j).PM,Designs(j).F]=...
            TuningFcn(getLoopCharacteristics(Gdata0,wcGrid(j)),wcGrid(j),PMreq,get2DOF);
        end
        F=[Designs.F];

        Fopt=min(F);
        if Fopt<Fmin/1.1


            iok=find(F<=max(0.1,1.1*Fopt));
            [~,imin]=min(abs(log(wcGrid(iok)/wcTarget)));
            isel=iok(imin);
            wc=wcGrid(isel);
            OptDes=Designs(isel);
            zC=OptDes.z;pC=OptDes.p;kC=OptDes.k;PM=OptDes.PM;
            zC2=OptDes.z2;pC2=OptDes.p2;kC2=OptDes.k2;

            Gdata=getLoopCharacteristics(Gdata0,wc);
        end

    end

