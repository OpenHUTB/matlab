function hF=createhdlfilter(systemObj,varargin)

    if nargin>1
        inputnumerictype=varargin{1};
    else
        inputnumerictype=hdlgetparameter('InputDataType');
    end

    hS=clone(systemObj);

    switch class(hS)
    case 'dsp.DigitalDownConverter'
        hF=hdlfilter.ddc;
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.DigitalUpConverter'
        hF=hdlfilter.duc;
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.CICDecimator'
        hF=hdlfilter.cicdecim;
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.CICInterpolator'
        hF=hdlfilter.cicinterp;
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.FIRDecimator'
        switch hS.Structure
        case 'Direct form'
            hF=hdlfilter.firdecim;
        case 'Direct form transposed'
            hF=hdlfilter.firtdecim;
        otherwise

            error(message('hdlfilter:createhdlfilter:unsuppfilterstruct'));
        end
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.FIRInterpolator'
        hF=hdlfilter.firinterp;
        hF.getSpecfromSysObj(hS,inputnumerictype);
    case 'dsp.NCO'

        hF=hdlfilter.NCO;
        hprop=hF.HDLParameters;
        PersistentHDLPropSet(hprop);
        updateINI(hprop);

        hdlnco=hdl.NCO('Source',hS);
        hF.Oscillator=hdlnco;
    case 'dsp.BiquadFilter'
        hF=hdlcreatebiquadfilter(hS);
        hF.getSpecfromSysObj(hS,inputnumerictype);
    otherwise
        error(message('hdlfilter:createhdlfilter:unsupportedsysObj'));
    end
