classdef(Hidden=true)PIDTuningData


























    properties
Frequency
Magnitude
Phase
Ts
ioDelay
LoopSign
Integral
TargetBW
mu0
ph0
        ZPK=[];
muInfo
Requirements
DesignFocus

    end
    properties(SetAccess=private)
DOF
        fixedBC=[1,1];
    end

    methods

        function DS=PIDTuningData(Gdata,C,Options)



            if strcmp(Options.DesignFocus,'balanced')
                DS.DesignFocus=1;
            elseif strcmp(Options.DesignFocus,'reference-tracking')
                DS.DesignFocus=2;
            elseif strcmp(Options.DesignFocus,'disturbance-rejection')
                DS.DesignFocus=3;
            else
                error(message('Control:design:pidtune12'));
            end

            try
                Gdata=getPIDPlantData(Gdata);
            catch ME
                throw(ME)
            end


            Ts=Gdata.Ts;
            DS.Ts=Ts;
            Type=lower(getType(C));
            if strcmp(Type(end),'2')
                Type=Type(1:end-1);
                DS.DOF=2;
                DS.fixedBC=[C.b,C.c];
            else
                DS.DOF=1;
            end
            if isa(C,'pidstd')
                Form='S';
            else
                Form='P';
            end
            if Ts==0
                IFormula=[];
                DFormula=[];
            else
                IFormula=C.IFormula(1);
                DFormula=C.DFormula(1);
            end




            if Ts>0&&DFormula=='T'&&any(strcmp(Type,{'pd','pid'}))
                if isa(C,'pid')
                    C.Kd=0;
                else
                    C.Td=0;
                end

                Type=Type(1:end-1);
            end


            IntFlag=any(Type=='i');
            DS.Integral=IntFlag;


            iod=Gdata.Delay.Input+Gdata.Delay.Output+Gdata.Delay.IO;
            if Ts>0
                DS.ioDelay=Ts*iod;
            else
                DS.ioDelay=iod;
            end



            [zAug,pAug]=augmentZPK(Ts,Type,IFormula,DFormula);


            ZPKFlag=isa(Gdata,'ltipack.zpkdata');
            if ZPKFlag



                z=[Gdata.z{1};zAug];
                p=[Gdata.p{1};pAug];
                k=Gdata.k;%#ok<*PROP>
                DS.ZPK=struct('z',z,'p',p,'k',k);

                w=freqgrid({z},{p},Ts,1);
                w=w(w>0);
                mag=magphaseresp(DS,w);
                DS.Frequency=w;



                if Ts==0
                    minf=length(p)-length(z);
                else
                    minf=sum(z==-1)-sum(p==-1);
                end
                DS.muInfo=struct('Pns',NaN,'m0',NaN,'minf',minf);
            else


                [mag,ph,w,m0]=localFRDMagPhase(Gdata.Response,Gdata.Frequency,Ts,...
                DS.ioDelay,zAug,pAug);
                DS.Frequency=w;
                DS.Magnitude=mag;

                Pns=Options.NumUnstablePoles;
                r=Pns+round(ph(1)/pi-m0/2);
                if rem(r,2)==0
                    DS.LoopSign=1;
                else

                    DS.LoopSign=-1;
                    ph=ph+pi;r=r+1;
                end
                DS.mu0=r/2;
                DS.ph0=ph(1);
                DS.Phase=ph;

                minf=NaN;
                DS.muInfo=struct('Pns',Pns,'m0',m0,'minf',minf);
            end


            TargetBW=getPlantNatFreq(w,mag,Ts);
            if DS.ioDelay>0
                TargetBW=min(TargetBW,pi/max(DS.ioDelay));
            end
            DS.TargetBW=TargetBW;




            Reqs=struct('Type',Type,'Form',Form,'IFormula',IFormula,'DFormula',DFormula,...
            'InitFcn',@getTuningParams,'ConstraintFcn',[],'zAug',zAug,'pAug',pAug);
            if strcmp(Form,'S')&&(strcmp(Type,'pidf')||(Ts>0&&strcmp(Type,'pid')))
                Reqs.ConstraintFcn=@checkValidPIDSTD;
            end
            DS.Requirements=Reqs;
        end


        function DS=getLoopCharacteristics(DS,wc)

            Ts=DS.Ts;
            w0=DS.Frequency;


            wx=(wc*logspace(-2,2,75)).';
            if Ts>0
                wx=wx(wx<=pi/Ts);
            end


            if isempty(DS.ZPK)

                w=unique([w0;wx(wx>w0(1)&wx<=w0(end))]);
                [DS.Magnitude,DS.Phase]=magphaseresp(DS,w);
                DS.Frequency=w;
            else

                z=DS.ZPK.z;p=DS.ZPK.p;k=DS.ZPK.k;






                wZero=1e-3*wc;




                if Ts==0

                    z(abs(z)<wZero)=0;
                    p(abs(p)<wZero)=0;


                    rp=real(p);
                    idx=find(rp>0&rp<1e-6*abs(p));
                    p(idx)=-conj(p(idx));

                    Pns=sum(real(p)>0);

                    m0=sum(z==0)-sum(p==0);
                else

                    z(abs(z-1)<wZero*Ts)=1;
                    p(abs(p-1)<wZero*Ts)=1;

                    rho=abs(p);
                    idx=find(rho>1&log(rho)<1e-6*abs(angle(p)));
                    p(idx)=p(idx)./rho(idx).^2;

                    Type=DS.Requirements.Type;
                    reldeg=length(z)-length(p)+...
                    any(strcmp(Type,{'pi','pd','pidf'}))+2*strcmp(Type,'pid');
                    Pns=sum(abs(p)>1)+max(0,reldeg);

                    m0=sum(z==1)-sum(p==1);
                end
                DS.ZPK.z=z;
                DS.ZPK.p=p;
                DS.muInfo.Pns=Pns;
                DS.muInfo.m0=m0;





                w=unique([0;wZero;w0(w0>wZero);wx(wx>wZero)]);
                nw=numel(w);
                [mag,ph]=magphaseresp(DS,w);
                DS.Frequency=w(2:nw);
                DS.Magnitude=mag(2:nw);
                DS.Phase=ph(2:nw);
                ph0=ph(1);




                r=Pns+round(ph0/pi-m0/2);
                if rem(r,2)==0
                    DS.LoopSign=1;
                else

                    DS.LoopSign=-1;
                    dph=sign(k)*pi;
                    DS.Phase=DS.Phase+dph;ph0=ph0+dph;
                    k=-k;
                    r=Pns+round(ph0/pi-m0/2);
                end
                DS.mu0=r/2;
                DS.ph0=ph0;
                DS.ZPK.k=k;
            end
        end


        function[mag,ph]=magphaseresp(DS,w)


            zpkData=DS.ZPK;
            if isempty(zpkData)

                wG=DS.Frequency;
                w(w<wG(1))=wG(1);
                w(w>wG(end))=wG(end);
                mag=pow2(utInterp1(log2(wG),log2(DS.Magnitude),log2(w)));
                ph=utInterp1(wG,DS.Phase,w);
            else

                [mag,ph]=zpkboderesp(zpkData.z,zpkData.p,zpkData.k,DS.Ts,w,true);
                if DS.ioDelay>0
                    ph=ph-w*DS.ioDelay;
                end
            end
            mag(~isfinite(mag))=Inf;
        end


        function[isStable,PM,F,NeedsInteg]=checkCL(DS,zC,pC,kC,wc)



            Ts=DS.Ts;
            w=DS.Frequency;magG=DS.Magnitude;phG=DS.Phase;
            muInfo=DS.muInfo;

            wZero=w(1);


            if Ts==0
                m0=muInfo.m0+(sum(abs(zC)<wZero)-sum(abs(pC)<wZero));
                minf=muInfo.minf+(length(pC)-length(zC));
                sgnInf=-1;
            else
                m0=muInfo.m0+(sum(abs(zC-1)<wZero*Ts)-sum(abs(pC-1)<wZero*Ts));
                minf=muInfo.minf+(sum(zC==-1)-sum(pC==-1));
                sgnInf=1;
            end
            [magC,phC]=zpkboderesp(zC,pC,kC,Ts,[0;w],true);
            magOL=magG.*magC(2:end);phOL=phG+phC(2:end);


            r=muInfo.Pns;
            if(m0<0)||(m0==0&&magOL(1)>1)
                r=r+round((DS.ph0+phC(1))/pi-m0/2);
            end
            if magOL(end)>1

                r=r-round(phOL(end)/pi-sgnInf*minf/2);
            end


            inBW=(magOL>=1);
            idxc=find(xor(inBW(1:end-1),inBW(2:end)));
            if isempty(idxc)

                muS=0;wphWC=zeros(0,1);
                NeedsInteg=false;
            else
                t=-log(magOL(idxc))./log(magOL(idxc+1)./magOL(idxc));

                phWC=(1-t).*phOL(idxc)+t.*phOL(idxc+1);
                wphWC=mod(phWC+pi,2*pi)-pi;
                muWC=round((phWC-wphWC)/pi);
                if magOL(1)<1
                    muS=sum(muWC(2:2:end))-sum(muWC(1:2:end));
                else
                    muS=sum(muWC(1:2:end))-sum(muWC(2:2:end));
                end

                NeedsInteg=(magOL(1)<1||magOL(end)>1);
            end
            isStable=(muS==r);
            if isStable
                PM=min([Inf;pi-abs(wphWC)]);

                if nargout>2
                    nu=w/wc;
                    Smag=1./sqrt(1+magOL.^2+2*magOL.*cos(phOL));
                    Tmag=magOL.*Smag;
                    STmag=sqrt(1+magOL.^2-2*magOL.*cos(phOL)).*Smag;
                    F=(max(getF(1,1,PM,nu,magOL,Tmag,STmag,0,inf,PM,[],[],[]))-1)/10;
                end
            else
                PM=NaN;F=Inf;
            end
        end

        function[PID,info]=tune(DS0,Options,ReturnPID,fixBC)















            if nargin<=2
                ReturnPID=true;
            end
            if nargin<=3
                fixBC=false;
            end
            if DS0.DOF==1
                [PID,info]=tune_(DS0,Options,ReturnPID,false);
            else
                if fixBC
                    b=DS0.fixedBC(1);c=DS0.fixedBC(2);
                    [PID,info]=tune_(DS0,Options,ReturnPID,false);
                    PID=make2DOF(PID,b,c);
                else
                    [PID,info]=tune_(DS0,Options,ReturnPID,true);
                end
            end
        end

        function[PID,info]=tune_(DS0,Options,ReturnPID,tune2DOF)


            RAD2DEG=180/pi;
            PM=Options.PhaseMargin/RAD2DEG;
            wc=Options.CrossoverFrequency;
            DesignReqs=DS0.Requirements;
            Ts=DS0.Ts;


            if any(strcmp(DesignReqs.Type,{'p','i'}))


                zC=zeros(0,1);pC=zeros(0,1);
                [kC,~,wc,DS]=tuneGain(DS0,PM,wc);
                zC2=zC;pC2=pC;kC2=kC;
            else


                DEG89=1.553;
                DTBOOST=0.785;
                switch DesignReqs.Type
                case 'pi'
                    TuningFcn=@tuneZ;
                    MAXLEAD=DEG89;
                case 'pd'
                    TuningFcn=@tuneZ;
                    MAXLEAD=DEG89+(Ts>0)*DTBOOST;
                case 'pdf'
                    TuningFcn=@tuneZP;
                    MAXLEAD=DEG89;
                case 'pid'
                    TuningFcn=@tuneZ2;
                    MAXLEAD=2*DEG89+(Ts>0)*DTBOOST;
                case 'pidf'
                    TuningFcn=@tuneZ2P;
                    MAXLEAD=2*DEG89;
                end


                if isempty(wc)





                    [zC,pC,kC,zC2,pC2,kC2,~,wc,DS]=tuneWC(DS0,PM,DS0.TargetBW,MAXLEAD,TuningFcn,tune2DOF);

                else





                    DS=getLoopCharacteristics(DS0,wc);
                    [zC,pC,kC,zC2,pC2,kC2]=TuningFcn(DS,wc,PM,tune2DOF);

                end
            end


            if tune2DOF
                [Z1,P1,K1,info]=getZPKController(DesignReqs,DS,zC,pC,kC,wc,Ts);
                [Z2,P2,K2,~]=getZPKController(DesignReqs,DS,zC2,pC2,kC2,wc,Ts);
                PID=ltipack.zpkdata({Z2,Z1},{P2,P1},[K2,-K1],Ts);
                switch DesignReqs.Form
                case 'P'
                    outobjtype=@pid2;
                case 'S'
                    outobjtype=@pidstd2;
                end
            else
                [Z,P,K,info]=getZPKController(DesignReqs,DS,zC,pC,kC,wc,Ts);
                PID=ltipack.zpkdata({Z},{P},K,Ts);
                switch DesignReqs.Form
                case 'P'
                    outobjtype=@pid;
                case 'S'
                    outobjtype=@pidstd;
                end
            end

            if ReturnPID
                if Ts==0
                    PID=outobjtype(PID);
                else
                    PID=outobjtype(PID,DesignReqs);
                end

                if strcmp(DesignReqs.Form,'P')&&strcmp(DesignReqs.Type,'i')
                    PID.Kp=0;
                end
            end
        end
    end

