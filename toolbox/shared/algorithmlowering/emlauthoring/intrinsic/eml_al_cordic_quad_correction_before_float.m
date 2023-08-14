function[negate,angle]=eml_al_cordic_quad_correction_before_float(theta)



%#codegen




    coder.allowpcode('plain')
    eml_assert(isfloat(theta));

    if isa(theta,'double')
        [angle,negate]=...
        eml_al_cordic_quad_corr_before_shared(...
        theta,pi/2,pi,...
        (theta-(2*pi)),(theta+(2*pi)),...
        true);
    elseif isa(theta,'single')
        [angle,negate]=...
        eml_al_cordic_quad_corr_before_shared(...
        theta,single(pi/2),single(pi),...
        (theta-single(2*pi)),(theta+single(2*pi)),...
        true);
    end

end
