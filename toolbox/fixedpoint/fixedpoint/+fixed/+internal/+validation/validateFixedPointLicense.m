function validateFixedPointLicense()




%#codegen

    coder.allowpcode('plain');

    if coder.target('MATLAB')
        if~license('checkout','fixed_point_toolbox')
            error(message('fixed:fi:licenseCheckoutFailed'));
        end
    else
        coder.license('checkout','fixed_point_toolbox');
    end

end