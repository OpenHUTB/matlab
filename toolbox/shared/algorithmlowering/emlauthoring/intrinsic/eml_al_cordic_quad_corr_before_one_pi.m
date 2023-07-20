function[th_out,negate]=eml_al_cordic_quad_corr_before_one_pi(theta,piOverTwo,onePi,thetaValuesCanBeNegative)



%#codegen

    coder.allowpcode('plain')
    eml_prefer_const(theta,piOverTwo,onePi,thetaValuesCanBeNegative);


    if theta>piOverTwo

        th_out=theta-onePi;
        negate=true;
    elseif(thetaValuesCanBeNegative&&(theta<(-piOverTwo)))

        th_out=theta+onePi;
        negate=true;
    else

        th_out=theta;
        negate=false;
    end

end
