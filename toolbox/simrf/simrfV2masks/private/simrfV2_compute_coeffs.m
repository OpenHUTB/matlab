function[nl_params_str,SrcBlk,Srclib,DstBlk]=...
    simrfV2_compute_coeffs(block,isTimeDomainFit,TreatAsLinear,...
    Single_Sparam)
    MaskVals=get_param(block,'MaskValues');
    MaskWSValues=simrfV2getblockmaskwsvalues(block);
    idxMaskNames=simrfV2getblockmaskparamsindex(block);

    Udata=get_param([block,'/AuxData'],'UserData');
    SourceAmpGain=MaskVals{idxMaskNames.Source_linear_gain};


    switch SourceAmpGain
    case 'Polynomial coefficients'
        validateattributes(MaskWSValues.Poly_Coeffs,{'numeric'},...
        {'nonempty','vector','finite','real'},'',...
        'Polynomial coefficients');
        if length(MaskWSValues.Poly_Coeffs)>10
            error(message('simrf:simrfV2errors:BadParamValues',...
            'More than ten',block,'Polynomial coefficients'))
        end

        poly_coeffs=2*MaskWSValues.Poly_Coeffs;

    otherwise

        if strcmpi(SourceAmpGain,'Data source')


            if(MaskWSValues.SetOpFreqAsMaxS21)
                [lin_Vgain,freq_used]=...
                get_sparam_vgain(Udata.Spars.Parameters,...
                Udata.Spars.Frequencies);
                lin_Vgain=2*lin_Vgain;
            else
                OpFreq=simrfV2convert2baseunit(MaskWSValues.OpFreq,...
                MaskWSValues.OpFreq_unit);
                [lin_Vgain,freq_used]=...
                get_sparam_vgain(Udata.Spars.Parameters,...
                Udata.Spars.Frequencies,OpFreq);
                lin_Vgain=2*lin_Vgain;
            end
            if isTimeDomainFit&&~(MaskWSValues.ConstS21NL)
                cacheData=get_param(block,'UserData');
                spars=simrfV2_sparm_from_ratmodel(cacheData.RationalModel,2,...
                freq_used);
                lin_Vgain=2*abs(spars(2,1));
            end

            if strcmpi(MaskVals{idxMaskNames.DataSource},'Data file')
                Zin=Udata.Spars.Impedance;
            else
                Zin=MaskWSValues.SparamZ0;
            end
            Zout=Zin;
        else
            Zin=MaskWSValues.Zin;
            Zout=MaskWSValues.Zout;
            lin_Vgain=get_lin_vgain(SourceAmpGain,...
            MaskWSValues.linear_gain,...
            MaskVals{idxMaskNames.linear_gain_unit},Zin,Zout);
        end

        if strcmpi(SourceAmpGain,'Data source')&&isfield(Udata,'NL')&&...
            Udata.NL.HasNLfileData



            RefTypeIO=MaskVals{idxMaskNames.IPType};
            poly_coeffs=compute_coeffs_odd(lin_Vgain,RefTypeIO,...
            Udata.NL.IP3,Udata.NL.P1dB,Udata.NL.Psat,Udata.NL.GCS,...
            Zin,Zout);
        elseif strcmpi(MaskVals{idxMaskNames.Source_Poly},'Odd order')
            check_ip(MaskWSValues.IP3,MaskVals{idxMaskNames.IP3_unit},'IP3');
            check_ip(MaskWSValues.P1dB,...
            MaskVals{idxMaskNames.P1dB_unit},'P1dB');
            check_ip(MaskWSValues.Psat,MaskVals{idxMaskNames.Psat_unit},...
            'Psat');
            check_ip(MaskWSValues.Gcomp,MaskVals{idxMaskNames.Gcomp_unit},...
            'Gcomp');

            RefTypeIO=MaskVals{idxMaskNames.IPType};
            poly_coeffs=compute_coeffs_odd(lin_Vgain,RefTypeIO,...
            simrfV2_convert2watts(MaskWSValues.IP3,...
            MaskVals{idxMaskNames.IP3_unit}),...
            simrfV2_convert2watts(MaskWSValues.P1dB,...
            MaskVals{idxMaskNames.P1dB_unit}),...
            simrfV2_convert2watts(MaskWSValues.Psat,...
            MaskVals{idxMaskNames.Psat_unit}),...
            simrfV2_convert2watts(MaskWSValues.Gcomp,...
            MaskVals{idxMaskNames.Gcomp_unit}),Zin,Zout);
        else
            check_ip(MaskWSValues.IP3,MaskVals{idxMaskNames.IP3_unit},'IP3');
            check_ip(MaskWSValues.IP2,MaskVals{idxMaskNames.IP2_unit},'IP2');
            IPs=[MaskWSValues.IP2,MaskWSValues.IP3];
            IPs_unit={MaskVals{idxMaskNames.IP2_unit}...
            ,MaskVals{idxMaskNames.IP3_unit}};

            if any(isfinite(IPs))
                poly_coeffs=compute_ip_coeffs(lin_Vgain,...
                MaskVals{idxMaskNames.IPType},IPs,IPs_unit,Zin,Zout);
            else
                poly_coeffs=[0,lin_Vgain];
            end
        end

    end
    [nl_params_str,SrcBlk,Srclib,DstBlk]=setModelPars(...
    poly_coeffs,isTimeDomainFit,TreatAsLinear,Single_Sparam);
