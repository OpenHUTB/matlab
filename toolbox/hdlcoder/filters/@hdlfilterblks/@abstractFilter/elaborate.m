function hNewC=elaborate(this,hN,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        slbh=-1;
    else
        slbh=hC.SimulinkHandle;
    end

    hF=this.getHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;
    filterarch=hF.Implementation;

    this.unApplyParams(s.pcache);

    mip=this.getImplParams('MultiplierInputPipeline');
    mop=this.getImplParams('MultiplierOutputPipeline');
    if isempty(mip)
        mip=0;
    end
    if isempty(mop)
        mop=0;
    end








    emitMode=~(any(strcmpi(methods(hF),'elaborateemit'))&&(strcmpi(filterarch,'parallel')));

    isFirtdecimPipelined=isa(hF,'hdlfilter.firtdecim')&&mip>0&&mop>0;
    isdecimMultiClock=(isa(hF,'hdlfilter.firdecim')||isa(hF,'hdlfilter.firtdecim')||...
    isa(hF,'hdlfilter.cicdecim'))...
    &&(hdlgetparameter('clockinputs')>1);

    if isa(hC,'hdlcoder.sysobj_comp')

        inSignals=hC.getInputSignals('data');
        numChannel=inSignals(1).Type.getDimensions;
    else
        block=get_param(slbh,'Object');
        numChannel=block.CompiledPortWidths.Inport(1);
    end

    isChannelShared=hF.HDLParameters.INI.getProp('filter_generate_multichannel')>1;



    try
        hasEnablePort=strcmpi(get_param(slbh,'ShowEnablePort'),'on');
    catch
        hasEnablePort=false;
    end

    try
        hasResetPort=~strcmpi(get_param(slbh,'ExternalReset'),'None');
    catch
        hasResetPort=false;
    end

    NumInputPorts=length(hC.PirInputSignals);

    if hasEnablePort||hasResetPort

        if hasEnablePort
            CtrlPortKind='SUBSYSTEM_ENABLE';
        else
            CtrlPortKind='SUBSYSTEM_SYNC_RESET';
        end


        hControlSubNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC,...
        'InportKinds',[repmat({'data'},1,NumInputPorts-1),CtrlPortKind]...
        );

        if this.forceElabModelGen(hN,hC)||hN.optimizationsRequested||hasEnablePort||hasResetPort
            hTopNet=pirelab.createNewNetworkWithInterface(...
            'Network',hControlSubNet,...
            'RefComponent',hC,...
            'InportKind',[repmat({'data'},1,NumInputPorts-1),CtrlPortKind]...
            );
        else
            hTopNet=hControlSubNet;
        end

        NumInputPorts=NumInputPorts-1;

        hTopNet.PirOutputSignals.SimulinkRate=hC.PirOutputSignals.SimulinkRate;
        hControlSubNet.PirOutputSignals.SimulinkRate=hC.PirOutputSignals.SimulinkRate;

        hTopNet.setSharingFactor(hN.getSharingFactor);
        hTopNet.setStreamingFactor(hN.getStreamingFactor);

    else

        hTopNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC);
    end



    hTopNet.PirOutputSignals.Name=hC.PirOutputSignals.Name;
    hTopNet.PirOutputSignals.SimulinkRate=hC.PirOutputSignals.SimulinkRate;


    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');

    hTopNet.PirInputPorts(1).Name=[dfname,'_in'];
    hTopNet.PirOutputPorts.Name=[dfname,'_out'];
    hTopNet.PirInputSignals(1).Name=[dfname,'_in'];
    hTopNet.PirOutputSignals.Name=[dfname,'_out'];

    if hF.coeffPort
        if isa(this,'hdlfilterblks.BiquadFilterHDLInstantiation')
            hTopNet.PirInputPorts(2).Name=[dfname,'_num'];
            hTopNet.PirInputSignals(2).Name=[dfname,'_num'];
            hTopNet.PirInputPorts(3).Name=[dfname,'_den'];
            hTopNet.PirInputSignals(3).Name=[dfname,'_den'];
            if hF.scalePort
                hTopNet.PirInputPorts(4).Name=[dfname,'_g'];
                hTopNet.PirInputSignals(4).Name=[dfname,'_g'];
            end
        else
            cinname=[dfname,'_',hdlgetparameter('filter_coeff_name')];
            hTopNet.PirInputPorts(2).Name=cinname;
            hTopNet.PirInputSignals(2).Name=cinname;
        end
    end

    if hasEnablePort||hasResetPort

        if hasEnablePort
            hControlSubNet.PirInputPorts(NumInputPorts+1).Name=[hC.Name,'_enable'];
            hControlSubNet.PirInputSignals(NumInputPorts+1).Name=[hC.Name,'_enable'];
            hTopNet.PirInputPorts(NumInputPorts+1).Name=[hC.Name,'_enable'];
            hTopNet.PirInputSignals(NumInputPorts+1).Name=[hC.Name,'_enable'];
        else
            hControlSubNet.PirInputPorts(NumInputPorts+1).Name=[hC.Name,'_reset'];
            hControlSubNet.PirInputSignals(NumInputPorts+1).Name=[hC.Name,'_reset'];
            hTopNet.PirInputPorts(NumInputPorts+1).Name=[hC.Name,'_reset'];
            hTopNet.PirInputSignals(NumInputPorts+1).Name=[hC.Name,'_reset'];
        end

    end


    if emitMode
        if any(strcmpi(filterarch,{'serial','serialcascade','distributedarithmetic'}))||...
            isFirtdecimPipelined||...
            isdecimMultiClock||...
