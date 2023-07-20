function x=midiScaleToRaw(x)



    assert(isa(x,'double')&&isscalar(x)&&isreal(x));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        x=midimexif('midiScaleToRaw',x);
    else

        x=coder.ceval('scaleToRawCpp',x);
    end
end
