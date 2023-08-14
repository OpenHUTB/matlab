function cfs=realWT(x,psidft)






    coder.allowpcode('plain');

%#codegen
    coder.gpu.kernelfun;

    xdft=fft(x);
    Ns=cast(size(psidft,1),'int32');
    Nfilt=cast(size(psidft,2),'int32');


    cfsdft=coder.nullcopy(complex(zeros(Ns,Nfilt,'like',x)));
    coder.gpu.kernel();
    for kk=1:Ns
        for jj=1:Nfilt

            cfsdft(kk,jj)=xdft(jj)*psidft(kk,jj);
        end
    end


    cfs=ifft(cfsdft,[],2);




