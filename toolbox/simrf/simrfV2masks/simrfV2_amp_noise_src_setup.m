function[out_freqs,transfer]=...
    simrfV2_amp_noise_src_setup(freqs,CholCovariance)

    [nport,~,~]=size(CholCovariance);
    validateattributes(CholCovariance,{'numeric'},{'nonempty','size',...
    [nport,nport,length(freqs)]},mfilename,'Covariance data')

    freqs=freqs(:)';
    assert(all(freqs>=0)&&issorted(freqs),...
    'Covariance frequencies should be nonnegative and sorted');

    if freqs(1)>1e-9
        freqs=[0,freqs];
        CholCovariance=cat(3,real(CholCovariance(:,:,1)),CholCovariance);
    else

        CholCovariance(:,:,1)=real(CholCovariance(:,:,1));
    end

    transfer=cell(nport,nport);
    out_freqs=cell(nport,nport);
    for i=1:nport
        for j=1:nport
            c=squeeze(CholCovariance(i,j,:));
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