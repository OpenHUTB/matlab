function simrfV2gatewayin1(block,action)

    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2util1')
        return
    end

    switch(action)
    case 'simrfInit'

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end
        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskWSValues=simrfV2getblockmaskwsvalues(block);
        internalGrounding=lower(MaskVals{idxMaskNames.InternalGrounding});
        simulinkInputSignalType=...
        lower(MaskVals{idxMaskNames.SimulinkInputSignalType});
        isPower=strcmpi(simulinkInputSignalType,'Power');
        if isPower
            replace_rseries='R';
        else
            replace_rseries='Zis0';
        end
        gndOn=strcmpi(internalGrounding,'on');
        rfMinus=simrfV2_find_repblk(block,'RF-');
        isUpdating=regexpi(get_param(top_sys,'SimulationStatus'),...
        '^(updating|initializing)$');

        useSqWave=lower(MaskVals{idxMaskNames.UseSqWave});

        pc=get_param([block,'/RF+'],'PortConnectivity');
        if strcmpi('R',get_param(pc.DstBlock,'Name'))
            oldSimulinkInputSignalType='power';
        else
            pc=get_param([block,'/Simulink-PS Converter'],...
            'PortConnectivity');
            dst=get_param(pc(2).DstBlock,'Name');
            if strcmpi(dst,'Controlled Voltage Source')
                oldSimulinkInputSignalType='ideal voltage';
            elseif strcmpi(dst,'Controlled Current Source')
                oldSimulinkInputSignalType='ideal current';
            else
                oldSimulinkInputSignalType='unknown';
            end
        end
        sameInput=strcmpi(simulinkInputSignalType,...
        oldSimulinkInputSignalType);


        pc1=get_param([block,'/SL'],'PortConnectivity');
        dst1=get_param(pc1.DstBlock,'Name');
        if strcmpi(dst1,'Gain')
            oldUseSqWave='off';
        else
            oldUseSqWave='on';
        end
        sameUseSqWave=strcmpi(useSqWave,oldUseSqWave);

        if isempty(rfMinus)
            oldInternalGrounding='on';
        else
            oldInternalGrounding='off';
        end
        sameGrounding=strcmpi(internalGrounding,oldInternalGrounding);

        if~sameInput||~sameGrounding

            switch simulinkInputSignalType
            case{'ideal voltage','power'}
                RepBlk='Controlled Current Source';
                SrcBlk='Controlled Voltage Source';
                DstBlkPort1='LConn';
                DstBlkPortIdx1=1;
                DstBlkPort2='RConn';
                DstBlkPortIdx2=2;
                orientation='down';
            case 'ideal current'
                RepBlk='Controlled Voltage Source';
                SrcBlk='Controlled Current Source';
                DstBlkPort1='RConn';
                DstBlkPortIdx1=2;
                DstBlkPort2='LConn';
                DstBlkPortIdx2=1;
                orientation='up';
            end


            if gndOn

                negDstBlk='Gnd';
                negDstBlkPortStr='LConn';
            else

                negDstBlk='RF-';
                negDstBlkPortStr='RConn';
            end
        end

        if~sameInput
            replace_src_complete=simrfV2repblk(struct(...
            'RepBlk',RepBlk,...
            'SrcBlk',['simrfV2_lib/Sources/',SrcBlk],...
            'SrcLib','simrfV2_lib',...
            'DstBlk',SrcBlk),block);
            current_rseries=simrfV2_find_repblk(block,'^(Zis0|R)$');
            if isPower
                replace_r_complete=simrfV2repblk(struct(...
                'RepBlk',current_rseries,...
                'SrcBlk','simrfV2_lib/Elements/R_RF',...
                'SrcLib','simrfV2_lib',...
                'DstBlk',replace_rseries),block);
            else
                replace_r_complete=simrfV2repblk(struct(...
                'RepBlk',current_rseries,...
                'SrcBlk','simrfV2_lib/Elements/SHORT_RF',...
                'SrcLib','simrfV2_lib',...
                'DstBlk',replace_rseries),block);
            end

            if replace_src_complete
                set_param([block,'/',SrcBlk],'Orientation',orientation)
                simrfV2connports(struct(...
                'DstBlk','Simulink-PS Converter',...
                'DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1,...
                'SrcBlk',SrcBlk,...
                'SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block)
            end

            if replace_src_complete||replace_r_complete
                simrfV2connports(struct(...
                'DstBlk',SrcBlk,...
                'DstBlkPortStr',DstBlkPort1,...
                'DstBlkPortIdx',DstBlkPortIdx1,...
                'SrcBlk',replace_rseries,...
                'SrcBlkPortStr','LConn',...
                'SrcBlkPortIdx',1),block)
            end

            if replace_r_complete
                simrfV2connports(struct(...
                'DstBlk',replace_rseries,...
                'DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1,...
                'SrcBlk','RF+',...
                'SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block)
            end
        end

        if~sameGrounding

            if gndOn

                replace_gnd_complete=simrfV2repblk(struct(...
                'RepBlk','RF-',...
                'SrcBlk','simrfV2elements/Gnd',...
                'SrcLib','simrfV2elements',...
                'DstBlk',negDstBlk),block);
            else

                replace_gnd_complete=simrfV2repblk(struct(...
                'RepBlk','Gnd',...
                'SrcBlk','nesl_utility_internal/Connection Port',...
                'SrcLib','nesl_utility_internal',...
                'DstBlk',negDstBlk,...
                'Param',...
                {{'Side','Right','Orientation','Left','Port','2'}}),...
                block);
            end
        end

        if(~sameInput&&replace_src_complete)||...
            (~sameGrounding&&replace_gnd_complete)

            simrfV2connports(struct(...
            'DstBlk',SrcBlk,...
            'DstBlkPortStr',DstBlkPort2,...
            'DstBlkPortIdx',DstBlkPortIdx2,...
            'SrcBlk',negDstBlk,...
            'SrcBlkPortStr',negDstBlkPortStr,...
            'SrcBlkPortIdx',1),block)
        end

        if~sameUseSqWave
            if strcmpi(useSqWave,'on')

                simrfV2repblk(struct('RepBlk','Gain',...
                'SrcBlk','simrfV2private/SqWaveCoeff',...
                'SrcLib','simrfV2private',...
                'DstBlk','SqWaveCoeff',...
                'Param',{{'NumCoeff','NumCoeff','Bias','Bias','DutyCyc',...
                'DutyCyc'}}),block);
            else
                replBlks=replace_block(block,'FollowLinks','on',...
                'Name','SqWaveCoeff','Gain','noprompt');
                if~isempty(replBlks)
                    set_param(replBlks{1},'Name','Gain');
                end
            end
        end



        if isUpdating

            inputfreq=simrfV2checkfreqs(MaskWSValues.CarrierFreq,'gtez');
            inputfreq=simrfV2convert2baseunit(inputfreq,...
            MaskVals{idxMaskNames.CarrierFreq_unit});


            if strcmpi(useSqWave,'on')

                validateattributes(MaskWSValues.NumCoeff,{'numeric'},...
                {'nonempty','scalar','>',1,'integer','real','nonnan','finite'},...
                '','Number of Fourier Coefficients for square wave modulation');
                validateattributes(MaskWSValues.DutyCyc,{'numeric'},...
                {'nonempty','scalar','>',0,'<',100,'real','nonnan','finite'},...
                '','Duty Cycle for square wave modulation');
                validateattributes(MaskWSValues.Bias,{'numeric'},...
                {'nonempty','scalar','real','nonnan','finite'},...
                '','DC Bias for square wave modulation');

                n=1:(MaskWSValues.NumCoeff-1);
                validateattributes(inputfreq,{'numeric'},...
                {'scalar','nonzero'},'',...
                'Input frequencies for Carrier frequencies for square wave modulation');
                carrierFreq=inputfreq*n;

                i_need=mod(n*pi*MaskWSValues.DutyCyc/100,pi)~=0;
                carrierFreq=[0,carrierFreq(i_need)];

                set_param([block,'/Simulink-PS Converter'],...
                'Frequencies',simrfV2vector2str(carrierFreq))
            else
                set_param([block,'/Simulink-PS Converter'],...
                'Frequencies',simrfV2vector2str(inputfreq))
            end


            if isPower

                ZS=simrfV2checkimpedance(MaskWSValues.ZS,1);
                resistance_val=simrfV2vector2str(ZS);
                inputgain=num2str(2*sqrt(ZS),16);
                set_param([block,'/',replace_rseries],'R',resistance_val)
            else
                inputgain='1';
            end
            if strcmpi(useSqWave,'on')
                set_param([block,'/SqWaveCoeff'],'gain_power',inputgain)
            else
                set_param([block,'/Gain'],'Gain',inputgain)
            end

        end

        set_param([block,'/Simulink-PS Converter'],'PseudoPeriodic','on')

    case 'simrfDelete'

    case 'simrfCopy'
        auxData=get_param(block,'UserData');
        auxData.FigHandle=[];
        set_param(block,'UserData',auxData)

    case 'simrfDefault'

    end

end
