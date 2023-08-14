function coefTable=reshapeFilterCoef(this,FilterCoefficients,NumFrequencyBands)




    numOfCoef=length(FilterCoefficients);
    zeroPadLen=NumFrequencyBands-mod(numOfCoef,NumFrequencyBands);
    if zeroPadLen==NumFrequencyBands
        coef_zeroPad=FilterCoefficients;
    elseif isnumeric(FilterCoefficients)
        coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1,'like',FilterCoefficients)];
    else
        coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1)];
    end

    NumTaps=length(coef_zeroPad)/NumFrequencyBands;
    coef_reshape=reshape(coef_zeroPad,NumFrequencyBands,NumTaps);
    coefTable=flipud(coef_reshape);

end
