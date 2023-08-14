function designData=filt_spars(obj,designData)


















    Rsrc=obj.Zin;
    Rload=obj.Zout;
    filterOrder=designData.FilterOrder;

    RsDB=obj.StopbandAttenuation;



    tenRs=10^(RsDB/10);
    epsilon2=1/(tenRs-1);
    epsilon=sqrt(epsilon2);

    y=asinh(1/epsilon)/filterOrder;

    polePhase=(2*(1:filterOrder/2)-1).*180/(2*filterOrder);
    cmplex_len=numel(polePhase);
    sinAng=sind(polePhase');
    sinAng2=sinAng.^2;
    secAng=secd(polePhase');

    coshAng2=cosh(y)^2;
    alpha_den=sinh(y)*sinAng;
    gamma_den=coshAng2-sinAng2;
    alpha=alpha_den./gamma_den;

    Pdiv=2*sqrt(Rsrc*Rload)/(Rsrc+Rload);

    uneven_termination=~isequal(Pdiv,1);
    if uneven_termination
        epsilon11=sqrt(epsilon2*(1-Pdiv^2));
        y11=asinh(1/epsilon11)/filterOrder;
        coshAng2_11=cosh(y11)^2;
        alpha_num11=sinh(y11)*sinAng;
        gamma_num11=coshAng2_11-sinAng2;
        alpha11=alpha_num11./gamma_num11;
    end








    respType=obj.ResponseType;
    switch respType
    case 'Lowpass'
        wc=designData.Ws;
        den=[ones(cmplex_len,1),2*wc*alpha,(wc^2)./gamma_den];
        num21=[ones(cmplex_len,1),zeros(cmplex_len,1),(wc*secAng).^2];
        if mod(filterOrder,2)
            den=[den;0,1,wc*csch(y)];


            factor=csch(y)/prod(gamma_den.*(secAng.^2));
            num21=[num21;0,0,wc*factor];
            if uneven_termination
                num11=[ones(cmplex_len,1),2*wc*alpha11...
                ,(wc^2)./gamma_num11];
                num11=[num11;0,1,wc*csch(y11)];
            else
                num11=[repmat([1,0,0],floor(filterOrder/2),1);0,1,0];
            end
        else
            factor=1/prod(gamma_den.*(secAng.^2));
            num21(end,:)=factor*num21(end,:);
            if uneven_termination
                num11=[ones(cmplex_len,1),2*wc*alpha11...
                ,(wc^2)./gamma_num11];
                factor11=sqrt(1-((epsilon2*Pdiv^2)/(1+epsilon2)));
                num11(1,:)=factor11*num11(1,:);
            else
                num11=[sqrt(1-factor^2),0,0;...
                repmat([1,0,0],(filterOrder/2)-1,1)];
            end
        end
        num21(1,:)=Pdiv*num21(1,:);
        num22=num11;
        num22(2:end,2)=-1*num22(2:end,2);
        num22(1,[1,3])=-1*num22(1,[1,3]);
    case 'Highpass'
        wc=designData.Ws;
        num21=[repmat([1,0],cmplex_len,1)...
        ,(repmat(wc,cmplex_len,1)./secAng).^2];
        den=[ones(cmplex_len,1),2*wc*alpha_den,(wc^2)*gamma_den];
        if mod(filterOrder,2)
            den=[den;0,1,wc/csch(y)];
            num21=[num21;0,1,0];
            if uneven_termination
                num11=[ones(cmplex_len,1),2*wc*alpha_num11...
                ,(wc^2)*gamma_num11];
                num11(1,:)=sqrt(1-Pdiv^2)*num11(1,:);
                num22=num11;
                num22(2:end,2)=-1*num22(2:end,2);
                num22(1,[1,3])=-1*num22(1,[1,3]);

                num11=[num11;0,1,wc/csch(y11)];
                num22=[num22;0,1,-wc/csch(y11)];
            else
                num11=[zeros(cmplex_len+1,2),den(:,3)];
                num22=num11;
            end
        else
            if uneven_termination
                num11=[ones(cmplex_len,1),2*wc*alpha_num11...
                ,(wc^2)*gamma_num11];
                num11(1,:)=sqrt(1-Pdiv^2)*num11(1,:);
                num22=num11;
                num22(2:end,2)=-1*num22(2:end,2);
                num22(1,[1,3])=-1*num22(1,[1,3]);
            else
                factor=sqrt(diff(prod([1./secAng.^2,gamma_den].^2,1)));
                num11=[0,0,factor*(wc^2);...
                repmat([0,0,wc^2],cmplex_len-1,1)];
                num22=num11;
                num22(1,3)=-1*num22(1,3);
            end

        end
        num21(1,:)=Pdiv*num21(1,:);
    case 'Bandpass'
        w1=designData.Ws(1);
        w2=designData.Ws(2);
        bw=(w2-w1)*designData.Auxiliary.Wx;
        Cn=w1*w2;
        den=[ones(cmplex_len,1),2*alpha*bw,(2*Cn)+((bw^2)./gamma_den)...
        ,2*alpha*bw*Cn,Cn^2.*ones(cmplex_len,1)];
        num21=[repmat([1,0],[cmplex_len,1]),((2*Cn)+(secAng*bw).^2)...
        ,zeros(cmplex_len,1),ones(cmplex_len,1)*(Cn^2)];
        if mod(filterOrder,2)
            den=[den;0,0,1,csch(y)*bw,Cn];
            factor=bw*csch(y)/prod(gamma_den.*(secAng.^2));
            num21=[num21;0,0,0,1,0];


            num21(end,:)=factor*num21(end,:);
            if uneven_termination
                num11=[ones(cmplex_len,1),2*alpha11*bw...
                ,(2*Cn)+((bw^2)./gamma_num11)...
                ,2*alpha11*bw*Cn,Cn^2.*ones(cmplex_len,1)];
                num22=num11;
                num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
                num22(1,[1,3,5])=-1*num22(1,[1,3,5]);

                num11=[num11;0,0,1,csch(y11)*bw,Cn];
                num22=[num22;0,0,-1,csch(y11)*bw,-Cn];
            else
                num11=[repmat([1,0,2*Cn,0,Cn^2],cmplex_len,1);...
                [0,0,1,0,Cn]];
                num22=num11;
                num22([1,end],[1,3,5])=-1*num22([1,end],[1,3,5]);
            end
        else
            factor=1/prod(gamma_den.*(secAng.^2));
            num21(1,:)=factor*num21(1,:);
            if uneven_termination
                num11=[ones(cmplex_len,1),2*alpha11*bw...
                ,(2*Cn)+((bw^2)./gamma_num11)...
                ,2*alpha11*bw*Cn,Cn^2.*ones(cmplex_len,1)];
                factor11=sqrt(1-((epsilon2*Pdiv^2)/(1+epsilon2)));
                num11(1,:)=factor11*num11(1,:);

                num22=num11;
                num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
                num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
            else
                num11=repmat((1-factor^2)^(1/filterOrder)*...
                [1,0,2*Cn,0,Cn^2],cmplex_len,1);
                num22=num11;
                num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
            end
        end
        num21(1,:)=Pdiv*num21(1,:);
    case 'Bandstop'
        w1=designData.Ws(1);
        w2=designData.Ws(2);
        bw=w2-w1;
        Cn=w1*w2;
        den=[ones(cmplex_len,1),2*bw*alpha.*gamma_den...
        ,(2*Cn)+((bw^2).*gamma_den),2*alpha*bw*Cn.*gamma_den...
        ,Cn^2.*ones(cmplex_len,1)];
        num21=[repmat([1,0],[cmplex_len,1]),(2*Cn)+(bw^2)./(secAng.^2)...
        ,zeros(cmplex_len,1),(Cn^2)*ones(cmplex_len,1)];
        if mod(filterOrder,2)
            den=[den;0,0,1,bw/csch(y),Cn];
            num21=[num21;0,0,1,0,Cn];





            if uneven_termination
                num11=[ones(cmplex_len,1),2*bw*alpha11.*gamma_num11...
                ,(2*Cn)+((bw^2).*gamma_num11)...
                ,2*alpha11*bw*Cn.*gamma_num11,Cn^2.*ones(cmplex_len,1)];
                num11(1,:)=sqrt(1-Pdiv^2)*num11(1,:);
                num11=[num11;0,0,1,bw/csch(y11),Cn];
            else
                num11=[repmat([0,0,(bw^2)/4,0,0],cmplex_len,1);...
                [0,0,0,bw/epsilon,0]];
            end
        else
            factor=sqrt(diff(prod([1./secAng.^2,gamma_den].^2,1)));
            if uneven_termination
                num11=[ones(cmplex_len,1),2*bw*alpha11.*gamma_num11...
                ,(2*Cn)+((bw^2).*gamma_num11)...
                ,2*alpha11*bw*Cn.*gamma_num11,Cn^2.*ones(cmplex_len,1)];
                num11(1,:)=sqrt(1-Pdiv^2)*num11(1,:);
            else
                num11=repmat([0,0,(bw^2)*factor^(2/filterOrder),0,0],...
                filterOrder/2,1);
            end





        end
        num21(1,:)=Pdiv*num21(1,:);
        num22=num11;
        num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
        num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
    end

    designData.Numerator21=num21;
    designData.Numerator11=num11;
    designData.Numerator22=num22;
    designData.Denominator=den;

    check_lossless(polyGen(num11),polyGen(num21),polyGen(num22),polyGen(den));
end

function out=polyGen(Coeff)
    nelem=size(Coeff,1);
    if nelem>1
        out=1;
        for i=1:nelem
            out=conv(out,Coeff(i,:));
        end
    else
        out=Coeff;
    end
    index=find(out,1);
    out=out(index:end);
end