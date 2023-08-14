function check_lossless(s11_num,s21_num,s22_num,den)









    polyLen=cellfun(@length,{s11_num,s21_num,s22_num,den});
    padNum=max(polyLen)-polyLen;
    s11_num=[zeros(1,padNum(1)),s11_num];
    s21_num=[zeros(1,padNum(2)),s21_num];
    s22_num=[zeros(1,padNum(3)),s22_num];
    den=[zeros(1,padNum(4)),den];


    epsMult=1e4;


    t12p1=conv(s_conj(s11_num),s21_num);
    epsp1=epsMult*eps(t12p1);
    t12p2=conv(s_conj(s21_num),s22_num);
    epsp2=epsMult*eps(t12p2);
    epsMin=min(epsp1,epsp2);
    if any(isinf(t12p1))||any(isinf(t12p2))...
        ||any(isinf(s11_num))||any(isinf(s21_num))||any(isinf(s22_num))
        return;
    end
    T12=t12p1+t12p2;

    T12(abs(T12)<epsMin)=0;

    validateattributes(abs(T12),{'numeric'},...
    {'nonempty','vector','nonnan','<=',epsMult*eps},...
    mfilename,'T12');


    t21p1=conv(s_conj(s21_num),s11_num);
    epsp1=epsMult*eps(t21p1);
    t21p2=conv(s_conj(s22_num),s21_num);
    epsp2=epsMult*eps(t21p2);
    epsMin=min(epsp1,epsp2);
    T21=t21p1+t21p2;
    if any(isinf(t21p1))||any(isinf(t21p2))
        return;
    end

    T21(abs(T21)<epsMin)=0;
    validateattributes(abs(T21),{'numeric'},...
    {'nonempty','vector','nonnan','<=',epsMult*eps},...
    mfilename,'T21');







    D2=conv(s_conj(den),den);

    D2(end-1:-2:1)=0;
    pow=fix(log10(abs(den)));
    epsDen=eps(epsMult*10.^[pow,pow(end)+pow(2:end)]);

    D2(abs(D2)<epsDen)=0;


    t11p1=conv(s_conj(s11_num),s11_num);

    t11p1(end-1:-2:1)=0;
    pow=fix(log10(abs(s11_num)));
    epsT11=eps(epsMult*10.^[pow,pow(end)+pow(2:end)]);

    t11p1(abs(t11p1)<epsT11)=0;
    t11p2=conv(s_conj(s21_num),s21_num);

    t11p2(end-1:-2:1)=0;
    pow=fix(log10(abs(s21_num)));
    epsT11=eps(epsMult*10.^[pow,pow(end)+pow(2:end)]);

    t11p2(abs(t11p2)<epsT11)=0;
    if any(isinf(t11p1))||any(isinf(t11p2))
        return;
    end
    T11=t11p1+t11p2;

    Unity11=deconv(T11,D2);
    validateattributes(abs(Unity11-1),{'numeric'},...
    {'nonempty','scalar','nonnan','<=',epsMult*eps},...
    mfilename,'Unity11 minus One');


    t22p2=conv(s_conj(s22_num),s22_num);

    t22p2(end-1:-2:1)=0;
    pow=fix(log10(abs(s22_num)));
    epsT22=eps(epsMult*10.^[pow,pow(end)+pow(2:end)]);

    t22p2(abs(t22p2)<epsT22)=0;
    T22=t11p2+t22p2;
    if any(isinf(t22p2))||any(isinf(t11p2))
        return;
    end

    Unity22=deconv(T22,D2);
    validateattributes(abs(Unity22-1),{'numeric'},...
    {'nonempty','scalar','nonnan','<=',epsMult*eps},...
    mfilename,'Unity22 minus One');

end

function poly_conj=s_conj(spoly)




    poly_conj=spoly;
    poly_conj(end-1:-2:1)=-poly_conj(end-1:-2:1);

end