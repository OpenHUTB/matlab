function selfint=metalselfint(obj,p,t,metalbasis,TetrahedraTotal)




    integScheme=getIntegrationScheme(obj);

    if isequal(integScheme,1)
        points=7;
        order=5;
    else
        points=3;
        order=2;
    end


    if TetrahedraTotal>0
        [coeff,weights]=em.EmStructures.gausstri(7,5);
    else
        [coeff,weights]=em.EmStructures.gausstri(points,order);
    end
    if strcmpi(class(obj),'infiniteArray')
        selfint=em.EmStructures.calc_integral_c(p,t(1:3,:),...
        metalbasis.Center,metalbasis.Area,metalbasis.Normal,...
        metalbasis.facesize,coeff,weights,2);
        if any(~isfinite(selfint.SS))
            [coeff,weights]=em.EmStructures.gausstri(7,5);
            selfint=em.EmStructures.calc_integral_c(p,t(1:3,:),...
            metalbasis.Center,metalbasis.Area,metalbasis.Normal,...
            metalbasis.facesize,coeff,weights,2);
        end
    else

        if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
            (TetrahedraTotal==0)
            if obj.MesherStruct.infGPconnected
                [coeff,weights]=em.EmStructures.gausstri(7,5);
                selfint=em.EmStructures.calc_integral_igp_conn_c(p,...
                t(1:3,:),metalbasis.Center,metalbasis.Area,...
                metalbasis.Normal,metalbasis.facesize,coeff,...
                weights,2);
            else
                selfint=em.EmStructures.calc_integral_igp_c(p,...
                t(1:3,:),metalbasis.Center,metalbasis.Area,...
                metalbasis.Normal,metalbasis.facesize,coeff,...
                weights,2);
            end
        else

            selfint=em.EmStructures.calc_integral_c(p,t(1:3,:),...
            metalbasis.Center,metalbasis.Area,metalbasis.Normal,...
            metalbasis.facesize,coeff,weights,2);
            if any(~isfinite(selfint.SS))
                [coeff,weights]=em.EmStructures.gausstri(7,5);
                selfint=em.EmStructures.calc_integral_c(p,t(1:3,:),...
                metalbasis.Center,metalbasis.Area,...
                metalbasis.Normal,metalbasis.facesize,coeff,...
                weights,2);
            end
        end
    end

end
