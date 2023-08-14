function Wx=designWx(mwsv,filterOrder)



    validateattributes(mwsv.PassbandAttenuation,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Passband attenuation')
    validateattributes(mwsv.StopbandAttenuation,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Stopband attenuation')
    if mwsv.StopbandAttenuation<mwsv.PassbandAttenuation
        error(message('rf:rffilter:InvalidAtten',...
        num2str(mwsv.StopbandAttenuation),...
        num2str(mwsv.PassbandAttenuation)));
    end
    tenRp=10^(mwsv.PassbandAttenuation/10);
    epsilon2=(tenRp-1);
    Mag2=10^(-1*mwsv.StopbandAttenuation/10);
    k2=(1-Mag2)/(Mag2*epsilon2);
    k2m1=sqrt(k2-1);
    k=sqrt(k2);
    expon=exp((1/filterOrder)*log(k+k2m1));
    Wx=(expon+1/expon)/2;
end
