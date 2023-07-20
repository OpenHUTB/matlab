function S=power_zmeter_pr(system,freq)








    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_zmeter'));
    end



    sps=power_analyze(system,'detailed');

    nstates=size(sps.Bswitch,1);
    [noutput,ninput]=size(sps.Dswitch);
    nlines=size(sps.distline,1);

    j=sqrt(-1);
    I=eye(nstates);
    Isrc=eye(ninput,ninput);
    rankA=rank(sps.Aswitch);
    Z=[];

    DeltaCo=length(freq)/10;
    Compteur=DeltaCo;

    for ifreq=1:length(freq)

        if freq(ifreq)==0&&rankA<nstates
            sI=j*2*pi*1e-5*I;
        else
            sI=j*2*pi*freq(ifreq)*I;
        end



        if(nstates)>0

            H1=sps.Cswitch*inv(sI-sps.Aswitch)*sps.Bswitch+sps.Dswitch;
        else

            H1=sps.Dswitch;
        end

        if nlines

            [H2]=etahlin(ninput,noutput,freq(ifreq),sps);


            H_f=H1*inv(Isrc-H2*H1);
        else
            H2=zeros(ninput,noutput);%#ok
            H_f=H1;
        end
        for k=1:size(sps.Zblocks,1)
            no_input=sps.Zblocks{k,2};
            no_output=sps.Zblocks{k,3};
            kz=sps.Zblocks{k,4};
            Z(ifreq,k)=H_f(no_output,no_input)*kz;%#ok
        end
        if ifreq>Compteur
            Compteur=Compteur+DeltaCo;
        end
    end
    S.Blocks={sps.Zblocks{:,1}};
    S.Z=Z;
    S.Freq=freq';