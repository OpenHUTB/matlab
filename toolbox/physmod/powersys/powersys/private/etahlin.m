function[H2]=etahlin(ninput,noutput,freq,sps)























































































    w=2*pi*freq;
    j=sqrt(-1);
    [nline]=size(sps.distline);
    H2=zeros(ninput,noutput);


    for iline=1:nline(1)
        nphase=sps.distline(iline,1);
        noinp=sps.distline(iline,2);
        noout=sps.distline(iline,3);
        long=sps.distline(iline,4);
        switch sps.DistributedParameterLine{iline}.WB
        case 0
            icol=5;Zmode=sps.distline(iline,icol:icol+nphase-1);
            icol=icol+nphase;Rmode=sps.distline(iline,icol:icol+nphase-1);
            icol=icol+nphase;Smode=sps.distline(iline,icol:icol+nphase-1);

            icol=icol+nphase;
            Ti=reshape(sps.distline(iline,icol:icol+nphase^2-1),nphase,nphase);
        case 1
            if freq==0
                freq=1e-6;
            end
            WBfile=sps.DistributedParameterLine{iline}.WBfile;
            DATA=power_cableparam(WBfile,'NoError');
            if isempty(DATA)

                DATA=power_lineparam(WBfile);
                if DATA.frequency~=freq
                    DATA.frequency=freq;
                    DATA=power_lineparam(DATA);
                end
            else
                if DATA.frequency~=freq
                    DATA.frequency=freq;
                    DATA=power_cableparam(DATA);
                end
            end
            [Zmode,Rmode,Smode,Ti]=blmodlin(nphase,freq,DATA.R,DATA.L,DATA.C,'');

        end


        Zimp=zeros(nphase,nphase);
        for imode=1:nphase
            Zimp(imode,imode)=Zmode(imode)+Rmode(imode)*long/4;
        end
        Y=Ti*inv(Zimp)*Ti';

        n1=nphase+1;n2=2*nphase;
        Ysr=zeros(n2,n2);
        Ysr(1:nphase,1:nphase)=Y;Ysr(n1:n2,n1:n2)=Y;
        DD=zeros(n2,n2);
        DD(1:nphase,1:nphase)=-eye(nphase,nphase);
        DD(n1:n2,n1:n2)=eye(nphase,nphase);
        TTi=zeros(n2,n2);
        TTi(1:nphase,1:nphase)=Ti;TTi(n1:n2,n1:n2)=Ti;








        Ym=zeros(1,n2);
        for imode=1:nphase
            gamal=j*w/Smode(imode)*long/2;
            A1=cosh(gamal);B1=Zmode(imode)*sinh(gamal);
            C1=1/Zmode(imode)*sinh(gamal);D1=A1;
            ML=[A1,B1;C1,D1];
            MR1=[1,Rmode(imode)*long/4;0,1];
            MR2=[1,Rmode(imode)*long/2;0,1];
            M=MR1*ML*MR2*ML*MR1;
            Ym(imode,imode)=M(1,1)/M(1,2);
            Ym(imode+nphase,imode+nphase)=-M(1,1)/M(1,2);
            Ym(imode,imode+nphase)=-1/M(1,2);
            Ym(imode+nphase,imode)=+1/M(1,2);
        end










        if sps.DistributedParameterLine{iline}.WB==1
            Ysr(1:nphase,1:nphase)=sps.DistributedParameterLine{iline}.WBG;
            Ysr(nphase+1:2*nphase,nphase+1:2*nphase)=sps.DistributedParameterLine{iline}.WBG;
        end
        if any(any(isnan(DD*TTi*Ym*TTi)))
            H2(noinp:noinp+2*nphase-1,noout:noout+2*nphase-1)=Ysr;
        else
            H2(noinp:noinp+2*nphase-1,noout:noout+2*nphase-1)=Ysr+DD*TTi*Ym*TTi';
        end
    end