function sf=cordic_compute_gain(niters)







%#codegen

    coder.allowpcode('plain');

    if~isempty(coder.target)
        eml_prefer_const(niters);
    end

    intArray=(0:(double(niters)-1))';
    sf=prod(sqrt(1+2.^(-2*intArray)));

end