end




function[Z,P,K,info]=getZPKController(DesignReqs,DS,zC,pC,kC,wc,Ts)
    RAD2DEG=180/pi;

    [isStable,PM,F,NI]=checkCL(DS,zC,pC,kC,wc);
    info=struct('Stable',isStable,'wc',wc,'PM',RAD2DEG*PM,'F',F,...
    'NeedsIntegrator',NI);


    pAug=DesignReqs.pAug;
    if Ts>0

        idxP=find(pAug==0|pAug==-1);
        if~isempty(idxP)
            idxZ=find(abs(zC-pAug(idxP))<1e3*eps,1);
            if~isempty(idxZ)
                zC(idxZ,:)=[];
                pAug(idxP,:)=[];
            end
        end
    end
    Z=[zC;DesignReqs.zAug];
    P=[pC;pAug];
    K=DS.LoopSign*kC;
end

function wc=getPlantNatFreq(w,mag,Ts)


    if Ts>0
        WMIN=1e-6*pi/Ts;WMAX=.1*pi/Ts;
    else
        WMIN=1e-6;WMAX=Inf;
    end
    nw=length(w);


    idx1=min([find(w>WMIN,1),floor(nw/2)]);
    w1=w(idx1);
    idx2=max([find(w>10*w1,1),idx1+1]);
    logmag=log(mag);
    s0=round((logmag(idx2)-logmag(idx1))/(log(w(idx2)/w1)));





    xlm=logmag(idx1)+s0*log(w/w1);
    idx=find(w>w1&w<WMAX&abs(logmag-xlm)>0.7,1);
    if isempty(idx)
        wRange=w(find(w>0,1)).^[.9,.1].*w(nw).^[.1,.9];
        wc=1;
        if Ts>0
            wc=min(wc,.1*pi/Ts);
        end
        wc=min(max(wRange(1),wc),wRange(2));
    else
        wc=w(idx);
    end

end


function[mag,ph,w,m0]=localFRDMagPhase(h,w,Ts,ioDelay,zAug,pAug)

    if Ts==0
        inRange=(w>0&w<Inf);
    else
        inRange=(w>0&w<=pi/Ts);
    end
    w=w(inRange);
    h=reshape(h(inRange),[length(w),1]);
    mag=abs(h);
    ph=unwrap(angle(h));


    if ioDelay>0
        ph=ph-w*ioDelay;
    end



    [magAug,phAug]=zpkboderesp(zAug,pAug,1,Ts,w,true);
    mag=mag.*magAug;
    ph=ph+phAug;


    m0=round(log(mag(2)/mag(1))/log(w(2)/w(1)));


    offset=(2*pi)*round((ph(1)-m0*pi/2)/(2*pi));
    ph=ph-offset;

end

