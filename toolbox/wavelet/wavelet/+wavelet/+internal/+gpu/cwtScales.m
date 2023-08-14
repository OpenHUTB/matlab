function[scales,minscale]=cwtScales(wname,N,nv,ga,be,numsd,cutoff)






    coder.allowpcode('plain');

%#codegen

    omegac=pi;

    [~,sigmat,cf]=wavelet.internal.cwt.wavCFandSD(wname,ga,be);

    maxscale=double(N)/(sigmat*numsd);


    cutoff=cutoff/100;

    switch lower(wname)
    case 'morse'
        omegac=getFreqFromCutoffMorse(cutoff,cf,ga,be);
    case 'bump'
        omegac=getFreqFromCutoffBump(cutoff,cf);
    case 'amor'
        omegac=getFreqFromCutoffAmor(cutoff,cf);
    end


    if isempty(omegac)
        omegac=pi;
    end


    minscale=omegac/pi;


    if maxscale<minscale*2^(1/nv)
        maxscale=minscale*2^(1/nv);
    end

    numoctaves=max(log2(maxscale/minscale),1/nv);

    a0=2^(1/nv);
    Ns=cast(floor(numoctaves*nv),'int32')+int32(1);
    scales=coder.nullcopy(zeros(1,Ns));

    coder.gpu.kernel();
    for kk=1:Ns
        scales(kk)=minscale*a0^(double(kk)-1);
    end




    function omegac=getFreqFromCutoffAmor(cutoff,cf)

        alpha=2*cutoff;
        psihat=@(omega)alpha-2*exp(-(omega-cf).^2/2);

        omax=((2*750).^0.5+cf);
        if psihat(cf)>0
            omegac=omax;
        else
            omegac=fzero(psihat,[cf,omax]);
        end


        function omegac=getFreqFromCutoffBump(cutoff,cf)

            sigma=0.6;

            if cutoff<10*eps(0)
                omegac=cf+sigma-10*eps(cf+sigma);
            else
                alpha=2*cutoff;
                psihat=@(om)1/(1-om^2)+log(alpha)-log(2)-1;
                epsilon=fzero(psihat,[0+eps(0),1-eps(1)]);
                omegac=sigma*epsilon+cf;
            end


            function omegac=getFreqFromCutoffMorse(cutoff,cf,ga,be)



                anorm=2*exp(be/ga*(1+(log(ga)-log(be))));

                alpha=2*cutoff;


                psihat=@(om)alpha-anorm*om.^be*exp(-om.^ga);

                omax=((750).^(1/ga));
                if psihat(cf)>=0
                    if psihat(omax)==psihat(cf)
                        omegac=omax;
                    else
                        omegac=cf;
                    end
                else
                    omegac=fzero(psihat,[cf,omax]);

                end


