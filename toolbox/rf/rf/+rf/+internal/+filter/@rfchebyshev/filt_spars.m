function designData=filt_spars(obj,designData)
















    Rsrc=obj.Zin;
    Rload=obj.Zout;
    Pdiv=2*sqrt(Rsrc*Rload)/(Rsrc+Rload);
    filterOrder=designData.FilterOrder;

    RpDB=obj.PassbandAttenuation;
    epsilon=sqrt(10^(RpDB/10)-1);
    neta=sinh(asinh(1/epsilon)/filterOrder);
    neta2=neta*neta;
    zeta=sinh(asinh(sqrt(1-Pdiv^2)/epsilon)/filterOrder);
    zeta2=zeta*zeta;
    Pdivc=Pdiv/(epsilon*pow2(filterOrder-1));

    polePhase=(2*(1:filterOrder/2)-1).*180/(2*filterOrder);
    cmplex_len=numel(polePhase);
    sinAng=sind(polePhase');
    alpha_den=neta*sinAng;
    cosAng2=(cosd(polePhase')).^2;
    neta2scosAng2=neta2+cosAng2;
    zetasinAng=zeta*sinAng;
    zeta2scosAng2=zeta2+cosAng2;












    respType=obj.ResponseType;
    switch respType
    case 'Lowpass'
        wc=designData.Wp;
        den=[ones(cmplex_len,1),2*wc*alpha_den...
        ,ones(cmplex_len,1)*(wc^2).*neta2scosAng2];
        num11=[ones(cmplex_len,1),2*wc*zetasinAng...
        ,ones(cmplex_len,1)*(wc^2).*zeta2scosAng2];

        if mod(filterOrder,2)
            num11=[num11;0,1,wc*zeta];
            den=[den;0,1,wc*neta];
            num21=[repmat([0,0,wc^2],(filterOrder-1)/2,1);...
            [0,0,wc*Pdivc]];
        else
            if filterOrder==2
                num21=[0,0,Pdivc*(wc^2)];
            else
                num21=[repmat([0,0,wc^2],floor((filterOrder-1)/2),1);...
                [0,0,Pdivc*(wc^2)]];
            end
        end
        num22=num11;
        num22(2:end,2)=-1*num22(2:end,2);
        num22(1,[1,3])=-1*num22(1,[1,3]);
        k=(wc^filterOrder)*Pdivc;
        if isinf(k)
            designData.Auxiliary.Numerator21Polynomial=...
            [zeros(1,filterOrder),prod(num21(:,3))];
        else
            designData.Auxiliary.Numerator21Polynomial=...
            [zeros(1,filterOrder),k];
        end
    case 'Highpass'
        wc=designData.Wp;
        den=[ones(cmplex_len,1).*neta2scosAng2...
        ,2*wc*alpha_den,ones(cmplex_len,1)*(wc^2)];
        num11=[ones(cmplex_len,1).*zeta2scosAng2,2*wc*zetasinAng...
        ,ones(cmplex_len,1)*(wc^2)];
        num22=num11;
        num22(2:end,2)=-1*num22(2:end,2);
        if filterOrder>1
            num22(1,[1,3])=-1*num22(1,[1,3]);
        end
        if mod(filterOrder,2)
            num11=[num11;0,zeta,wc];
            den=[den;0,neta,wc];
            if filterOrder>1
                num22=[num22;0,zeta,-wc];
            else
                num22=[num22;0,zeta,wc];
            end
            num21=[repmat([1,0,0],(filterOrder-1)/2,1);...
            [0,Pdivc,0]];
        else
            if filterOrder==2
                num21=[Pdivc,0,0];
            else
                num21=[repmat([1,0,0],floor((filterOrder-1)/2),1);...
                [Pdivc,0,0]];
            end
        end
        designData.Auxiliary.Numerator21Polynomial=...
        [Pdivc,zeros(1,filterOrder)];
    case 'Bandpass'
        w1=designData.Wp(1);
        w2=designData.Wp(2);
        bw=designData.Auxiliary.Wx*(w2-w1);
        Cn=w1*w2;
        den=[ones(cmplex_len,1),2*alpha_den*bw...
        ,((2*Cn)+((bw^2).*neta2scosAng2)).*ones(cmplex_len,1)...
        ,2*alpha_den*bw*Cn,Cn^2*ones(cmplex_len,1)];
        num11=[ones(cmplex_len,1),2*zetasinAng*bw...
        ,((2*Cn)+((bw^2).*zeta2scosAng2)).*ones(cmplex_len,1)...
        ,2*zetasinAng*bw*Cn,Cn^2*ones(cmplex_len,1)];
        num22=num11;
        num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
        num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
        if mod(filterOrder,2)
            num11=[num11;0,0,1,bw*zeta,Cn];
            den=[den;0,0,1,bw*neta,Cn];
            num22=[num22;0,0,-1,bw*zeta,-Cn];
            num21=[repmat([bw^2,0,0],(filterOrder-1)/2,1);...
            [0,bw*Pdivc,0]];
        else
            if filterOrder==2
                num21=[(bw^2)*Pdivc,0,0];
            else
                num21=[repmat([bw^2,0,0],floor((filterOrder-1)/2),1);...
                [(bw^2)*Pdivc,0,0]];
            end
        end
        k=(bw^filterOrder)*Pdivc;
        if isinf(k)
            index=num21>0;
            designData.Auxiliary.Numerator21Polynomial=...
            [prod(num21(index)),zeros(1,filterOrder)];
        else
            designData.Auxiliary.Numerator21Polynomial=...
            [k,zeros(1,filterOrder)];
        end
    case 'Bandstop'
        w1=designData.Ws(1);
        w2=designData.Ws(2);
        wx=designData.Auxiliary.Wx;
        bw=wx*(w2-w1);
        Cn=w1*w2;
        den=[neta2scosAng2.*ones(cmplex_len,1)...
        ,2*alpha_den*bw...
        ,((2*Cn.*neta2scosAng2)+((bw)^2)).*ones(cmplex_len,1)...
        ,2*alpha_den*bw*Cn,neta2scosAng2.*Cn^2.*ones(cmplex_len,1)];

        num11=[zeta2scosAng2.*ones(cmplex_len,1),2*zetasinAng*bw...
        ,((2*Cn.*zeta2scosAng2)+((bw)^2)).*ones(cmplex_len,1)...
        ,2*zetasinAng*bw*Cn,zeta2scosAng2.*Cn^2.*ones(cmplex_len,1)];
        if mod(filterOrder,2)
            num11=[num11;0,0,zeta,bw,Cn*zeta];
            den=[den;0,0,neta,bw,Cn*neta];
            num21=Pdivc^(2/filterOrder)*[ones(floor(filterOrder/2),1)...
            ,zeros(floor(filterOrder/2),1)...
            ,2*Cn*ones(floor(filterOrder/2),1),...
            zeros(floor(filterOrder/2),1),...
            (Cn^2)*ones(floor(filterOrder/2),1)];
            num21=[num21;Pdivc^(1/filterOrder)*[0,0,1,0,Cn]];
        else
            num21=Pdivc^(2/filterOrder)*[ones(filterOrder/2,1)...
            ,zeros(filterOrder/2,1)...
            ,2*Cn*ones(filterOrder/2,1),...
            zeros(filterOrder/2,1),...
            (Cn^2)*ones(filterOrder/2,1)];
        end
        num22=num11;
        num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
        num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
        designData.Auxiliary.Numerator21Polynomial=...
        Pdivc^(1/filterOrder)*[ones(filterOrder,1)...
        ,zeros(filterOrder,1),Cn*ones(filterOrder,1)];
    end

    designData.Numerator21=num21;
    designData.Numerator11=num11;
    designData.Numerator22=num22;
    designData.Denominator=den;

    check_lossless(polyGen(num11),polyGen(num21),polyGen(num22),...
    polyGen(den));

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
