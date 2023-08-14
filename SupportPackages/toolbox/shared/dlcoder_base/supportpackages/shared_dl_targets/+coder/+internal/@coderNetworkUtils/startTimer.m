function timer=startTimer(isProfilingEnabled)











%#codegen
    coder.inline('always');
    coder.allowpcode('plain');

    coder.internal.prefer_const(isProfilingEnabled);

    if coder.const(isProfilingEnabled)
        timer=tic;
    else
        timer=0;
    end
end
