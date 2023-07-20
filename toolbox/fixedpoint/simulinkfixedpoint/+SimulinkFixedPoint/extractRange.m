function range=extractRange(val)
    rangeVec=double(val(:));

    if~isreal(rangeVec)
        realVec=real(rangeVec);
        imagVec=imag(rangeVec);

        range=[realVec;imagVec];
    else
        range=rangeVec;
    end
end