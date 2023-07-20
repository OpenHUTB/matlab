function val=RatioTestTolerances(cname)














%#codegen

    coder.allowpcode('plain');

    switch cname


    case 'MaxLPStepSize'
        val=realmax('double');
    case 'MaxQPStepSize'
        val=double(1.0);
    case 'MaxStepSize'
        val=double(1e30);
    case 'ErrNorm'
        val=1e3*eps('double');


    case 'DeltaF'
        val=eps('double')^(3/8);
    case 'K'
        val=coder.internal.indexInt(round(eps('double')^(-1/4)));
    case 'Delta0'
        val=0.5*eps('double')^(3/8);
    case 'DeltaK'
        val=0.99*eps('double')^(3/8);
    case 'tau'
        val=(0.99-0.5)*eps('double')^(3/8);
    otherwise
        assert(false,'qpactiveset_RatioTestTolerances unexpected input');
    end

end

