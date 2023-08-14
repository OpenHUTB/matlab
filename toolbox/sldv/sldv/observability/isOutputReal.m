function flag=isOutputReal(blockH)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    flag=coder.const(sldvprivate('isOutputPortReal',blockH));
end
