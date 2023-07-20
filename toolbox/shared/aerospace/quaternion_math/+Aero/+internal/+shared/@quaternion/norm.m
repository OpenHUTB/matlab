function qout=norm(q)%#codegen





    if any(~isreal(q(:)))
        error(message('aerospace:quatnorm:isNotReal'));
    end

    if(size(q,2)~=4)
        error(message('aerospace:quatnorm:wrongDimension'));
    end

    qout=sum(q.^2,2);

end

