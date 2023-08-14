function qmod=mod(q)%#codegen





    if any(~isreal(q(:)))
        error(message('aerospace:quatnorm:isNotReal'));
    end

    if(size(q,2)~=4)
        error(message('aerospace:quatnorm:wrongDimension'));
    end

    qmod=sqrt(Aero.internal.shared.quaternion.norm(q));

end