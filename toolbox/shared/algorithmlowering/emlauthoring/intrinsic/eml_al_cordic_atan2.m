function theta=eml_al_cordic_atan2(y,x,numIters,inputLUT)

%#codegen

    coder.allowpcode('plain');

    eml_prefer_const(y);
    eml_prefer_const(x);
    eml_prefer_const(numIters);
    eml_prefer_const(inputLUT);

    theta=eml_al_cordic_cart2pol(x,y,numIters,inputLUT,false,0);

end
