function designData=filt_designpars(mwsv)
























    orderGiven=mwsv.UseFilterOrder;
    if orderGiven
        validateattributes(mwsv.FilterOrder,{'numeric'},...
        {'nonempty','scalar','integer','>=',2,'<=',60},...
        mfilename,'Filter order');
        filterOrder=mwsv.FilterOrder;
    end

    switch lower(mwsv.ResponseType)
    case 'lowpass'
        Wp=mwsv.PassFreq_lp*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','scalar','finite','real','positive'},...
        mfilename,'Passband frequency')
        if~orderGiven
            Ws=mwsv.StopFreq_lp*(2*pi);
            validateattributes(Ws,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband frequency')
            validateattributes(Ws-Wp,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Stopband frequency must be greater ',...
            'than Passband frequency'])
            Wratio=Ws/Wp;
        end

    case 'highpass'
        Wp=mwsv.PassFreq_hp*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','scalar','finite','real','positive'},...
        mfilename,'Passband frequency')
        if~orderGiven
            Ws=mwsv.StopFreq_hp*(2*pi);
            validateattributes(Ws,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband frequency')
            validateattributes(Wp-Ws,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Passband frequency must be greater ',...
            'than Stopband frequency'])
            Wratio=Wp/Ws;
        end

    case 'bandpass'
        designData.Auxiliary.Wx=1;
        Wp=mwsv.PassFreq_bp*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','size',[1,2],'finite','real','positive',...
        'increasing'},mfilename,'Passband frequencies')
        if~orderGiven
            Ws=mwsv.StopFreq_bp*(2*pi);
            validateattributes(Ws,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Stopband frequencies')
            if Wp(1)<Ws(1)
                error(message('rf:rffilter:InvalidBandPassLeft'))
            elseif Ws(2)<Wp(2)
                error(message('rf:rffilter:InvalidBandPassRight'))
            end
            validateattributes(Wp(1)-Ws(1),{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Left Passband frequency must be greater ',...
            'than Left Stopband frequency'])
            validateattributes(Ws(2)-Wp(2),{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Right Stopband frequency must be greater ',...
            'than Right Passband frequency'])
            Wratio1=abs((Wp(1)*Wp(2)-Ws(1)^2)/(Ws(1)*Wp(2)-Ws(1)*Wp(1)));
            Wratio2=abs((Wp(1)*Wp(2)-Ws(2)^2)/(Ws(2)*Wp(2)-Ws(2)*Wp(1)));
            Wratio=min(Wratio1,Wratio2);
        end

    case 'bandstop'
        Ws=mwsv.StopFreq_bs*(2*pi);
        validateattributes(Ws,{'numeric'},...
        {'nonempty','size',[1,2],'finite','real','positive',...
        'increasing'},mfilename,'Stopband frequencies')
        if~orderGiven
            Wp=mwsv.PassFreq_bs*(2*pi);
            validateattributes(Wp,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Passband frequencies')
            if Ws(1)<Wp(1)
                error(message('rf:rffilter:InvalidBandStopLeft'))
            elseif Wp(2)<Ws(2)
                error(message('rf:rffilter:InvalidBandStopRight'))
            end
            validateattributes(Ws(1)-Wp(1),{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Left Stopband frequency must be greater ',...
            'than Left Passband frequency'])
            validateattributes(Wp(2)-Ws(2),{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,['Right Passband frequency must be greater ',...
            'than Right Stopband frequency'])
            Wratio1=abs((Ws(1)*Ws(2)-Wp(1)^2)/(Wp(1)*Ws(2)-Wp(1)*Ws(1)));
            Wratio2=abs((Ws(1)*Ws(2)-Wp(2)^2)/(Wp(2)*Ws(2)-Wp(2)*Ws(1)));
            Wratio=min(Wratio1,Wratio2);
        end
    end

    if~orderGiven

        filterOrder=filtOrder(mwsv,Wratio);
    end


    scale3dB=(10^(mwsv.PassbandAttenuation/10)-1)^(-1/(2*filterOrder));
    switch lower(mwsv.ResponseType)
    case 'lowpass'
        Wp=Wp*scale3dB;
    case 'highpass'
        Wp=Wp/scale3dB;
    case 'bandpass'
        designData.Auxiliary.Wx=scale3dB;
    case 'bandstop'
        designData.Auxiliary.Wx=designWx(mwsv,filterOrder);
    end


    if strcmpi(mwsv.ResponseType,'bandstop')
        designData.Ws=Ws;
    else
        designData.Wp=Wp;
    end

    if filterOrder>60
        error(message('rf:rffilter:FilterOrderCalTooBig'))
    end
    designData.FilterOrder=filterOrder;

end












