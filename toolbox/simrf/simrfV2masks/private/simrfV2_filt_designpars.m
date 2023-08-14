function designData=simrfV2_filt_designpars(mwsv)

























    validateattributes(mwsv.Rsrc,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Source impedance')
    validateattributes(mwsv.Rload,{'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    mfilename,'Load impedance')

    orderGiven=strcmpi(mwsv.UseFilterOrder,'on');
    if orderGiven
        validateattributes(mwsv.FilterOrder,{'numeric'},...
        {'nonempty','scalar','integer','>=',2,'<=',60},...
        mfilename,'Filter order');
        filterOrder=mwsv.FilterOrder;
    end

    switch lower(mwsv.ResponseType)
    case 'lowpass'
        Wp=simrfV2convert2baseunit(mwsv.PassFreq_lp,...
        mwsv.PassFreq_lp_unit)*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','scalar','finite','real','positive'},...
        mfilename,'Passband frequency')
        if~orderGiven
            Ws=simrfV2convert2baseunit(mwsv.StopFreq_lp,...
            mwsv.StopFreq_lp_unit)*(2*pi);
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
        Wp=simrfV2convert2baseunit(mwsv.PassFreq_hp,...
        mwsv.PassFreq_hp_unit)*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','scalar','finite','real','positive'},...
        mfilename,'Passband frequency')
        if~orderGiven
            Ws=simrfV2convert2baseunit(mwsv.StopFreq_hp,...
            mwsv.StopFreq_hp_unit)*(2*pi);
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


        designData.Wx=1;
        Wp=simrfV2convert2baseunit(mwsv.PassFreq_bp,...
        mwsv.PassFreq_bp_unit)*(2*pi);
        validateattributes(Wp,{'numeric'},...
        {'nonempty','size',[1,2],'finite','real','positive',...
        'increasing'},mfilename,'Passband frequencies')
        if~orderGiven
            Ws=simrfV2convert2baseunit(mwsv.StopFreq_bp,...
            mwsv.StopFreq_bp_unit)*(2*pi);
            validateattributes(Ws,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Stopband frequencies')
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
        Ws=simrfV2convert2baseunit(mwsv.StopFreq_bs,...
        mwsv.StopFreq_bs_unit)*(2*pi);
        validateattributes(Ws,{'numeric'},...
        {'nonempty','size',[1,2],'finite','real','positive',...
        'increasing'},mfilename,'Stopband frequencies')
        if~orderGiven
            Wp=simrfV2convert2baseunit(mwsv.PassFreq_bs,...
            mwsv.PassFreq_bs_unit)*(2*pi);
            validateattributes(Wp,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Passband frequencies')
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
    otherwise
        error('Unknown responseType %s%s\n.',mwsv.ResponseType,...
        'Allowed types are lowpass highpass bandpass bandstop')
    end

    designMethod=lower(mwsv.DesignMethod);
    switch designMethod
    case 'butterworth'
        if~orderGiven

            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            validateattributes(mwsv.StopAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')
            filterOrder=ceil(log10((10^(mwsv.StopAtten/10)-1)/...
            (10^(mwsv.PassAtten/10)-1))/(2*log10(Wratio)));
        end


        switch lower(mwsv.ResponseType)
        case 'lowpass'
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            scale3dB=(10^(mwsv.PassAtten/10)-1)^(-1/(2*filterOrder));
            Wp=Wp*scale3dB;
        case 'highpass'
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            scale3dB=(10^(mwsv.PassAtten/10)-1)^(-1/(2*filterOrder));
            Wp=Wp/scale3dB;
        case 'bandpass'
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            scale3dB=(10^(mwsv.PassAtten/10)-1)^(-1/(2*filterOrder));
            designData.Auxiliary.Wx=scale3dB;
        case 'bandstop'
            validateattributes(mwsv.StopAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')
            designData.Auxiliary.Wx=...
            (10^(mwsv.StopAtten/10)-1)^(1/(2*filterOrder));
        end

    case{'chebyshev','inversechebyshev'}
        if~orderGiven
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            validateattributes(mwsv.StopAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')

            tenRp=10^(mwsv.PassAtten/10);
            tenRs=10^(mwsv.StopAtten/10);
            filterOrder=ceil(...
            log(sqrt((tenRs-1)/(tenRp-1))+sqrt((tenRs-tenRp)/(tenRp-1)))/...
            log(Wratio+sqrt(Wratio*Wratio-1)));
        end
        if strcmpi(mwsv.ResponseType,'bandstop')
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            validateattributes(mwsv.StopAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')
            tenRp=10^(mwsv.PassAtten/10);
            epsilon2=(tenRp-1);
            Mag2=10^(-1*mwsv.StopAtten/10);
            k2=(1-Mag2)/(Mag2*epsilon2);
            k2m1=sqrt(k2-1);
            k=sqrt(k2);
            expon=exp((1/filterOrder)*log(k+k2m1));
            designData.Auxiliary.Wx=(expon+1/expon)/2;
        end

    case 'elliptic'




        L2=(10^(mwsv.StopAtten/10)-1)/(10^(mwsv.PassAtten/10)-1);
        OverL2=1/L2;
        OneMOverL2=(L2-1)/L2;
        L2periods=ellipke(OverL2)/ellipke(OneMOverL2);
        if~orderGiven
            validateattributes(mwsv.PassAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            validateattributes(mwsv.StopAtten,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')


            Wratio2=Wratio^2;
            OverWratio2=1/Wratio2;


            OneMOverWratio2=(Wratio2-1)/Wratio2;


            filterOrder=ceil(...
            ellipke(OverWratio2)/(ellipke(OneMOverWratio2)*L2periods));
        end



        opts=optimset('MaxIter',1e4,'MaxFunEvals',1e4,...
        'TolFun',1e-14,'TolX',1e-14);
        [xSol,sse,exitflag,output]=...
        fminsearch(@(x)findWx(x,filterOrder*L2periods),Wratio,opts);

        OverxSol2=1/xSol^2;
        checkN=ellipke(OverxSol2)/(ellipke(1-OverxSol2)*L2periods);
        designData.Wx=xSol;

    case{'besself','besseldn','besselfn','ellipa','ellipb','ellipc','ellips'}
    end


    if strcmpi(mwsv.ResponseType,'bandstop')
        designData.Ws=Ws;
    else
        designData.Wp=Wp;
    end


    if strcmpi(mwsv.Implementation,'Transfer function')&&...
        filterOrder>30
        if strcmpi(mwsv.UseFilterOrder,'on')
            error(message('simrf:simrfV2errors:FilterOrderTooLarge'));
        else
            error(message('simrf:simrfV2errors:FilterOrderCalTooLarge'))
        end
    end

    if filterOrder>60
        error(message('simrf:simrfV2errors:FilterOrderCalTooBig'))
    end
    designData.FilterOrder=filterOrder;

end



function sse=findWx(parWx,L2Cnst)
    if parWx<=1
        sse=1e30;
    else
        parWx2=parWx^2;
        invWx2=1/parWx2;
        sse=(L2Cnst-ellipke(invWx2)/ellipke((parWx2-1)/parWx2))^2;
    end
end
