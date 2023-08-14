function n=rotate(q,r)%#codegen





    if any(~isreal(q(:)))
        error(message('aerospace:quatrotate:isNotReal1'));
    end

    if(size(q,2)~=4)
        error(message('aerospace:quatrotate:wrongDimension1'));
    end

    if any(~isreal(r(:)))
        error(message('aerospace:quatrotate:isNotReal2'));
    end

    if(size(r,2)~=3)
        error(message('aerospace:quatrotate:wrongDimension2'));
    end

    if(size(r,1)~=size(q,1)&&~(size(r,1)==1||size(q,1)==1))
        error(message('aerospace:quatrotate:wrongDimension3'));
    end

    dcm=Aero.internal.shared.quaternion.toDCM(q);

    if(size(q,1)==1)

        n=(dcm*r')';
    elseif(size(r,1)==1)

        n=squeeze(pagemtimes(dcm,r'))';
    else

        n=squeeze(pagemtimes(dcm,permute(r,[2,3,1])))';
    end

end
