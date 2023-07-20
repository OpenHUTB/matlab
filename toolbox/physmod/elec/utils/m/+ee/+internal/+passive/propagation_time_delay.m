function tau_delay_m=propagation_time_delay(Hm,Vm,freq,len)









    w=2*pi*freq;
    Nf=length(freq);
    Nl=size(Hm,2);

    ang1_m=zeros(Nf,Nl);
    ang2_m=zeros(Nf,Nl);
    tau_delay_m=zeros(1,Nl);


    for j=2:Nf-1
        tmp1=log(abs(Hm(j+1,:))./abs(Hm(j-1,:)));
        tmp2=log(w(j+1)/w(j-1));
        ang1_m(j,:)=0.5*pi*tmp1/tmp2;
    end
    ang1_m(1,:)=ang1_m(2,:);
    ang1_m(Nf,:)=ang1_m(Nf-1,:);


    for j=2:Nf-1
        for k=1:Nf-1
            tmp1=log(abs(Hm(k+1,:)./abs(Hm(k,:))))./log(w(k+1)/w(k));
            tmp2=log(abs(Hm(j+1,:)./abs(Hm(j-1,:))))./log(w(j+1)/w(j-1));
            ang2_m(j,:)=ang2_m(j,:)+(abs(tmp1)-abs(tmp2)).*...
            log(coth(abs(log((w(k+1)+w(k))./(2*w(j))))/2)).*...
            log(w(k+1)/w(k));
        end
    end
    ang2_m(1,:)=ang2_m(2,:);
    ang2_m(Nf,:)=ang2_m(Nf-1,:);
    ang2_m=ang2_m/pi;

    ang_m=ang1_m-ang2_m;
    [min_ang_m,min_ang_m_index]=min(ang_m);
    w1=w(min_ang_m_index);


    for index_i=1:Nl
        if abs(Hm(min_ang_m_index(index_i),index_i))>0.1
            min_ang_m(index_i)=ang_m(end,index_i);
            min_ang_m_index(index_i)=Nf;
            w1(index_i)=w(end);
        end
    end


    for index_i=1:Nl
        tau_delay_m(index_i)=len/Vm(min_ang_m_index(index_i),index_i)+min_ang_m(index_i)/w1(index_i);
    end

end