isChannelShared

            outsig=hC.PirOutputSignals(1);



            regoutsig=hN.addSignal(outsig.Type,...
            [outsig.Name,'_reg']);

            regoutsig.VType(outsig.VType);
            regoutsig.Imag(outsig.Imag);
            regoutsig.SimulinkHandle=0;
            regoutsig.SimulinkRate=outsig.SimulinkRate;

            outsig.disconnectDriver(hC,0);
            regoutsig.addDriver(hC,0);

            [~,slOr]=getRegBlockPosition(hC);
            hElabC=pirelab.getIntDelayComp(hN,regoutsig,outsig,1);
            hElabC.Name=[hC.Name,'_reg'];

            hElabC.setOrientation(slOr);
            hElabC.setIsPipelineRegister(true);
            hElabC.setOutputDelay(1);

        end

        if(numChannel>1)&&(~isChannelShared)

            [~,ht_input]=pirelab.getVectorTypeInfo(hC.PirInputSignals(1));
            [~,ht_output]=pirelab.getVectorTypeInfo(hC.PirOutputSignals(1));

            for ii=1:numChannel
                hSigIn(ii)=hTopNet.addSignal(ht_input,sprintf('%s_in_%d',hC.Name,ii));%#ok<AGROW>
                hSigOut(ii)=hTopNet.addSignal(ht_output,sprintf('%s_out_%d',hC.Name,ii));%#ok<AGROW>
            end
            pirelab.getDemuxComp(hTopNet,hTopNet.PirInputSignals(1),hSigIn);

            inputtype=hSigIn(1).Type;
            outputtype=hSigOut(1).Type;
            inportrate=hSigIn(1).SimulinkRate;

            if length(hC.getInputPorts('data'))>1
                ht_coeff=hC.PirInputSignals(2).Type;
                for ii=1:numChannel
                    hSigCoeffsIn(ii)=hTopNet.addSignal(ht_coeff,sprintf('%s_coeffs_in_%d',hC.Name,ii));%#ok<AGROW>
                    pirelab.getWireComp(hTopNet,hTopNet.PirInputSignals(2),hSigCoeffsIn(ii));
                end
                coefftype=hSigCoeffsIn(1).Type;
                coeffrate=hSigCoeffsIn(1).SimulinkRate;

                hFilterNet=pirelab.createNewNetwork(...
                'Network',hTopNet,...
                'Name','Filter_Unit',...
                'InportNames',{'filter_in','coeffs_in'},...
                'InportTypes',[inputtype,coefftype],...
                'InportRates',[inportrate,coeffrate],...
                'OutportNames',{'filter_out'},...
                'OutportTypes',outputtype);


                pirelab.getFilterComp(hFilterNet,hFilterNet.PirInputSignals,hFilterNet.PirOutputSignals,this,hF,hC.Name,slbh);


                for ii=1:numChannel
                    pirelab.instantiateNetwork(hTopNet,hFilterNet,...
                    [hSigIn(ii),hSigCoeffsIn(ii)],hSigOut(ii),['filter_',num2str(ii)]);
                end

            else


                hFilterNet=pirelab.createNewNetwork(...
                'Network',hTopNet,...
                'Name','Filter_Unit',...
                'InportNames',{'filter_in'},...
                'InportTypes',inputtype,...
                'InportRates',inportrate,...
                'OutportNames',{'filter_out'},...
                'OutportTypes',outputtype);


                pirelab.getFilterComp(hFilterNet,hFilterNet.PirInputSignals,hFilterNet.PirOutputSignals,this,hF,hC.Name,slbh);


                for ii=1:numChannel
                    pirelab.instantiateNetwork(hTopNet,hFilterNet,...
                    hSigIn(ii),hSigOut(ii),['filter_',num2str(ii)]);
                end
            end


            pirelab.getMuxComp(hTopNet,hSigOut,hTopNet.PirOutputSignals(1));

        else
            filtername=[hdlgetparameter('module_prefix'),hC.Name];
            pirelab.getFilterComp(hTopNet,hTopNet.PirInputSignals,hTopNet.PirOutputSignals,this,hF,filtername,slbh);
        end

        hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

        hNewC.ReferenceNetwork.setLocalMultirate(1);
        hTopNet.flattenAfterModelgen;

    else
        if any(strcmpi(filterarch,{'serial','serialcascade','distributedarithmetic'}))||...
            isFirtdecimPipelined||...
            isdecimMultiClock||...