end


function lin_Vgain=get_lin_vgain(SrcAmpGain,gain,gain_unit,Zin,Zout)
    validateattributes(gain,{'numeric'},...
    {'nonempty','scalar','finite','real'},'','Amplifier gain');

    switch SrcAmpGain
    case 'Available power gain'
        if isinf(real(Zin))||real(Zin)==0
            error(message('simrf:simrfV2errors:NLpower','Zin'))
        end
        if isinf(real(Zout))||real(Zout)==0
            error(message('simrf:simrfV2errors:NLpower','Zout'))
        end

        if strcmp(gain_unit,'dB')
            gain=10^(gain/10);
        end
        sign_gain=sign(gain);
        lin_Vgain=sign_gain*sqrt(abs(gain))*2*...
        sqrt(real(Zout)*real(Zin))/abs(Zin);
    case 'Open circuit voltage gain'

        if strcmp(gain_unit,'dB')
            gain=10^(gain/20);
        end
        lin_Vgain=gain;
    end
end

function[vgain_max,freq_used]=get_sparam_vgain(sparam,freqs,varargin)

    s21=squeeze(sparam(2,1,:));
    vgain=abs(s21);
    if(nargin>2)
        opFreq=varargin{1};
        if((opFreq>min(freqs))&&(opFreq<max(freqs)))
            vgain_max=interp1(freqs,vgain,opFreq);
            freq_used=opFreq;
        else
            if(opFreq<=min(freqs))
                [~,freqInd]=min(freqs);
            else
                [~,freqInd]=max(freqs);
            end
            vgain_max=vgain(freqInd);
            freq_used=freqs(freqInd);
        end
    else
        [~,idxmax]=max(abs(s21));
        vgain_max=abs(vgain(idxmax));
        freq_used=freqs(idxmax);
    end

    validateattributes(vgain_max,{'numeric'},{'finite'},'','Gain');
end

