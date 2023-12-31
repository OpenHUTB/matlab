function filterOrder=filtOrder(mwsv,Wratio)


    validateattributes(mwsv.StopbandAttenuation,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Stopband attenuation')
    if mwsv.StopbandAttenuation<=mwsv.PassbandAttenuation
        error(message('rf:rffilter:InvalidAtten',...
        num2str(mwsv.StopbandAttenuation),...
        num2str(mwsv.PassbandAttenuation)));
    end
    filterOrder=ceil(log10((10^(mwsv.StopbandAttenuation/10)-1)/...
    (10^(mwsv.PassbandAttenuation/10)-1))/(2*log10(Wratio)));
end