isChannelShared

            outsig=hC.PirOutputSignals(1);



            regoutsig=hN.addSignal(outsig.Type,...
            [outsig.Name,'_reg']);

            regoutsig.VType(outsig.VType);
            regoutsig.Imag(outsig.Imag);
            regoutsig.SimulinkHandle=0;
            regoutsig.SimulinkRate=outsig.SimulinkRate;

            outsig.disconnectDriver(hC,0);
            regoutsig.addDriver(hC,0);

            [~,slOr]=getRegBlockPosition(hC);
            hElabC=pirelab.getIntDelayComp(hN,regoutsig,outsig,1);
            hElabC.Name=[hC.Name,'_reg'];

            hElabC.setOrientation(slOr);
            hElabC.setIsPipelineRegister(true);
            hElabC.setOutputDelay(1);

        end

        hFilterNet=hTopNet;

        hdlsetparameter('filter_registered_input',0);
        hdlsetparameter('filter_registered_output',0);

        if hF.coeffPort
            hdlsetparameter('filter_generate_coeff_port',1);


            hdlsetparameter('filter_coefficient_source','internal');
        else
            hdlsetparameter('filter_generate_coeff_port',0);
        end

        if isa(this,'hdlfilterblks.BiquadFilterHDLInstantiation')
            hdlsetparameter('filter_generate_biquad_scale_port',hF.scalePort);
        end

        hdlsetparameter('multiplier_input_pipeline',hF.HDLParameters.INI.getProp('multiplier_input_pipeline'));
        hdlsetparameter('multiplier_output_pipeline',hF.HDLParameters.INI.getProp('multiplier_output_pipeline'));
        hdlsetparameter('filter_generate_multichannel',hF.HDLParameters.INI.getProp('filter_generate_multichannel'));

        hdlsetparameter('filter_pipelined',hF.HDLParameters.INI.getProp('filter_pipelined'));
        hdlsetparameter('filter_multipliers',hF.HDLParameters.INI.getProp('filter_multipliers'));

        hdlsetparameter('filter_serialsegment_inputs',hF.HDLParameters.INI.getProp('filter_serialsegment_inputs'));

        hF.elaborateemit(hFilterNet,hC);

        hdlsetparameter('filter_registered_input',hF.HDLParameters.INI.getProp('filter_registered_input'));
        hdlsetparameter('filter_registered_output',hF.HDLParameters.INI.getProp('filter_registered_output'));

        if hasEnablePort||hasResetPort
            hNewC=pirelab.instantiateNetwork(hN,hControlSubNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
            pirelab.instantiateNetwork(hControlSubNet,hTopNet,hControlSubNet.PirInputSignals,hControlSubNet.PirOutputSignals,hC.Name);
        else
            hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
        end



        if this.allowElabModelGen&&~isChannelShared
            hdlsetparameter('requestedoptimslowering',hN.optimizationsRequested||hNewC.ReferenceNetwork.optimizationsRequested);
            hdlsetparameter('forcedlowering',this.forceElabModelGen(hN,hC));
        else
            hdlsetparameter('requestedoptimslowering',0);
            hdlsetparameter('forcedlowering',false);
        end

    end





    if strcmpi('ntwk_instance_comp',hNewC.ClassName)&&...
        numChannel>1&&(isChannelShared)
        hNewC.ReferenceNetwork.setLocalMultirate(1);
    end

end


function[regpos,orientation]=getRegBlockPosition(hC)






    pos=get_param(hC.SimulinkHandle,'Position');
    orientation=get_param(hC.SimulinkHandle,'Orientation');

    offset=15;
    udsizeX=15;
    udsizeY=15;
    filtSizeX=pos(3)-pos(1);
    filtSizeY=pos(4)-pos(2);


    switch orientation
    case 'right'
        regpos=[pos(1)+filtSizeX+offset,pos(2),pos(3)+offset+udsizeX,pos(4)];
    case 'left'
        regpos=[pos(1)-offset-udsizeX,pos(2),pos(3)-filtSizeX-offset,pos(4)];
    case 'down'
        regpos=[pos(1),pos(2)+filtSizeY+offset,pos(3),pos(4)+offset+udsizeY];
    case 'up'
        regpos=[pos(1),pos(2)-offset-udsizeY,pos(3),pos(4)-offset-filtSizeY];
    end
    regpos=min(regpos,32767);
    regpos=max(regpos,-32768);

end




