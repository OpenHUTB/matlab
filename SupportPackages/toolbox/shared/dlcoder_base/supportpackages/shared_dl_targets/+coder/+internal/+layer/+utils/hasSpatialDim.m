function res=hasSpatialDim(fmt)




%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(fmt)

    res=coder.const(@feval,'contains',fmt,'S');
end