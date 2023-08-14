function res=hasTwoSpatialDims(fmt)




%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(fmt)

    res=coder.const(@feval,'count',fmt,'S')==2;
end