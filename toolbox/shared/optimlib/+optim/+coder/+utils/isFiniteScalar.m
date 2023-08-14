function tf=isFiniteScalar(v)







%#codegen
%#internal
    coder.allowpcode('plain');
    coder.inline('always');
    validateattributes(v,{'double'},{'scalar'});

    if coder.target('MATLAB')||eml_option('NonFinitesSupport')
        tf=isfinite(v);
    else
        tf=abs(v)<optim.coder.infbound;
    end
end