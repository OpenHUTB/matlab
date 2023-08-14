function setSpectrumSidedType(obj)




    if obj.pIsDownConverterEnabled




        obj.pIsCurrentSpectrumTwoSided=true;
    elseif obj.TwoSidedSpectrum
        obj.pIsCurrentSpectrumTwoSided=true;
    else
        obj.pIsCurrentSpectrumTwoSided=false;
    end
end
