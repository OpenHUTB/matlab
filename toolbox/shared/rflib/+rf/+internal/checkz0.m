function checkz0(newZ)

    validateattributes(newZ,{'numeric'},{'nonempty','scalar','finite'},...
    '','Impedance')
    if imag(newZ)==0
        newZ=real(newZ);
    end
    validateattributes(newZ,{'numeric'},{'real','positive'},'','Impedance')
