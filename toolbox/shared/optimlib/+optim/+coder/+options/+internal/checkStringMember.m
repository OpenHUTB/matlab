function valid=checkStringMember(v,validValues)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    if coder.internal.isCharOrScalarString(v)
        valid=any(strcmp(v,validValues));
    else
        valid=false;
    end

end