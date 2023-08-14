function str=getStrFromNum(num)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(num);
    coder.extrinsic('sldvprivate');
    str=coder.const(sldvprivate('getStrFromNum',num));
end
