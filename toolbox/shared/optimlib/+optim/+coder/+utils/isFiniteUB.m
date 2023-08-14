function tf=isFiniteUB(ub)























%#codegen
%#internal
    coder.allowpcode('plain');
    coder.inline('always');
    validateattributes(ub,{'double'},{'scalar'});

    if coder.target('MATLAB')||eml_option('NonFinitesSupport')
        tf=isfinite(ub);
    else
        tf=ub<optim.coder.infbound;
    end
end