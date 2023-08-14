function sps=etass(sps,X0Sw)











































































    if~exist('X0Sw','var')
        X0Sw=[];
    end


    if~isfield(sps,'Rswitch')
        if~isempty(sps.rlswitch)
            sps.Rswitch=sps.rlswitch(:,1);
        else
            sps.Rswitch=[];
        end
    end

    if sps.PowerguiInfo.SPID


        [nbvar,nbvar]=size(sps.Aswitch);
        [noutput,ninput]=size(sps.Dswitch);
    else
        [nbvar,nbvar]=size(sps.A);
        [noutput,ninput]=size(sps.D);
        sps.Aswitch=sps.A;
        sps.Bswitch=sps.B;
        sps.Cswitch=sps.C;
        sps.Dswitch=sps.D;
    end

    nsw=size(sps.switches,1);
    nsrc=size(sps.source,1);
    nlines=size(sps.distline,1);

    sps.Hlin=zeros(noutput,ninput);


    NbSwitchLonZero=sum(find(sps.switches(:,5)==0)&1);


    nb_swf=0;


    if nsw


        if~isempty(X0Sw)
            sps.switches(:,3)=X0Sw.SwitchStatus;
        end


        no_swf=find(sps.switches(:,3)==1);

        nb_swf=length(no_swf);

        if nb_swf

            if NbSwitchLonZero

                YswitchDiagonal=zeros(nsw,1);
                YswitchDiagonal(no_swf)=1./sps.rlswitch(no_swf,1);
                D2=zeros(ninput,noutput);
                D2(1:nsw,1:nsw)=diag(YswitchDiagonal);

                I=diag(ones(1,noutput));
                Dx=(I-sps.D*D2);

                sps.Cswitch=Dx\sps.C;
                sps.Dswitch=Dx\sps.D;
                BD=sps.B*D2;
                sps.Aswitch=sps.A+BD*sps.Cswitch;
                sps.Bswitch=sps.B+BD*sps.Dswitch;

            else

                As=diag(-sps.rlswitch(no_swf,1)./sps.rlswitch(no_swf,2));
                Bs=diag(ones(nb_swf,1)./sps.rlswitch(no_swf,2));
                Cs=eye(nb_swf);
                Ds=zeros(nb_swf);%#ok


                [sps.Aswitch,sps.Bswitch,sps.Cswitch,sps.Dswitch]=etafbak(sps.A,sps.B,sps.C,sps.D,As,Bs,Cs,sps.switches(no_swf,6)',sps.switches(no_swf,7)');

            end
        end
    end


    j=sqrt(-1);
    [n,dim]=size(sps.source);
    freq=[];

    if dim==5

        nfreq=1;
        freq=sps.freq;

    elseif dim>=6

        freq=-1;

        for isource=1:nsrc

            if~any(freq==sps.source(isource,6)),
                iswitch=[];
                if dim<7

                    if nsw>0&&sps.source(isource,3)==1,
                        iswitch=find(sps.switches(:,6)==isource);
                    end




                else
                    if sps.source(isource,7)~=99&&sps.source(isource,7)~=20&&sps.source(isource,7)~=21&&sps.source(isource,7)~=22&&sps.source(isource,7)~=23&&sps.source(isource,7)~=24&&sps.source(isource,7)~=25&&~(sps.source(isource,7)>=13&&sps.source(isource,7)<=16)
                        iswitch=1;
                    end
                end
                if isempty(iswitch),
                    freq=[freq,sps.source(isource,6)];%#ok
                end
            end
        end
        freq=sort(freq);
        nfreq=length(freq);

        freq=freq(2:nfreq);
        nfreq=nfreq-1;
    end

    sps.freq=freq;
    sps.uss=zeros(ninput,1);
    sps.xss=zeros(nbvar,1);
    sps.yss=zeros(noutput,1);
    x_f=[];
    sps.x0=zeros(nbvar,1);
    sps.x0switch=zeros(nsw,1);
    H=[];%#ok

    if isempty(freq)
        freq=0;
    end

    if NbSwitchLonZero
        NBSPEC=nbvar;
    else
        NBSPEC=nbvar+nb_swf;
    end


    if(dim==5||dim>=6)

        for ifreq=1:nfreq

            u_f=sps.source(:,4).*exp(j*sps.source(:,5)*pi/180);

            if dim>=6,

                n=find(sps.source(:,6)~=freq(ifreq));
                u_f(n)=zeros(length(n),1);
            end

            if freq(ifreq)==0&&rank(sps.Aswitch)<(NBSPEC)
                sI=j*2*pi*1e-5*eye(NBSPEC);
            else
                sI=j*2*pi*freq(ifreq)*eye(NBSPEC);
            end


            if(NBSPEC)>0

                H1=(sps.Cswitch/(sI-sps.Aswitch))*sps.Bswitch+sps.Dswitch;
            else

                H1=sps.Dswitch;
            end

            [noutput,ninput]=size(sps.Dswitch);
            if nlines

                [H2]=etahlin(ninput,noutput,freq(ifreq),sps);

                I=eye(nsrc,nsrc);
                H_f=H1/(I-H2*H1);

            else
                H2=zeros(ninput,noutput);
                H_f=H1;
            end


            y_f=H_f*u_f;

            u2=H2*y_f;
            u1=u_f+u2;

            if(NBSPEC)>0
                x_f_1=cond(sI-sps.Aswitch);
                x_f=(sI-sps.Aswitch)\sps.Bswitch*u1;
            end


            if nb_swf

                if NbSwitchLonZero
                    u_f(1:nsw)=zeros(1,nsw);

                    u_f(1:NbSwitchLonZero)=(y_f(1:NbSwitchLonZero)./sps.Rswitch).*sps.switches(1:NbSwitchLonZero,3);
                else
                    u_f(sps.switches(no_swf,6))=x_f(nbvar+1:nbvar+nb_swf);
                end

            end

            if freq(ifreq)>0
                x0_f=imag(x_f);
            else
                x_f=real(x_f);
                x0_f=x_f;
            end


            x0sw_f=zeros(nsw,1);

            if nb_swf

                if NbSwitchLonZero
                    if freq(ifreq)>0
                        x0sw_f(1:NbSwitchLonZero)=imag(y_f(1:NbSwitchLonZero)./sps.Rswitch);
                        x0sw_f(1:NbSwitchLonZero)=x0sw_f(1:NbSwitchLonZero).*sps.switches(1:NbSwitchLonZero,3);
                    else
                        x0sw_f(1:NbSwitchLonZero)=real(y_f(1:NbSwitchLonZero)./sps.Rswitch);
                        x0sw_f(1:NbSwitchLonZero)=x0sw_f(1:NbSwitchLonZero).*sps.switches(1:NbSwitchLonZero,3);
                    end
                else
                    x_f=x_f(1:nbvar);
                    x0sw_f(no_swf)=x0_f(nbvar+1:nbvar+nb_swf);
                    x0_f=x0_f(1:nbvar);
                end

            end



            if~isempty(u_f)
                sps.uss(1:end,ifreq)=u_f;
            end

            if~isempty(x_f)
                sps.xss(1:end,ifreq)=x_f;
            end
            if~isempty(y_f)
                sps.yss(1:end,ifreq)=y_f;
            end

            if~isempty(x0_f)
                sps.x0=sps.x0+x0_f;
            end
            sps.x0switch=sps.x0switch+x0sw_f;

            sps.Hlin(:,:,ifreq)=H_f;
        end
    end



    Frequence=sps.PowerguiInfo.PhasorFrequency;
    sI=eye(nbvar)*j*2*pi*Frequence;
    if(nbvar)>0,

        if isempty(sps.D)
            H1=[];
        else
            H1=sps.C/(sI-sps.A)*sps.B+sps.D;
        end
    else

        H1=sps.D;
    end

    if nlines

        H2=etahlin(ninput,noutput,Frequence,sps);

        I=eye(nsrc,nsrc);
        sps.Hswo=H1/(I-H2*H1);

        IoutH2=H2*sps.yss;
        n1=sps.distline(1,2);
        n2=sps.distline(end,2)+2*sps.distline(end,1)-1;
        sps.uss(n1:n2)=IoutH2(n1:n2);

    else
        H2=zeros(ninput,noutput);%#ok
        sps.Hswo=H1;
    end


    u0=zeros(size(sps.source,1),1);
    if size(sps.source,2)>5
        for i=1:size(sps.source,1)
            for ifreq=1:nfreq
                if sps.source(i,6)==0
                    u0(i)=u0(i)+real(sps.uss(i,ifreq));
                else
                    u0(i)=u0(i)+imag(sps.uss(i,ifreq));
                end
            end
        end
    end
    sps.u0=u0;


