function[needToNegate,theta_in_range]=eml_al_cordic_quad_correction_before(theta,K)%#ok<INUSD> 

%#codegen
    coder.allowpcode('plain')
    [theta_in_range,needToNegate]=fixed.internal.cordiccexpInputQuadrantCorrection(theta);
end