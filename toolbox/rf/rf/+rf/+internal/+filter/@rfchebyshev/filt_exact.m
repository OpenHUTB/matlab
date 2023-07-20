function elValsLP=filt_exact(obj,designData)
















    filterOrder=designData.FilterOrder;
    topology=obj.Implementation;
    Rsrc=obj.Rsrc;
    Rload=obj.Rload;
    RloadNorm=Rload/Rsrc;
    RpDB=designData.RpDB;


    Rp=10^(RpDB/10);
    epsilon=sqrt(Rp-1);

    Wh=1;
    beta=2*asinh(1/epsilon);



    impedScale=1;
    if bitand(filterOrder,1)
        if(strcmpi(topology,'LC Tee')&&RloadNorm<1)||...
            (strcmpi(topology,'LC Pi')&&RloadNorm>1)
            impedScale=RloadNorm;
        end

    elseif strcmpi(topology,'LC Tee')

        if RloadNorm<coth(beta/4)^2
            minResStr=num2str(coth(beta/4)^2);
            error(message('rf:rffilter:InvalidDesignParsSet',...
            topology,'Chebyshev','even order',...
            num2str(filterOrder),num2str(RloadNorm),...
            'less than',minResStr));
        end
    else

        if RloadNorm>tanh(beta/4)^2
            maxResStr=num2str(tanh(beta/4)^2);
            error(message('rf:rffilter:InvalidDesignParsSet',...
            topology,'Chebyshev','even order',...
            num2str(filterOrder),num2str(RloadNorm),...
            'greater than',maxResStr));
        end
    end


    Rsrc=1;
    if bitand(filterOrder,1)
        Rratio=4*RloadNorm/(RloadNorm+Rsrc)^2;
    else



        Rratio=4*RloadNorm*Rp/(RloadNorm+Rsrc)^2;
    end

    delta=sinh(asinh(sqrt(1-Rratio)/epsilon)/filterOrder);
    gamma=sinh(beta/(2*filterOrder));
    el_idx=1:filterOrder;
    bTerms=gamma^2+delta^2-...
    2*gamma*delta*cosd(el_idx*180/filterOrder)+...
    sind(el_idx*180/filterOrder).^2;
    aTerms=sind(((2*el_idx-1)*180)/(2*filterOrder));

    elValues=inf(1,filterOrder);
    elValues(1)=2*aTerms(1)/((gamma-delta)*Wh);

    for el_idx=2:filterOrder
        elValues(el_idx)=4*aTerms(el_idx)*aTerms(el_idx-1)/...
        (bTerms(el_idx-1)*elValues(el_idx-1));
    end

    if impedScale~=1

        elValues(end:-1:1)=elValues(1:end);
    end


    elValsLP=inf(2,filterOrder);
    if strcmpi(topology,'LC Tee')

        elValsLP(1,1:2:end)=elValues(1:2:end)*impedScale;
        elValsLP(2,2:2:end)=elValues(2:2:end)/impedScale;
    else

        elValsLP(1,2:2:end)=elValues(2:2:end)*impedScale;
        elValsLP(2,1:2:end)=elValues(1:2:end)/impedScale;
    end

end