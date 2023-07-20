%#codegen


function r=dts_preconditioning_isa(val,cls)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('always');
    eml_prefer_const(val,cls);
    r=isa(val,cls);
    if eml_is_const(cls)&&strcmp(cls,'double')
        coder.internal.assert(false,'Coder:FXPCONV:DTS_IsaDoubleTypeNotValid');
    end
end


