function[out_freqs,transfer]=...
    simrfV2_corr_noise_src_setup(freqs,covariance)















    [m,n,nfreqs]=size(covariance);

    if min(m,n)==1&&nfreqs==1
        covariance=covariance(:);

        covariance=permute(covariance,[3,2,1]);
    end


    [nport,~,~]=size(covariance);
    validateattributes(covariance,{'numeric'},{'nonempty','size',...
    [nport,nport,length(freqs)]},mfilename,'Covariance data')


    freqs=freqs(:)';
    assert(all(freqs>=0)&&issorted(freqs),...
    'Covariance frequencies should be nonnegative and sorted');

    if freqs(1)>1e-9
        freqs=[0,freqs];
        covariance=cat(3,real(covariance(:,:,1)),covariance);
    else

        covariance(:,:,1)=real(covariance(:,:,1));
    end


    cholesky=zeros(size(covariance));
    for i=1:size(covariance,3)
        c=covariance(:,:,i);

        assert(norm(c-c')<=1e-8*norm(c)+1e-30,...
        'Covariance matrix is not hermitian');

        if norm(c)
            [tmp,notPosDef]=chol(c);

            if notPosDef
                [tmp,notPosDef]=...
                chol(c+100*eps*diag(diag(c)));
                if notPosDef
                    [tmp,notPosDef]=chol(...
                    c+1000*eps*diag(diag(c)+eps(min(min(abs(c(c~=0)))))));
                    if notPosDef
                        error(message(...
                        'simrf:simrfV2errors:CovarianceNotPassive'));
                    else
                        cholesky(:,:,i)=tmp;
                        makeZero=all(c(1:nport,:)==0)&all(c(:,1:nport)==0);
                        cholesky(makeZero,makeZero,i)=0;
                    end
                else
                    makeZero=all(c(1:nport,:)==0)&all(c(:,1:nport)==0);
                    tmp(makeZero,makeZero)=0;
                    cholesky(:,:,i)=tmp;
                end
            else
                cholesky(:,:,i)=tmp;
            end
        else
            cholesky(:,:,i)=zeros(nport);
        end
    end


    transfer=cell(nport,nport);
    out_freqs=cell(nport,nport);
    for i=1:nport
        for j=1:nport
            c=squeeze(cholesky(i,j,:));
            c=c(:).';
            f=freqs;

            if all(c==c(1))&&isreal(c(1))
                f=0;
                c=c(1);
            end

            out_freqs{i,j}=f;
            transfer{i,j}=[real(c),imag(c)];
        end
    end