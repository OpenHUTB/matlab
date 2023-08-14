function qout=conj(qin)%#codegen





    if any(~isreal(qin(:)))
        error(message('aerospace:quatconj:isNotReal'));
    end

    if(size(qin,2)~=4)
        error(message('aerospace:quatconj:wrongDimension'));
    end

    qout=[qin(:,1),-qin(:,2:4)];

end
