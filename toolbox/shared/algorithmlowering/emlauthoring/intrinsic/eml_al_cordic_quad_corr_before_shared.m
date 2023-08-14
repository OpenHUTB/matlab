function[th_out,negate]=eml_al_cordic_quad_corr_before_shared(theta,piOverTwo,onePi,thetaMinusTwoPi,thetaPlusTwoPi,thetaValuesCanBeNegative)



%#codegen

    coder.allowpcode('plain')
    eml_prefer_const(theta,piOverTwo,onePi,thetaMinusTwoPi,thetaPlusTwoPi,thetaValuesCanBeNegative);


    if theta>piOverTwo





        if(theta-onePi)<=piOverTwo
            th_out=theta-onePi;
            negate=true;
        else

            th_out=thetaMinusTwoPi;
            negate=false;
        end
    elseif(thetaValuesCanBeNegative&&(theta<(-piOverTwo)))





        if(theta+onePi)>=(-piOverTwo)
            th_out=theta+onePi;
            negate=true;
        else

            th_out=thetaPlusTwoPi;
            negate=false;
        end
    else

        th_out=theta;
        negate=false;
    end

end
