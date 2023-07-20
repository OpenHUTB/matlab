function[corrMatRatFitStr,isHerm]=...
    simrfV2corrnoise_freq_domain(spars,scale,block)





    sparams=spars;
    freqsLen=size(sparams,3);
    nports=size(sparams,1);
    isHerm=true;




    if~ispassive_herm(sparams)
        warning(message('simrf:simrfV2errors:DerivedNoiseNotPassive',block));
        sparams=makepassive_herm(sparams);
    end



    corrMatRatFitStr='cat(3';
    for fidx=1:freqsLen

        sparsSq=sparams(:,:,fidx)*sparams(:,:,fidx)';
        sparsSq(1:nports+1:nports^2)=real(sparsSq(1:nports+1:nports^2));
        hermPart=scale*(eye(nports)-sparsSq);

        if norm(hermPart-hermPart')>1e-8*norm(hermPart)+1e-30
            isHerm=false;
        end
        corrMatRatFitStr=sprintf('%s%s%s',corrMatRatFitStr,', ',...
        mat2str(hermPart,16));
    end
    corrMatRatFitStr=[corrMatRatFitStr,')'];
end



function ispass=ispassive_herm(spars)

    s_idx=1;
    ispass=true;
    while ispass&&s_idx<=size(spars,3)
        ispass=~(norm(spars(:,:,s_idx),2)>1+10*eps);
        s_idx=s_idx+1;
    end
end

function spars_passive=makepassive_herm(spars)
    freqsLen=size(spars,3);
    spars_passive=spars;
    threshold=1-100*(eps);


    for freq_idx=1:freqsLen

        result=ispassive_herm(spars_passive(:,:,freq_idx));
        idx=0;

        while result==false&&idx<10
            [U,zigma,V]=svd(spars_passive(:,:,freq_idx));
            nzigma=length(zigma);
            upsilon=eye(nzigma);
            psi=eye(nzigma);
            for ii=1:nzigma
                if zigma(ii,ii)<=threshold
                    upsilon(ii,ii)=0;
                    psi(ii,ii)=0;
                else
                    upsilon(ii,ii)=1;
                    psi(ii,ii)=threshold;
                end
            end

            zigma_viol=zigma*upsilon-psi;
            s_viol=U*zigma_viol*V';

            spars_passive(:,:,freq_idx)=spars_passive(:,:,freq_idx)-s_viol;
            idx=idx+1;
            result=ispassive_herm(spars_passive(:,:,freq_idx));
        end
    end
end