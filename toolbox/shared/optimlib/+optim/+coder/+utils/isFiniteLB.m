function tf=isFiniteLB(lb)























%#codegen
%#internal
    coder.allowpcode('plain');
    coder.inline('always');
    validateattributes(lb,{'double'},{'scalar'});

    if coder.target('MATLAB')||eml_option('NonFinitesSupport')
        tf=isfinite(lb);
    else
        tf=lb>-optim.coder.infbound;
    end
end