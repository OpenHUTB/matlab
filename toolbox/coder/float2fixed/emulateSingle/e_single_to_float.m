%#codegen

function d=e_single_to_float(value)
    coder.allowpcode('plain');
    coder.inline('always');

    d=typecast(storedInteger(value),'single');
end
