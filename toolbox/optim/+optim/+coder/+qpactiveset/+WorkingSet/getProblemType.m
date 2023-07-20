function type=getProblemType(obj)












%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    validateattributes(obj,{'struct'},{'scalar'});

    type=obj.probType;
end

