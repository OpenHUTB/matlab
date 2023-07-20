function flag=isCheckEnabled(checkName)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(checkName);
    coder.extrinsic('sldvprivate');
    flag=coder.const(sldvprivate('isBlockCondCheckEnabled',checkName));
end
