function val=getDoubleFromString(str)
    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(str);
    coder.extrinsic('sldvprivate');
    val=coder.const(sldvprivate('getDoubleFromString',str));
end