function[nl_params_str,SrcBlk,Srclib,DstBlk]=setModelPars(...
    poly_coeffs,isTimeDomainFit,TreatAsLinear,Single_Sparam)
    if TreatAsLinear
        if isTimeDomainFit
            Srclib='simrfV2_lib';
            if Single_Sparam
                SrcBlk='simrfV2_lib/Sparameters/D2PORT_RF';
                DstBlk='d2port';
            else
                SrcBlk='simrfV2_lib/Sparameters/S2PORT_RF';
                DstBlk='s2port';
            end
        else
            SrcBlk='simrfV2_lib/Sparameters/F2PORT_RF';
            Srclib='simrfV2_lib';
            DstBlk='f2port';
        end
        nl_params_str='';
    else

        poly_coeffs=poly_coeffs(1:find(poly_coeffs,1,'last'));
        poly_len=length(poly_coeffs);

        poly_coeffs=[poly_coeffs,zeros(1,10-poly_len)];


        poly_norm=poly_coeffs.*...
        [0,1,0,3/4,0,5/8,0,35/64,0,63/128];




        derPoly=polyder(fliplr(poly_norm));
        dpolyRoots=roots(derPoly);

        realRoots=dpolyRoots(imag(dpolyRoots)==0);


        VsatNeg=-min(abs(realRoots(realRoots<0)));

        if isempty(VsatNeg)
            VsatNeg=-inf;
            if mod(poly_len,2)

                VoutNeg=sign(poly_coeffs(poly_len))*inf;
            else

                VoutNeg=-sign(poly_coeffs(poly_len))*inf;
            end
        else
            VoutNeg=polyval(fliplr(poly_coeffs),VsatNeg);
        end


        VsatPlus=min(realRoots(realRoots>0));

        if isempty(VsatPlus)
            VsatPlus=inf;
            VoutPlus=sign(poly_coeffs(poly_len))*inf;
        else
            VoutPlus=polyval(fliplr(poly_coeffs),VsatPlus);
        end


        poly_odd=(poly_coeffs*[1,0,1,0,1,0,1,0,1,0]'==0);
        if poly_odd
            if poly_len==2
                DstBlk='NL_POLY_LINEAR_RF';
            else
                DstBlk=['NL_POLY_ODD',int2str(poly_len-1),'_RF'];
            end
        else
            DstBlk=['NL_POLY_',int2str(poly_len-1),'ORDER_RF'];
        end
        nl_params_str=[{'Poly_Coeffs'},simrfV2vector2str(poly_coeffs)...
        ,'VsatPlus',num2str(VsatPlus,16),'VsatNeg',num2str(VsatNeg,16)...
        ,'VoutPlus',num2str(VoutPlus,16),'VoutNeg',num2str(VoutNeg,16)];
        load_system('simrfV2_lib')
        SrcBlk=['simrfV2_lib/Elements/',DstBlk];
        Srclib='simrfV2_lib';







































    end
end

function poly_coeffs=compute_ip_coeffs(lin_Vgain,...
    IPType,IPs,IPs_unit,Zin,Zout)

    len_ip=length(IPs);
    poly_coeffs=[0,lin_Vgain,zeros(1,len_ip)];
    for ip_idx=1:len_ip
        if isinf(IPs(ip_idx))
            continue
        end
        ip_watts=simrfV2_convert2watts(IPs(ip_idx),IPs_unit{ip_idx});
        poly_coeffs(2+ip_idx)=compute_ip(ip_idx+1,ip_watts,IPType,...
        lin_Vgain,Zin,Zout);
    end
end

function poly_coeff=compute_ip(ip_num,ip_watts,IPType,...
    lin_Vgain,Zin,Zout)
    switch IPType

    case 'Output'

        if isinf(real(Zout))||real(Zout)==0
            error(message('simrf:simrfV2errors:NLpower','Zout'))
        end
        if ip_num==2
            poly_coeff=lin_Vgain^2/sqrt(2*ip_watts*4*real(Zout));
        elseif ip_num==3
            poly_coeff=-(4/3)*lin_Vgain^3/(2*ip_watts*4*real(Zout));
        end
    case 'Input'

        if isinf(real(Zin))||real(Zin)==0
            error(message('simrf:simrfV2errors:NLpower','Zin'))
        end
        if ip_num==2
            poly_coeff=lin_Vgain*sqrt(real(Zin))/...
            (abs(Zin)*sqrt(2*ip_watts));
        elseif ip_num==3
            poly_coeff=-(4/3)*lin_Vgain*real(Zin)/...
            (2*ip_watts*abs(Zin)^2);
        end
    end

























end

function check_ip(inval,inval_unit,param_name)
    if regexpi(inval_unit,'^(W|mW)$')
        validateattributes(inval,{'numeric'},...
        {'nonempty','scalar','nonnan','real','positive'},'',param_name);
    else
        validateattributes(inval,{'numeric'},...
        {'nonempty','scalar','nonnan','real'},'',param_name);
    end
end

function poly_coeffs=compute_coeffs_odd(lin_VGain,RefTypeIO,IP3,...
    P1dB,Psat,GCS,Zin,Zout)

    fh=str2func(['PolyModel',int2str(isfinite([IP3,P1dB,Psat])*[1,2,4]')]);
    A_ipsat=sqrt((2*Psat)/real(Zin))*abs(Zin);
    V0_opsat=2*sqrt(2*Psat*real(Zout));
    A_ip1dB=sqrt((2*P1dB)/real(Zin))*abs(Zin);
    V0_op1dB=2*sqrt(2*P1dB*real(Zout));
    A_op1dB=2*10^(1/20)*sqrt(2*P1dB*real(Zout))/lin_VGain;
    gcs_sr=sqrt(GCS);
    parStruct=struct('RefTypeIO',RefTypeIO,'IP3w',IP3,...
    'A_ipsat',A_ipsat,'V0_opsat',V0_opsat,'A_ip1dB',A_ip1dB,...
    'V0_op1dB',V0_op1dB,'A_op1dB',A_op1dB,'lin_VGain',lin_VGain,...
    'gcs_sr',gcs_sr,'Zin',Zin,'Zout',Zout);
    poly_coeffs=fh(parStruct);
end

function poly_coeffs=PolyModel0(pars)

    c1=pars.lin_VGain;
    poly_coeffs=[0,c1];
end

function poly_coeffs=PolyModel1(pars)

    c1=pars.lin_VGain;
    c3=compute_ip(3,pars.IP3w,pars.RefTypeIO,c1,pars.Zin,pars.Zout);
    poly_coeffs=[0,c1,0,c3];
end

function poly_coeffs=PolyModel2(pars)

    c1=pars.lin_VGain;
    switch pars.RefTypeIO
    case 'Input'
        c3=(2*c1*(10^(19/20)-10))/(15*pars.A_ip1dB^2);
    case 'Output'
        c3=(2*c1*(10^(19/20)-10))/(15*pars.A_op1dB^2);
    end
    poly_coeffs=[0,c1,0,c3];
end

function poly_coeffs=PolyModel3(pars)

    c1=pars.lin_VGain;
    c3=compute_ip(3,pars.IP3w,pars.RefTypeIO,c1,pars.Zin,pars.Zout);
    switch pars.RefTypeIO
    case 'Input'
        c5=-(30*c3*pars.A_ip1dB^2+40*c1-4*10^(19/20)*c1)/...
        (25*pars.A_ip1dB^4);
    case 'Output'
        c5=-(30*c3*pars.A_op1dB^2+40*c1-4*10^(19/20)*c1)/...
        (25*pars.A_op1dB^4);
    end
    poly_coeffs=[0,c1,0,c3,0,c5];
end

function poly_coeffs=PolyModel4(pars)

    c1=pars.lin_VGain;
    gcs_sr=pars.gcs_sr;
    if isinf(gcs_sr)
        switch pars.RefTypeIO
        case 'Input'
            c3=-(4*c1)/(9*pars.A_ipsat^2);
        case 'Output'
            c3=-(16*c1^3)/(81*pars.V0_opsat^2);
        end
        poly_coeffs=[0,c1,0,c3];
    else
        switch pars.RefTypeIO
        case 'Input'
            c3=-(2*c1*(4*gcs_sr-5))/(3*pars.A_ipsat^2*gcs_sr);
            c5=(4*c1*(2*gcs_sr-3))/(5*pars.A_ipsat^4*gcs_sr);
        case 'Output'
            c3=-(2*c1^3*(4*gcs_sr-5))/(3*pars.V0_opsat^2*gcs_sr^3);
            c5=(4*c1^5*(2*gcs_sr-3))/(5*pars.V0_opsat^4*gcs_sr^5);
        end
        poly_coeffs=[0,c1,0,c3,0,c5];
    end
end

function poly_coeffs=PolyModel5(pars)

    c1=pars.lin_VGain;
    c3=compute_ip(3,pars.IP3w,pars.RefTypeIO,c1,pars.Zin,pars.Zout);
    gcs_sr=pars.gcs_sr;
    if isinf(gcs_sr)
        if strcmpi(pars.RefTypeIO,'Input')
            c5=-(2*(9*c3*pars.A_ipsat^2+4*c1))/(25*pars.A_ipsat^4);
        else
            A=roots([3*c3,0,8*c1,-10*pars.V0_opsat]);
            A=A(imag(A)==0);
            A=A(A>0);
            validateattributes(A,{'numeric'},{'nonempty'},mfilename,'A')
            c5=-(4*(3*pars.V0_opsat-2*A*c1))./(5*A.^5);
            c5=min(c5);
            validateattributes(c5,{'numeric'},{'nonempty','<',0},...
            mfilename,'c5')
        end
        poly_coeffs=[0,c1,0,c3,0,c5];
    else
        if strcmpi(pars.RefTypeIO,'Input')
            c5=-(4*(3*c3*gcs_sr*pars.A_ipsat^2-7*c1+6*c1*gcs_sr))/...
            (5*pars.A_ipsat^4*gcs_sr);
            c7=(16*(3*c3*gcs_sr*pars.A_ipsat^2-10*c1+8*c1*gcs_sr))/...
            (35*pars.A_ipsat^6*gcs_sr);
        else
            c5=-(4*c1^2*(3*c3*pars.V0_opsat^2*gcs_sr^3+6*c1^3*gcs_sr-...
            7*c1^3))/(5*pars.V0_opsat^4*gcs_sr^5);
            c7=(16*c1^4*(3*c3*pars.V0_opsat^2*gcs_sr^3+8*c1^3*gcs_sr-...
            10*c1^3))/(35*pars.V0_opsat^6*gcs_sr^7);
        end
        poly_coeffs=[0,c1,0,c3,0,c5,0,c7];
    end
end

function poly_coeffs=PolyModel6(pars)

    c1=pars.lin_VGain;
    gcs_sr=pars.gcs_sr;
    if isinf(gcs_sr)
        if strcmpi(pars.RefTypeIO,'Input')
            c3=(2*c1*(10^(19/20)*pars.A_ipsat^4+2*pars.A_ip1dB^4-...
            10*pars.A_ipsat^4))/(15*pars.A_ip1dB^2*pars.A_ipsat^4-...
            9*pars.A_ip1dB^4*pars.A_ipsat^2);
            c5=-(4*c1*(3*10^(19/20)*pars.A_ipsat^2+10*pars.A_ip1dB^2-...
            30*pars.A_ipsat^2))/(125*pars.A_ip1dB^2*pars.A_ipsat^4-...
            75*pars.A_ip1dB^4*pars.A_ipsat^2);
        else
            A=roots(...
            [(2*10^(1/20)*c1^5-2*c1^5),...
            0,...
            (-4*10^(3/20)*pars.V0_op1dB^2*c1^3),...
            (5*10^(3/20)*pars.V0_op1dB^2*pars.V0_opsat*c1^2),...
            (2*10^(1/4)*pars.V0_op1dB^4*c1),...
            (-3*10^(1/4)*pars.V0_op1dB^4*pars.V0_opsat)]);
            A=A(imag(A)==0);
            A=A(A>0);
            validateattributes(A,{'numeric'},{'nonempty'},mfilename,'A')
            c5=(4*c1^2*(10^(19/20)*A.^3*c1^3-...
            15*pars.V0_opsat*A.^2*c1^2+...
            5*2^(1/10)*5^(1/10)*pars.V0_opsat*pars.V0_op1dB^2))./...
            (25*A.^3.*(10^(1/10)*pars.V0_op1dB^2-A.^2*c1^2).^2);
            [c5,idxC5]=sort(c5);
            c5=c5(1);
            validateattributes(c5,{'numeric'},{'nonempty','scalar',...
            '<',0},mfilename,'c5')
            A=A(idxC5(1));
            c3=-(4*2^(19/20)*5^(19/20)*A^5*c1^5-...
            50*pars.V0_opsat*A^4*c1^4+...
            10*10^(1/5)*pars.V0_opsat*pars.V0_op1dB^4)/...
            (15*A^3*(10^(1/10)*pars.V0_op1dB^2-A^2*c1^2)^2);
        end
        poly_coeffs=[0,c1,0,c3,0,c5];
    else
        if strcmpi(pars.RefTypeIO,'Input')
            c3=-(2*c1*(20*pars.A_ip1dB^6*gcs_sr+...
            10*pars.A_ipsat^6*gcs_sr-25*pars.A_ip1dB^6+...
            35*pars.A_ip1dB^4*pars.A_ipsat^2-...
            30*pars.A_ip1dB^4*pars.A_ipsat^2*gcs_sr-...
            10^(19/20)*pars.A_ipsat^6*gcs_sr))/...
            (15*pars.A_ip1dB^2*pars.A_ipsat^2*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
            c5=(4*c1*(10*pars.A_ip1dB^6*gcs_sr+...
            20*pars.A_ipsat^6*gcs_sr-15*pars.A_ip1dB^6+...
            35*pars.A_ip1dB^2*pars.A_ipsat^4-...
            30*pars.A_ip1dB^2*pars.A_ipsat^4*gcs_sr-...
            2*2^(19/20)*5^(19/20)*pars.A_ipsat^6*gcs_sr))/...
            (25*pars.A_ip1dB^2*pars.A_ipsat^4*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
            c7=-(32*c1*(10*pars.A_ip1dB^4*gcs_sr+...
            10*pars.A_ipsat^4*gcs_sr-15*pars.A_ip1dB^4+...
            25*pars.A_ip1dB^2*pars.A_ipsat^2-...
            20*pars.A_ip1dB^2*pars.A_ipsat^2*gcs_sr-...
            10^(19/20)*pars.A_ipsat^4*gcs_sr))/...
            (175*pars.A_ip1dB^2*pars.A_ipsat^4*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
        else
            c3=(2*c1*(25*pars.A_op1dB^6*c1^6-...
            10*pars.V0_opsat^6*gcs_sr^7-...
            20*pars.A_op1dB^6*c1^6*gcs_sr+...
            10^(19/20)*pars.V0_opsat^6*gcs_sr^7-...
            35*pars.A_op1dB^4*pars.V0_opsat^2*c1^4*gcs_sr^2+...
            30*pars.A_op1dB^4*pars.V0_opsat^2*c1^4*gcs_sr^3))/...
            (15*pars.A_op1dB^2*pars.V0_opsat^2*gcs_sr^3*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
            c5=-(4*c1^3*(15*pars.A_op1dB^6*c1^6-...
            20*pars.V0_opsat^6*gcs_sr^7-...
            10*pars.A_op1dB^6*c1^6*gcs_sr-...
            35*pars.A_op1dB^2*pars.V0_opsat^4*c1^2*gcs_sr^4+...
            30*pars.A_op1dB^2*pars.V0_opsat^4*c1^2*gcs_sr^5+...
            2*2^(19/20)*5^(19/20)*pars.V0_opsat^6*gcs_sr^7))/...
            (25*pars.A_op1dB^2*pars.V0_opsat^4*gcs_sr^5*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
            c7=(32*c1^5*(15*pars.A_op1dB^4*c1^4-...
            10*pars.V0_opsat^4*gcs_sr^5-...
            10*pars.A_op1dB^4*c1^4*gcs_sr+...
            10^(19/20)*pars.V0_opsat^4*gcs_sr^5-...
            25*pars.A_op1dB^2*pars.V0_opsat^2*c1^2*gcs_sr^2+...
            20*pars.A_op1dB^2*pars.V0_opsat^2*c1^2*gcs_sr^3))/...
            (175*pars.A_op1dB^2*pars.V0_opsat^4*gcs_sr^5*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
        end
        poly_coeffs=[0,c1,0,c3,0,c5,0,c7];
    end
end

function poly_coeffs=PolyModel7(pars)

    c1=pars.lin_VGain;
    c3=compute_ip(3,pars.IP3w,pars.RefTypeIO,c1,pars.Zin,pars.Zout);
    gcs_sr=pars.gcs_sr;
    if isinf(gcs_sr)
        if strcmpi(pars.RefTypeIO,'Input')
            c5=-(210*c3*pars.A_ip1dB^2-90*c3*pars.A_ipsat^2+240*c1...
            -28*2^(19/20)*5^(19/20)*c1)/(175*pars.A_ip1dB^4-...
            125*pars.A_ipsat^4);
            c7=-(64*pars.A_ip1dB^4*c1-320*pars.A_ipsat^4*c1-...
            240*pars.A_ip1dB^2*pars.A_ipsat^4*c3+...
            144*pars.A_ip1dB^4*pars.A_ipsat^2*c3+...
            32*2^(19/20)*5^(19/20)*pars.A_ipsat^4*c1)/...
            (245*pars.A_ip1dB^10-175*pars.A_ip1dB^6*pars.A_ipsat^4);
        else
            A=roots(...
            [3*10^(3/20)*pars.V0_op1dB^2*c1^8*c3+...
            4*10^(1/20)*c1^11-4*c1^11,...
            0,...
            -6*10^(1/4)*pars.V0_op1dB^4*c1^6*c3,...
            0,...
            -12*10^(1/4)*pars.V0_op1dB^4*c1^7,...
            14*10^(1/4)*pars.V0_op1dB^4*pars.V0_opsat*c1^6,...
            6*10^(9/20)*pars.V0_op1dB^8*c1^2*c3+...
            8*10^(7/20)*pars.V0_op1dB^6*c1^5-...
            8*10^(3/10)*pars.V0_op1dB^6*c1^5,...
            0,...
            -3*10^(11/20)*pars.V0_op1dB^10*c3,...
            0,...
            0,...
            -2*10^(11/20)*pars.V0_op1dB^10*pars.V0_opsat]);...
            A=A(imag(A)==0);
            A=A(A>0);
            validateattributes(A,{'numeric'},{'nonempty'},mfilename,'A')
            c7=(8*2^(19/20)*5^(19/20)*c1^2*(3*10^(1/20)*c3*A.^7*c1^4-...
            6*2^(3/20)*5^(3/20)*c3*A.^5*pars.V0_op1dB^2*c1^2+...
            8*A.^5*c1^5-10*10^(1/20)*pars.V0_opsat*A.^4*c1^4+...
            3*10^(1/4)*c3*A.^3*pars.V0_op1dB^4+2*2^(1/4)*5^(1/4)*...
            pars.V0_opsat*pars.V0_op1dB^4))./...
            (175*A.^5.*(10^(1/10)*pars.V0_op1dB^2-A.^2*c1^2).^2.*...
            (A.^2*c1^2+2*2^(1/10)*5^(1/10)*pars.V0_op1dB^2));
            [c7,idxC7]=sort(c7);
            c7=c7(1);
            validateattributes(c7,{'numeric'},{'nonempty','<',0},...
            mfilename,'c7')
            A=A(idxC7(1));
            c5=-(10^(19/20)*(12*2^(1/20)*5^(1/20)*c3*A^9*c1^6-...
            18*2^(3/20)*5^(3/20)*c3*A^7*pars.V0_op1dB^2*c1^4+...
            24*A^7*c1^7-28*2^(1/20)*5^(1/20)*pars.V0_opsat*A^6*c1^6+...
            6*2^(7/20)*5^(7/20)*c3*A^3*pars.V0_op1dB^6+...
            4*2^(7/20)*5^(7/20)*pars.V0_opsat*pars.V0_op1dB^6))/...
            (50*A^5*(10^(1/10)*pars.V0_op1dB^2-A^2*c1^2)^2*...
            (A^2*c1^2+2*2^(1/10)*5^(1/10)*pars.V0_op1dB^2));
        end
        poly_coeffs=[0,c1,0,c3,0,c5,0,c7];
    else
        if strcmpi(pars.RefTypeIO,'Input')
            c5=-(2*(90*pars.A_ip1dB^6*pars.A_ipsat^2*c1-...
            70*pars.A_ip1dB^8*c1+60*pars.A_ip1dB^8*c1*gcs_sr+...
            20*pars.A_ipsat^8*c1*gcs_sr-...
            80*pars.A_ip1dB^6*pars.A_ipsat^2*c1*gcs_sr+...
            15*pars.A_ip1dB^2*pars.A_ipsat^8*c3*gcs_sr-...
            45*pars.A_ip1dB^6*pars.A_ipsat^4*c3*gcs_sr+...
            30*pars.A_ip1dB^8*pars.A_ipsat^2*c3*gcs_sr-...
            2*2^(19/20)*5^(19/20)*pars.A_ipsat^8*c1*gcs_sr))/...
            (25*pars.A_ip1dB^4*pars.A_ipsat^4*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
            c7=(16*(90*pars.A_ip1dB^4*pars.A_ipsat^4*c1-...
            50*pars.A_ip1dB^8*c1+40*pars.A_ip1dB^8*c1*gcs_sr+...
            40*pars.A_ipsat^8*c1*gcs_sr-...
            80*pars.A_ip1dB^4*pars.A_ipsat^4*c1*gcs_sr+...
            30*pars.A_ip1dB^2*pars.A_ipsat^8*c3*gcs_sr-...
            45*pars.A_ip1dB^4*pars.A_ipsat^6*c3*gcs_sr+...
            15*pars.A_ip1dB^8*pars.A_ipsat^2*c3*gcs_sr-...
            4*2^(19/20)*5^(19/20)*pars.A_ipsat^8*c1*gcs_sr))/...
            (175*pars.A_ip1dB^4*pars.A_ipsat^6*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
            c9=-(32*(70*pars.A_ip1dB^4*pars.A_ipsat^2*c1-...
            50*pars.A_ip1dB^6*c1+40*pars.A_ip1dB^6*c1*gcs_sr+...
            20*pars.A_ipsat^6*c1*gcs_sr-...
            60*pars.A_ip1dB^4*pars.A_ipsat^2*c1*gcs_sr+...
            15*pars.A_ip1dB^2*pars.A_ipsat^6*c3*gcs_sr-...
            30*pars.A_ip1dB^4*pars.A_ipsat^4*c3*gcs_sr+...
            15*pars.A_ip1dB^6*pars.A_ipsat^2*c3*gcs_sr-...
            2*2^(19/20)*5^(19/20)*pars.A_ipsat^6*c1*gcs_sr))/...
            (315*pars.A_ip1dB^4*pars.A_ipsat^6*gcs_sr*...
            (pars.A_ip1dB^2-pars.A_ipsat^2)^2);
        else
            c5=-(120*pars.A_op1dB^8*c1^9*gcs_sr-...
            140*pars.A_op1dB^8*c1^9+40*pars.V0_opsat^8*c1*gcs_sr^9+...
            180*pars.A_op1dB^6*pars.V0_opsat^2*c1^7*gcs_sr^2-...
            160*pars.A_op1dB^6*pars.V0_opsat^2*c1^7*gcs_sr^3+...
            30*pars.A_op1dB^2*pars.V0_opsat^8*c3*gcs_sr^9-...
            90*pars.A_op1dB^6*pars.V0_opsat^4*c1^4*c3*gcs_sr^5+...
            60*pars.A_op1dB^8*pars.V0_opsat^2*c1^6*c3*gcs_sr^3-...
            4*2^(19/20)*5^(19/20)*pars.V0_opsat^8*c1*gcs_sr^9)/...
            (25*pars.A_op1dB^4*pars.V0_opsat^4*gcs_sr^5*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
            c7=(16*c1^2*(40*pars.A_op1dB^8*c1^9*gcs_sr-...
            50*pars.A_op1dB^8*c1^9+40*pars.V0_opsat^8*c1*gcs_sr^9+...
            90*pars.A_op1dB^4*pars.V0_opsat^4*c1^5*gcs_sr^4-...
            80*pars.A_op1dB^4*pars.V0_opsat^4*c1^5*gcs_sr^5+...
            30*pars.A_op1dB^2*pars.V0_opsat^8*c3*gcs_sr^9-...
            45*pars.A_op1dB^4*pars.V0_opsat^6*c1^2*c3*gcs_sr^7+...
            15*pars.A_op1dB^8*pars.V0_opsat^2*c1^6*c3*gcs_sr^3-...
            4*2^(19/20)*5^(19/20)*pars.V0_opsat^8*c1*gcs_sr^9))/...
            (175*pars.A_op1dB^4*pars.V0_opsat^6*gcs_sr^7*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
            c9=-(32*c1^4*(40*pars.A_op1dB^6*c1^7*gcs_sr-...
            50*pars.A_op1dB^6*c1^7+20*pars.V0_opsat^6*c1*gcs_sr^7+...
            70*pars.A_op1dB^4*pars.V0_opsat^2*c1^5*gcs_sr^2-...
            60*pars.A_op1dB^4*pars.V0_opsat^2*c1^5*gcs_sr^3+...
            15*pars.A_op1dB^2*pars.V0_opsat^6*c3*gcs_sr^7-...
            30*pars.A_op1dB^4*pars.V0_opsat^4*c1^2*c3*gcs_sr^5+...
            15*pars.A_op1dB^6*pars.V0_opsat^2*c1^4*c3*gcs_sr^3-...
            2*2^(19/20)*5^(19/20)*pars.V0_opsat^6*c1*gcs_sr^7))/...
            (315*pars.A_op1dB^4*pars.V0_opsat^6*gcs_sr^7*...
            (pars.A_op1dB^2*c1^2-pars.V0_opsat^2*gcs_sr^2)^2);
        end
        poly_coeffs=[0,c1,0,c3,0,c5,0,c7,0,c9];
    end
end















