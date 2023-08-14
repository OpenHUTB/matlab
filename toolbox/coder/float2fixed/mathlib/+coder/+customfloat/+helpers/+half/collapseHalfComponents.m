%#codegen





function x_half=collapseHalfComponents(Sign,Exponent,Mantissa)
    coder.allowpcode('plain');

    x_half=bitor(bitor(bitshift(Sign,15),bitshift(Exponent,10)),Mantissa);
end

