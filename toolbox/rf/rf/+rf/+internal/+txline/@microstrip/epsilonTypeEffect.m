function[Eeff,z0]=epsilonTypeEffect(h,Eeff,z0,we)





    width=h.Width;
    height=h.Height;
    dielectricthickness=h.DielectricThickness;
    Er=h.EpsilonR;
    thickness=h.Thickness;

    isSuspended=false;
    isInverted=false;
    isEmbedded=false;

    switch h.Type
    case 'Embedded'
        isEmbedded=true;
        buryfactor=(dielectricthickness/height)-1;
    case 'Inverted'
        if Er>6
            warning(message('rf:rftxline:EpsilonLimit'))
        end
        isInverted=true;
        aInverted=dielectricthickness;
        bInverted=height+thickness;
        if(aInverted/bInverted)<0.2||(aInverted/bInverted)>1
            warning(message('rf:rftxline:AOverBRatio'))
        end
    case 'Suspended'
        if Er>6
            warning(message('rf:rftxline:EpsilonLimit'))
        end
        isSuspended=true;
        aSuspended=dielectricthickness;
        bSuspended=height-dielectricthickness;
        if(aSuspended/bSuspended)<0.2||(aSuspended/bSuspended)>1
            warning(message('rf:rftxline:AOverBRatio'))
        end
    end

    if isSuspended
        a1=(0.8621-0.1251*log(aSuspended/bSuspended))^4;
        b1=(0.4986-0.1397*log(aSuspended/bSuspended))^4;
        Eeff=(1+((aSuspended/bSuspended)*(a1-b1*log(we/bSuspended))*((1./sqrt(Eeff))-1))).^-1;
        u=width/(aSuspended+bSuspended);
    elseif isInverted
        a1i=(0.5173-0.1515*log(aInverted/bInverted))^2;
        b1i=(0.3092-0.1047*log(aInverted/bInverted))^2;
        Eeff=(1+((aInverted/bInverted)*(a1i-(b1i*log(we/bInverted))).*(sqrt(Eeff)-1)));
        u=width/bInverted;
    elseif isEmbedded


        epsReffB=Eeff.*exp(-2*buryfactor)+Er*(1-exp(-2*buryfactor));

        z0=z0.*sqrt(Eeff./epsReffB);
        Eeff=epsReffB;
    end

    if isSuspended||isInverted
        f_u=@(u)6+((2*pi)-6)*(exp(-(30.666/u)^0.7528));
        z0=(60./Eeff)*log((f_u(u)/u)+sqrt(1+(2/u)^2));
    end
end
