function x=midiScaleFromRaw(x)



    assert(isa(x,'double')&&isscalar(x)&&isreal(x));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        x=midimexif('midiScaleFromRaw',x);
    else

        x=coder.ceval('scaleFromRawCpp',x);
    end
end
