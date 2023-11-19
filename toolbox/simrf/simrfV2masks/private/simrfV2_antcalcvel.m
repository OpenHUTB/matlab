function[normFItheta,normFIphi]=simrfV2_antcalcvel(ant,sparam,dir,showBar)

    theta=dir(1);
    phi=dir(2);
    sinTh=sin(theta);
    cosPh=cos(phi);
    sinPh=sin(phi);
    sinThCosPh=sinTh*cosPh;
    sinThSinPh=sinTh*sinPh;
    cosTh=cos(theta);
    cosThCosPh=cosTh*cosPh;
    cosThSinPh=cosTh*sinPh;
    c=rf.physconst('LightSpeed');
    mu=1.2566370621219e-6;
    eta=mu*c;
    supClasses=superclasses(ant);
    isEmStruct=any(strcmp(supClasses,'em.EmStructures'));
    if~isEmStruct
        isWrStruct=any(strcmp(supClasses,'em.WireStructures'));
        FPortFldName='Frequency';
    else

        isWrStruct=false;
        FPortFldName='PortFrequency';
    end
    freqs=unique(ant.info.(FPortFldName));
    numfreq=numel(freqs);
    showBar=showBar&&numfreq>2;
    Z=zparameters(sparam);
    Zp=Z.Parameters;
    if size(Zp,1)==1
        normFItheta=zeros(numfreq,1);
        normFIphi=zeros(numfreq,1);
    else
        normFItheta=zeros(size(Zp,1),numfreq);
        normFIphi=zeros(size(Zp,1),numfreq);
    end
    R=getRadiationSphereRadius(ant,freqs(1));
    if showBar
        msg=sprintf('Calculating solution for %d frequency points',...
        numfreq);
        if isWrStruct
            obj.hwait=waitbar(0,msg,'Name','Frequency sweep',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            hwait=obj.hwait;
        else
            hwait=waitbar(0,msg,'Name','Frequency sweep',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        end
        setappdata(hwait,'canceling',0)
    else
        hwait=[];
    end
    try
        for freqInd=1:numfreq
            omega=2*pi*freqs(freqInd);
            gamma=1j*omega/c;
            if size(Zp,1)==1
                E=EHfields(ant,freqs(freqInd),...
                [R*sinThCosPh;R*sinThSinPh;R*cosTh]);
                FV=E*R*exp(gamma*R);
                FI=FV.*Zp(1,1,freqInd);
                normFI=sqrt(4*pi/eta)*FI;
                normFItheta(freqInd)=normFI(1)*cosThCosPh+...
                normFI(2)*cosThSinPh-normFI(3)*sinTh;
                normFIphi(freqInd)=-normFI(1)*sinPh+normFI(2)*cosPh;
            else
                FI=zeros(3,size(Zp,1));
                for i=1:size(Zp,1)
                    E=EHfields(ant,freqs(freqInd),...
                    [R*sinThCosPh;R*sinThSinPh;R*cosTh],...
                    'ElementNumber',i,'Termination',1e-12);
                    FV=E*R*exp(gamma*R);
                    FI=FI+FV.*Zp(i,:,freqInd);
                end
                normFI=sqrt(4*pi/eta)*FI;
                normFItheta(:,freqInd)=normFI(1,:)*cosThCosPh+...
                normFI(2,:)*cosThSinPh-normFI(3,:)*sinTh;
                normFIphi(:,freqInd)=-normFI(1,:)*sinPh+...
                normFI(2,:)*cosPh;
            end
            if showBar

                if getappdata(hwait,'canceling')
                    break
                end
                msg=sprintf('Calculating %d/%d frequency points',...
                freqInd,numfreq);
                waitbar(freqInd/numfreq,hwait,msg);
            end
        end
    catch ME
        if showBar
            delete(hwait);
        end
        rethrow(ME)
    end
    if showBar
        delete(hwait);
    end
end
