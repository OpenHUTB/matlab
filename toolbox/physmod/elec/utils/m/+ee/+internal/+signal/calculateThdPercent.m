function thdPercent=calculateThdPercent(harmonicOrder,harmonicMagnitude)







    validateattributes(harmonicOrder,{'numeric'},{'real','integer','nonnegative','increasing'},mfilename,'harmonicOrder',1);
    validateattributes(harmonicMagnitude,{'numeric'},{'real','nonnegative'},mfilename,'harmonicMagnitude',2);


    if any(size(harmonicOrder)~=size(harmonicMagnitude))
        pm_error('physmod:simscape:compiler:patterns:checks:LengthEqualLength','harmonicOrder','harmonicMagnitude');
    end


    if~isfloat(harmonicOrder)
        harmonicOrder=double(harmonicOrder);
    end
    if~isfloat(harmonicMagnitude)
        harmonicMagnitude=double(harmonicMagnitude);
    end


    harmonicMagnitude_rms=harmonicMagnitude./sqrt(2);


    fundamentalMagnitude_rms=harmonicMagnitude_rms(harmonicOrder==1);


    higherHarmonicMagnitude_rms=harmonicMagnitude_rms(harmonicOrder>1);


    thdPercent=100*sqrt(sum(higherHarmonicMagnitude_rms.^2))/fundamentalMagnitude_rms;
end