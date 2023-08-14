function designData=filt_spars(obj,designData)



















    Rsrc=obj.Zin;
    Rload=obj.Zout;
    Pdiv=2*sqrt(Rsrc*Rload)/(Rsrc+Rload);
    rtn=((Rsrc-Rload)/(Rsrc+Rload))^2;
    filterOrder=designData.FilterOrder;
    rtnO2N=rtn^(1/(2*filterOrder));
    rtnO2Nsq=rtn^(1/filterOrder);

    polePhase=(2*(1:filterOrder/2)-1).*180/(2*filterOrder);
    cmplex_len=numel(polePhase);
    sinAng=sind(polePhase');
    rtnO2NsinAng=rtnO2N*sinAng;













    respType=obj.ResponseType;
    switch respType
    case 'Lowpass'
        wc=designData.Wp;
        den=[ones(cmplex_len,1),2*wc*sinAng,ones(cmplex_len,1)*(wc^2)];
        num11=[ones(cmplex_len,1),2*wc*rtnO2NsinAng...
        ,ones(cmplex_len,1)*(wc^2)*rtnO2Nsq];
        if mod(filterOrder,2)
            num11=[num11;0,1,wc*rtnO2N];
            den=[den;0,1,wc];
            num21=[repmat([0,0,wc^2],(filterOrder-1)/2,1);...
            [0,0,wc*Pdiv]];
        else
            if filterOrder==2
                num21=[0,0,Pdiv*(wc^2)];
            else
                num21=[repmat([0,0,wc^2],floor((filterOrder-1)/2),1);...
                [0,0,Pdiv*(wc^2)]];
            end
        end
        num22=num11;
        num22(1,[1,3])=-1*num22(1,[1,3]);
        num22(2:end,2)=-1*num22(2:end,2);
        k=(wc^filterOrder)*Pdiv;
        if isinf(k)
            designData.Auxiliary.Numerator21Polynomial=...
            [zeros(1,filterOrder),prod(num21(:,3))];
        else
            designData.Auxiliary.Numerator21Polynomial=...
            [zeros(1,filterOrder),k];
        end
    case 'Highpass'
        wc=designData.Wp;
        den=[ones(cmplex_len,1),2*wc*sinAng,ones(cmplex_len,1)*(wc^2)];
        num11=[ones(cmplex_len,1)*rtnO2Nsq,2*wc*rtnO2NsinAng...
        ,ones(cmplex_len,1)*(wc^2)];
        num22=num11;
        num22(2:end,2)=-1*num22(2:end,2);
        if filterOrder>1
            num22(1,[1,3])=-1*num22(1,[1,3]);
        end
        if mod(filterOrder,2)
            num11=[num11;0,rtnO2N,wc];
            if filterOrder>1
                num22=[num22;0,rtnO2N,-wc];
            else
                num22=[num22;0,rtnO2N,wc];
            end
            den=[den;0,1,wc];
            num21=[repmat([1,0,0],(filterOrder-1)/2,1);...
            [0,Pdiv,0]];
        else
            if filterOrder==2
                num21=[Pdiv,0,0];
            else
                num21=[repmat([1,0,0],floor((filterOrder-1)/2),1);...
                [Pdiv,0,0]];
            end
        end
        designData.Auxiliary.Numerator21Polynomial=...
        [Pdiv,zeros(1,filterOrder)];
    case 'Bandpass'
        w1=designData.Wp(1);
        w2=designData.Wp(2);
        bw=designData.Auxiliary.Wx*(w2-w1);
        Cn=w1*w2;
        den=[ones(cmplex_len,1),2*sinAng*bw...
        ,((2*Cn)+(bw*bw))*ones(cmplex_len,1)...
        ,2*sinAng*bw*Cn,Cn^2*ones(cmplex_len,1)];
        num11=[ones(cmplex_len,1),2*rtnO2NsinAng*bw...
        ,((2*Cn)+((bw^2)*rtnO2Nsq))*ones(cmplex_len,1)...
        ,2*rtnO2NsinAng*bw*Cn,Cn^2*ones(cmplex_len,1)];
        num22=num11;
        num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
        num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
        if mod(filterOrder,2)
            num11=[num11;0,0,1,bw*rtnO2N,Cn];
            den=[den;0,0,1,bw,Cn];
            num22=[num22;0,0,-1,bw*rtnO2N,-Cn];
            num21=[repmat([bw^2,0,0],(filterOrder-1)/2,1);...
            [0,bw*Pdiv,0]];
        else
            if filterOrder==2
                num21=[(bw^2)*Pdiv,0,0];
            else
                num21=[repmat([bw^2,0,0],floor((filterOrder-1)/2),1);...
                [(bw^2)*Pdiv,0,0]];
            end
        end
        k=(bw^filterOrder)*Pdiv;
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
        den=[ones(cmplex_len,1),2*sinAng*bw...
        ,((2*Cn)+((bw)^2))*ones(cmplex_len,1)...
        ,2*sinAng*bw*Cn,Cn^2*ones(cmplex_len,1)];
        num11=[rtnO2Nsq*ones(cmplex_len,1),2*rtnO2NsinAng*bw...
        ,((2*Cn*rtnO2Nsq)+((bw)^2))*ones(cmplex_len,1)...
        ,2*rtnO2NsinAng*bw*Cn,rtnO2Nsq*Cn^2*ones(cmplex_len,1)];

        if mod(filterOrder,2)
            num11=[num11;0,0,rtnO2N,bw,Cn*rtnO2N];
            den=[den;0,0,1,bw,Cn];
            num21=Pdiv^(2/filterOrder)*[ones(floor(filterOrder/2),1)...
            ,zeros(floor(filterOrder/2),1)...
            ,2*Cn*ones(floor(filterOrder/2),1),...
            zeros(floor(filterOrder/2),1),...
            (Cn^2)*ones(floor(filterOrder/2),1)];
            num21=[num21;Pdiv^(1/filterOrder)*[0,0,1,0,Cn]];
        else
            num21=Pdiv^(2/filterOrder)*[ones(filterOrder/2,1)...
            ,zeros(filterOrder/2,1)...
            ,2*Cn*ones(filterOrder/2,1),...
            zeros(filterOrder/2,1),...
            (Cn^2)*ones(filterOrder/2,1)];
        end
        num22=num11;
        num22(2:end,[2,4])=-1*num22(2:end,[2,4]);
        num22(1,[1,3,5])=-1*num22(1,[1,3,5]);
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
