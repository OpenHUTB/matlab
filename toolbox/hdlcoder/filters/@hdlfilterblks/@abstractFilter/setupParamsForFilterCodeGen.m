function pcache=setupParamsForFilterCodeGen(this,hC,hF)







    if(hC.SimulinkHandle~=-1)
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        inComplexSig=block.CompiledPortComplexSignals.Inport;
        inComplex=inComplexSig(1);
        coeffPort=0;
        if isa(this,'hdlfilterblks.DiscreteFIRFilterHDLInstantiation')
            coeffPort=strcmpi(get_param(bfp,'CoefSource'),'Input Port');
        elseif isa(this,'hdlfilterblks.BiquadFilterHDLInstantiation')
            coeffPort=strcmpi(get_param(bfp,'FilterSource'),'Input port(s)');
        end
    else
        inComplexSig=hF.InputComplex;
        inComplex=inComplexSig(1);
        coeffPort=hF.coeffPort;



    end

    pcache={};
    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');

    finname=[dfname,'_in'];
    foutname=[dfname,'_out'];

    if hdlgetparameter('clockinputs')==1||~this.isMultiClockModeSupported
        hF.setHDLParameter('clockinputs','single');
        hdlsetparameter('clockinputs',1);
    else
        hF.setHDLParameter('clockinputs','multiple');
        hdlsetparameter('clockinputs',2);
    end

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
        inPortOffset=3;
    else
        multiclock=1;
        inPortOffset=6;
    end


    inPortOffset=setInputPorts(this,hF,hC,inPortOffset);


    if coeffPort


        hF.HDLParameters.INI.setProp('filter_generate_coeff_port',1);
        setupCoeffPorts(this,hF,hC,inPortOffset);
    else
        hF.HDLParameters.INI.setProp('filter_generate_coeff_port',0);
    end

    hF.updateHdlfilterINI;


    setOutputPorts(this,hF,hC);

    outComplex=hF.isOutputPortComplex;
    if~inComplex&&outComplex
        hF.setHDLParameter('InputComplex','off');
    end

    hC.setInputPortName(0,hC.PirInputSignals(1).Name);




    hF.setHDLParameter('Name',dfname);
    hF.setHDLParameter('InputPort',finname);
    hF.setHDLParameter('OutputPort',foutname);






    if multiclock==0
        hC.setInputPortName(1,hC.PirInputSignals(2).Name);
        hC.setInputPortName(2,hC.PirInputSignals(3).Name);

        hF.setHDLParameter('ClockInputPort',hC.PirInputSignals(1).Name);
        hF.setHDLParameter('ClockEnableInputPort',hC.PirInputSignals(2).Name);
        hF.setHDLParameter('ResetInputPort',hC.PirInputSignals(3).Name);
    else

        hC.setInputPortName(2,hC.PirInputSignals(3).Name);
        hC.setInputPortName(4,hC.PirInputSignals(5).Name);

        hC.setInputPortName(3,hC.PirInputSignals(4).Name);
        hC.setInputPortName(5,hC.PirInputSignals(6).Name);


        hF.setHDLParameter('ClockInputPort',hC.PirInputSignals(1).Name);
        hF.setHDLParameter('ClockEnableInputPort',hC.PirInputSignals(3).Name);
        hF.setHDLParameter('ResetInputPort',hC.PirInputSignals(5).Name);

        hF.HDLParameters.INI.setProp('filter_multiclock_portname',...
        hC.PirInputSignals(2).Name);
        hF.HDLParameters.INI.setProp('filter_multiclock_enableportname',...
        hC.PirInputSignals(4).Name);
        hF.HDLParameters.INI.setProp('filter_multiclock_resetportname',...
        hC.PirInputSignals(6).Name);
    end

    hF.HDLParameters.INI.setProp('filter_excess_latency',0);
    hF.setHDLParameter('AddOutputRegister','off');
    hF.setHDLParameter('AddInputRegister','off');


    hF.HDLParameters.INI.setProp('filter_generate_ceout',0);

    hF.updateHdlfilterINI;

