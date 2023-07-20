function Wx=designWx(mwsv,filterOrder)


    validateattributes(mwsv.StopbandAttenuation,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Stopband attenuation')
    Wx=(10^(mwsv.StopbandAttenuation/10)-1)^(1/(2*filterOrder));
end