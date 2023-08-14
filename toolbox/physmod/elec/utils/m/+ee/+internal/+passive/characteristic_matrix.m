function[Yc,Vm,Hm,D,T,Tinv]=characteristic_matrix(Z,Y,freq,len)















    Nf=length(freq);
    Nl=size(Z(:,:,1),1);
    Yc=zeros(Nl,Nl,Nf);
    Vm=zeros(Nl,Nf);
    Hm=zeros(Nl,Nf);
    T=zeros(Nl,Nl,Nf);
    Tinv=zeros(Nl,Nl,Nf);
    D=zeros(Nl,Nl,Nl,Nf);
    YZ=zeros(Nl,Nl,Nf);

    for index_k=1:Nf
        Z_k=Z(:,:,index_k);
        Y_k=Y(:,:,index_k);
        YZ(:,:,index_k)=Z_k*Y_k;
    end
    [Tseq,Dseq]=ee.internal.passive.eigenshuffle(YZ);

    for index_k=1:Nf
        Z_k=Z(:,:,index_k);
        Y_k=Y(:,:,index_k);
        freq_k=freq(index_k);

        T_k=Tseq(:,:,index_k);
        D_k=diag(Dseq(:,index_k));

        Tinv_k=inv(T_k);
        T(:,:,index_k)=T_k;
        Tinv(:,:,index_k)=Tinv_k;
        Gamma_k=sqrt(diag(D_k));

        Yc(:,:,index_k)=(T_k*diag(1./Gamma_k)/T_k)*Y_k;

        Vm(:,index_k)=2*pi*freq_k./imag(Gamma_k);
        Hm(:,index_k)=exp(-Gamma_k*len);

        for index_i=1:Nl
            D(:,:,index_i,index_k)=T_k(:,index_i)*Tinv_k(index_i,:);
        end
    end

    Vm=Vm.';
    Hm=Hm.';

end