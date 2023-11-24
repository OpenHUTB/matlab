function simrfV2mixer(block,action)

    switch(action)
    case 'simrfInit'
        top_sys=bdroot(block);

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end
        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskWSValues=simrfV2getblockmaskwsvalues(block);
        MaskDisplay='';
        MaskDisplay_3term=simrfV2_add_portlabel(MaskDisplay,...
        2,{'In','LO'},1,{'Out'},true);
        MaskDisplay_6term=simrfV2_add_portlabel(MaskDisplay,...
        4,{'In','LO'},2,{'Out'},false);
        currentMaskDisplay=get_param(block,'MaskDisplay');
        if isequal(currentMaskDisplay,MaskDisplay_6term)&&...
            strcmpi(MaskVals{idxMaskNames.InternalGrounding},'on')
            set_param(block,'MaskDisplay',MaskDisplay_3term)
        end


        current_zin=simrfV2_find_repblk(block,'^(Rin|Zin|ZisInf)$');


        current_zlo=simrfV2_find_repblk(block,'^(RLO|ZLO|ZisInf_LO)$');


        switch lower(MaskVals{idxMaskNames.InternalGrounding})
        case 'on'

            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'In-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd1'),block);


            if replace_gnd_complete
                phtemp=get_param([block,'/',current_zin],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn,'Line'));
                simrfV2connports(struct('SrcBlk',current_zin,...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                'DstBlk','Gnd1','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
            end


            replace_LO_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'LO-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd3'),block);


            if replace_LO_gnd_complete
                phtemp=get_param([block,'/',current_zlo],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn,'Line'));
                simrfV2connports(struct('SrcBlk',current_zlo,...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                'DstBlk','Gnd3','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
            end

            reconnect_negterm=simrfV2repblk(struct('RepBlk','Out-',...
            'SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd2'),block);
            negterm_out='Gnd2';
            negterm_outportstr='LConn';
            MaskDisplay=MaskDisplay_3term;

        case 'off'

            replace_gnd_complete=simrfV2repblk(struct(...
            'RepBlk','Gnd1',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk','In-','Param',...
            {{'Side','Left','Orientation','Up','Port','3'}}),...
            block);


            if replace_gnd_complete
                phtemp=get_param([block,'/',current_zin],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn,'Line'));
                simrfV2connports(struct('DstBlk',current_zin,...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk','In-','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);
            end


            replace_LO_gnd_complete=simrfV2repblk(struct(...
            'RepBlk','Gnd3',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk','LO-',...
            'Param',{{'Side','Left','Orientation','Up',...
            'Port','6'}}),block);


            if replace_LO_gnd_complete
                phtemp=get_param([block,'/',current_zlo],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn,'Line'));
                simrfV2connports(struct('DstBlk',current_zlo,...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk','LO-','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);
            end


            reconnect_negterm=simrfV2repblk(struct(...
            'RepBlk','Gnd2',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk','Out-',...
            'Param',{{'Side','Right','Orientation','Up',...
            'Port','4'}}),block);

            simrfV2repblk(struct('RepBlk','Gnd2','DstBlk','Out-',...
            'Param',{{'Side','Right'}}),block);

            negterm_out='Out-';
            negterm_outportstr='RConn';
            MaskDisplay=MaskDisplay_6term;
        end
        simrfV2_set_param(block,'MaskDisplay',MaskDisplay);

        if reconnect_negterm
            simrfV2connports(struct('SrcBlk','lna','SrcBlkPortStr',...
            'RConn','SrcBlkPortIdx',2,'DstBlk',negterm_out,...
            'DstBlkPortStr',negterm_outportstr,'DstBlkPortIdx',1),...
            block);
        end

        if replace_gnd_complete||replace_LO_gnd_complete

            simrfV2connports(struct('DstBlk','MIXER_RF','DstBlkPortStr',...
            'LConn','DstBlkPortIdx',2,'SrcBlk',current_zin,...
            'SrcBlkPortStr','RConn','SrcBlkPortIdx',1),block);

            simrfV2connports(struct('SrcBlk','MIXER_RF','SrcBlkPortStr',...
            'LConn','SrcBlkPortIdx',4,'DstBlk',current_zlo,...
            'DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
        end

        mo=Simulink.Mask.get(block);
        if isempty(MaskWSValues.NF)||~isscalar(MaskWSValues.NF)||...
            ~isnumeric(MaskWSValues.NF)||MaskWSValues.NF<=0
            mo.BlockDVGIcon='RFBlksIcons.mixer';
        else
            mo.BlockDVGIcon='RFBlksIcons.mixernfon';
        end


        if strcmpi(top_sys,'simrfV2elements')
            return
        end


        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')

            Zinput=simrfV2checkimpedance(MaskWSValues.Zin,0,...
            'Input impedance of mixer',0,1);
            ZLO=simrfV2checkimpedance(MaskWSValues.ZLO,0,...
            'LO impedance of mixer',0,1);
            [~]=simrfV2checkimpedance(MaskWSValues.Zout,0,...
            'Output impedance of mixer',1,0);


            if isinf(Zinput)
                zin_str='ZisInf';
                replace_zin_complete=simrfV2repblk(struct(...
                'RepBlk',current_zin,...
                'SrcBlk','simrfV2_lib/Elements/OPEN_RF',...
                'SrcLib','simrfV2_lib','DstBlk','ZisInf',...
                'Param',{{'Orientation','Down'}}),block);
            elseif isreal(Zinput)
                zin_str='Rin';
                replace_zin_complete=simrfV2repblk(struct('RepBlk',...
                current_zin,'SrcBlk',...
                'simrfV2_lib/Elements/R_RF',...
                'SrcLib','simrfV2_lib',...
                'DstBlk','Rin','Param',{{'Orientation','Down'}}),...
                block);
            else
                zin_str='Zin';
                replace_zin_complete=simrfV2repblk(struct('RepBlk',...
                current_zin,'SrcBlk','simrfV2elements/Z','SrcLib',...
                'simrfV2elements','DstBlk','Zin','Param',...
                {{'Orientation','Down'}}),block);
            end
            if replace_zin_complete
                current_negterm_in=simrfV2_find_repblk(block,...
                '^(Gnd1|In-)$');
                if strncmpi(current_negterm_in,'Gnd',3)
                    current_negterm_in_pstr='LConn';
                elseif strcmpi(current_negterm_in(end),'-')
                    current_negterm_in_pstr='RConn';
                end
                phtemp=get_param([block,'/',current_negterm_in],...
                'PortHandles');
                simrfV2deletelines(get(phtemp.(current_negterm_in_pstr),...
                'Line'));
                simrfV2connports(struct('SrcBlk',zin_str,...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                'DstBlk','In+','DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('DstBlk',zin_str,...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk',current_negterm_in,...
                'SrcBlkPortStr',current_negterm_in_pstr,...
                'SrcBlkPortIdx',1),block);
            end
            if strcmp(zin_str,'Zin')
                simrfV2_set_param([block,'/',zin_str],'Impedance',...
                sprintf('%20.15g + 1i*%20.15g',real(Zinput),...
                imag(Zinput)));
            elseif strcmp(zin_str,'Rin')
                simrfV2_set_param([block,'/',zin_str],'R',...
                num2str(Zinput,16));
            end


            if isinf(ZLO)
                ZLO_str='ZisInf_LO';
                replace_ZLO_complete=simrfV2repblk(struct(...
                'RepBlk',current_zlo,...
                'SrcBlk','simrfV2_lib/Elements/OPEN_RF',...
                'SrcLib','simrfV2_lib','DstBlk','ZisInf_LO',...
                'Param',{{'Orientation','Down'}}),block);
            elseif isreal(ZLO)
                ZLO_str='RLO';
                replace_ZLO_complete=simrfV2repblk(struct('RepBlk',...
                current_zlo,'SrcBlk',...
                'simrfV2_lib/Elements/R_RF',...
                'SrcLib','simrfV2_lib',...
                'DstBlk','RLO','Param',{{'Orientation','Down'}}),...
                block);
            else
                ZLO_str='ZLO';
                replace_ZLO_complete=simrfV2repblk(struct('RepBlk',...
                current_zlo,'SrcBlk','simrfV2elements/Z',...
                'SrcLib','simrfV2elements','DstBlk','ZLO',...
                'Param',{{'Orientation','Down'}}),block);
            end
            if replace_ZLO_complete
                current_negterm_LO=simrfV2_find_repblk(block,...
                '^(Gnd3|LO-)$');
                if strncmpi(current_negterm_LO,'Gnd',3)
                    current_negterm_LO_pstr='LConn';
                elseif strcmpi(current_negterm_LO(end),'-')
                    current_negterm_LO_pstr='RConn';
                end
                phtemp=get_param([block,'/',current_negterm_LO],...
                'PortHandles');
                simrfV2deletelines(get(phtemp.(current_negterm_LO_pstr),...
                'Line'));
                simrfV2connports(struct('SrcBlk',ZLO_str,...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                'DstBlk','LO+','DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('DstBlk',ZLO_str,...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk',current_negterm_LO,...
                'SrcBlkPortStr',current_negterm_LO_pstr,...
                'SrcBlkPortIdx',1),block);
            end
            if strcmp(ZLO_str,'ZLO')
                simrfV2_set_param([block,'/',ZLO_str],'Impedance',...
                sprintf('%20.15g + 1i*%20.15g',real(ZLO),imag(ZLO)));
            elseif strcmp(ZLO_str,'RLO')
                simrfV2_set_param([block,'/',ZLO_str],'R',...
                num2str(ZLO,16));
            end



            [~,~,~,~,normalize]=...
            simrfV2_find_solverparams(top_sys,block,1);
            if normalize
                scale=1/sqrt(2);
            else
                scale=1;
            end
            simrfV2_set_param([block,'/MIXER_RF'],'Scale',num2str(scale,16));


            tempValue=MaskWSValues.linear_gain;
            switch MaskVals{idxMaskNames.linear_gain_unit}
            case 'dB'
                linear_gain=tempValue+20*log10(2);
            otherwise
                if strcmpi(MaskVals{idxMaskNames.Source_linear_gain},...
                    'Available power gain')

                    linear_gain=4*tempValue;
                else

                    linear_gain=2*tempValue;
                end
            end

            poly_coeffs=simrfV2vector2str(2*MaskWSValues.Poly_Coeffs);

            NF=MaskWSValues.NF;
            validateattributes(NF,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','finite'},'',...
            'Mixer Noise figure');
            FactorMixer=10^(NF/10);
            FactorAmplifier=(FactorMixer+3)/4;
            NFAmplifier=10*log10(FactorAmplifier);

            MixerIp2=simrfV2_convert2watts(MaskWSValues.IP2,...
            MaskVals{idxMaskNames.IP2_unit});
            MixerIp3=simrfV2_convert2watts(MaskWSValues.IP3,...
            MaskVals{idxMaskNames.IP3_unit});
            MixerP1dB=simrfV2_convert2watts(MaskWSValues.P1dB,...
            MaskVals{idxMaskNames.P1dB_unit});
            MixerPsat=simrfV2_convert2watts(MaskWSValues.Psat,...
            MaskVals{idxMaskNames.Psat_unit});
            MixerGcomp=simrfV2_convert2watts(MaskWSValues.Gcomp,...
            MaskVals{idxMaskNames.Gcomp_unit});

            if strcmp(MaskVals{idxMaskNames.IPType},'Input')

                AmplifierIp2=1/4*MixerIp2;
                AmplifierIp3=3/4*MixerIp3;
                AmplifierP1dB=3/4*MixerP1dB;
                AmplifierPsat=3/4*MixerPsat;
                AmplifierGcomp=MixerGcomp;
            else

                AmplifierIp2=MixerIp2;
                AmplifierIp3=3*MixerIp3;
                AmplifierP1dB=3*MixerP1dB;
                AmplifierPsat=3*MixerPsat;
                AmplifierGcomp=MixerGcomp;
            end

            simrfV2_set_param([block,'/lna'],...
            'Source_linear_gain',...
            MaskVals{idxMaskNames.Source_linear_gain},...
            'linear_gain',num2str(linear_gain,16),...
            'linear_gain_unit',...
            MaskVals{idxMaskNames.linear_gain_unit},...
            'Zin',MaskVals{idxMaskNames.Zin},...
            'Zout',MaskVals{idxMaskNames.Zout},...
            'Source_Poly',MaskVals{idxMaskNames.Source_Poly},...
            'Poly_Coeffs',poly_coeffs,...
            'IPType',MaskVals{idxMaskNames.IPType},...
            'IP2',num2str(AmplifierIp2,16),'IP2_unit','W',...
            'IP3',num2str(AmplifierIp3,16),'IP3_unit','W',...
            'P1dB',num2str(AmplifierP1dB,16),'P1dB_unit','W',...
            'Psat',num2str(AmplifierPsat,16),'Psat_unit','W',...
            'Gcomp',num2str(AmplifierGcomp,16),...
            'Gcomp_unit','W','NF',num2str(NFAmplifier,16));


            if replace_zin_complete||replace_ZLO_complete
                lib_blockname='MIXER_RF';
                phlib_block=get_param([block,'/',lib_blockname],...
                'PortHandles');
                simrfV2deletelines(get(phlib_block.LConn,'Line'));
                simrfV2deletelines(get(phlib_block.RConn,'Line'));

                simrfV2connports(struct('SrcBlk',lib_blockname,...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                'DstBlk',zin_str,'DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('DstBlk',lib_blockname,...
                'DstBlkPortStr','LConn','DstBlkPortIdx',2,...
                'SrcBlk',zin_str,'SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);

                simrfV2connports(struct('SrcBlk',lib_blockname,...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                'DstBlk','lna','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',lib_blockname,...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
                'DstBlk','lna','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',2),block);

                simrfV2connports(struct('SrcBlk',lib_blockname,...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',3,...
                'DstBlk',ZLO_str,'DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',lib_blockname,...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',4,...
                'DstBlk',ZLO_str,'DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1),block);
            end

        end

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end

end