function elValsLP=filt_exact(obj,designData)












    filterOrder=designData.FilterOrder;
    topology=obj.Implementation;
    Rsrc=obj.Rsrc;
    Rload=obj.Rload;
    RloadNorm=Rload/Rsrc;

    if strcmpi(topology,'LC Tee')
        if RloadNorm>=1
            impedScale=1;
        else

            if~bitand(filterOrder,1)
                error(message('rf:rffilter:InvalidDesignParsSet',...
                topology,'Butterworth','even order',...
                num2str(filterOrder),num2str(RloadNorm),...
                'less than','1'));
            end
            impedScale=RloadNorm;
        end
    else
        if RloadNorm<=1
            impedScale=1;
        else

            if~bitand(filterOrder,1)
                error(message('rf:rffilter:InvalidDesignParsSet',...
                topology,'Butterworth','even order',...
                num2str(filterOrder),num2str(RloadNorm),...
                'greater than','1'));
            end
            impedScale=RloadNorm;
        end
    end

    Rratio=(4*RloadNorm)/(RloadNorm+1)^2;
    gamma=1;
    delta=(gamma-Rratio)^(1/(2*filterOrder));
    el_idx=1:filterOrder;

    bTerms=gamma^2+delta^2-2*gamma*delta*cosd(el_idx*180/filterOrder);
    aTerms=sind(((2*el_idx-1)*180)/(2*filterOrder));

    elValues=inf(1,filterOrder);
    elValues(1)=(2*aTerms(1))/(gamma-delta);

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