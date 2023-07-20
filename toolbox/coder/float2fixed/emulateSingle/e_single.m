%#codegen

function sf=e_single(value)
    coder.allowpcode('plain');
    coder.inline('always');

    if isfi(value)
        sf=fi2sflt(value);
    else
        sf=dec2sflt(value);
    end
end

function f=dec2sflt(d)
    coder.inline('always');

    bits=typecast(d,'uint32');
    f=fi(reinterpretcast(bits,numerictype(0,32,0)),hdlfimath);
end
