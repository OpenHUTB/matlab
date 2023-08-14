function Hk=Hk_compute(T,Tinv,D,Hm,freq,tau_delay_m)










    w=2*pi*freq;
    Nf=length(freq);
    Nl=size(Hm,2);


    Hk=zeros(Nl,Nl,Nl,Nf);
    for index_k=1:Nf
        for index_i=1:Nl
            Hk(:,:,index_i,index_k)=D(:,:,index_i,index_k)*Hm(index_k,index_i)/exp(-1i*w(index_k)*tau_delay_m(index_i));
        end
    end

end