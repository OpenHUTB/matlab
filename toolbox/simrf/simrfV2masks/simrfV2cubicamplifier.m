function simrfV2cubicamplifier(block,action)

    top_sys=bdroot(block);
    if strcmpi(top_sys,'simrfV2elements')&&...
        ~strcmpi(get_param(block,'Parent'),'simrfV2elements/Mixer')
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
        MaskDisplay_2term=simrfV2_add_portlabel([],1,...
        {'In'},1,{'Out'},true);
        MaskDisplay_4term=simrfV2_add_portlabel([],2,...
        {'In'},2,{'Out'},false);
        currentMaskDisplay=get_param(block,'MaskDisplay');

        if isequal(currentMaskDisplay,MaskDisplay_4term)...
            &&strcmpi(MaskVals{idxMaskNames.InternalGrounding},'on')
            set_param(block,'MaskDisplay',MaskDisplay_2term)
        end


        SourceAmpGain=MaskVals{idxMaskNames.Source_linear_gain};
        dataSource=strcmpi(SourceAmpGain,'Data source');
        if dataSource
            switch MaskVals{idxMaskNames.DataSource}
            case{'Data file','Network-parameters'}
                simrfV2_cachefit(block,MaskWSValues);
            case 'Rational model'
                simrfV2_process_rational_model(block,MaskWSValues);
            end
        end




        Single_Sparam=false;
        if strcmpi(MaskVals{idxMaskNames.SparamRepresentation},...
            'Time domain (rationalfit)')||...
            strcmpi(MaskVals{idxMaskNames.DataSource},'Rational model')
            isTimeDomainFit=true;
            if dataSource
                auxData=simrfV2_getauxdata(block);
                cacheData=get_param(block,'UserData');
                if all(cellfun('isempty',cacheData.RationalModel.C))
                    Single_Sparam=true;
                end
                if length(auxData.Spars.Frequencies)==1
                    Single_Sparam=true;
                    if~isreal(auxData.Spars.Parameters)
                        isTimeDomainFit=false;
                    end
                end
            end
        else
            isTimeDomainFit=false;
        end


        current_nl=simrfV2_find_repblk(block,...
        ['^(NL_POLY_1ORDER_RF|NL_POLY_2ORDER_RF|NL_POLY_3ORDER_RF|'...
        ,'NL_POLY_4ORDER_RF|NL_POLY_5ORDER_RF|NL_POLY_6ORDER_RF|'...
        ,'NL_POLY_7ORDER_RF|NL_POLY_8ORDER_RF|NL_POLY_9ORDER_RF|'...
        ,'NL_POLY_LINEAR_RF|f2port|s2port|d2port|'...
        ,'NL_POLY_ODD3_RF|NL_POLY_ODD5_RF|NL_POLY_ODD7_RF|'...
        ,'NL_POLY_ODD9_RF|AMAM_AMPM)$']);


        switch lower(MaskVals{idxMaskNames.InternalGrounding})
        case 'on'

            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'In-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd1'),block);


            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Front ZinNoise',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,'DstBlk',...
                'Gnd1','DstBlkPortStr','LConn','DstBlkPortIdx',1),block);
            end
            reconnect_negterm=simrfV2repblk(struct('RepBlk',...
            'Out-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd2'),block);
            negterm_out='Gnd2';
            negterm_portstr='LConn';
            MaskDisplay=MaskDisplay_2term;

        case 'off'

            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'Gnd1','SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk',...
            'In-','Param',...
            {{'Side','Left','Orientation','Up','Port','3'}}),block);

            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Front ZinNoise',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,'DstBlk',...
                'In-','DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
            end

            reconnect_negterm=simrfV2repblk(struct('RepBlk','Gnd2',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk',...
            'Out-','Param',...
            {{'Side','Right','Orientation','Up','Port','4'}}),block);
            negterm_out='Out-';
            negterm_portstr='RConn';
            MaskDisplay=MaskDisplay_4term;
        end

        simrfV2_set_param(block,'MaskDisplay',MaskDisplay)

        if reconnect_negterm
            phtemp=get_param([block,'/Refout'],'PortHandles');
            phtempRConn=phtemp.('RConn');
            simrfV2deletelines(get(phtempRConn(2),'Line'));
            simrfV2connports(struct('DstBlk','Refout',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',2,...
            'SrcBlk',negterm_out,'SrcBlkPortStr',...
            negterm_portstr,'SrcBlkPortIdx',1),block);
            simrfV2connports(struct('DstBlk','Refout',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',2,...
            'SrcBlk','Refout','SrcBlkPortStr',...
            'LConn','SrcBlkPortIdx',4),block);
        end







        TreatAsLinear=false;
        nonLinear=false;
        switch SourceAmpGain
        case 'Polynomial coefficients'

            validateattributes(MaskWSValues.Poly_Coeffs,...
            {'numeric'},{'nonempty','vector','finite','real'},...
            '','Polynomial coefficients');
            if any(MaskWSValues.Poly_Coeffs([1,3:end])~=0)
                nonLinear=true;
            end
        case 'AM/AM-AM/PM table'
            validateattributes(MaskWSValues.AmAmAmPmTable,...
            {'double','single','matrix'},...
            {'2d','size',[NaN,3],'nonempty','finite','nonnan','real'},...
            '','Am/Am-Am/Pm Table')
            validateattributes(MaskWSValues.AmAmAmPmTable(:,1),...
            {'numeric'},{'increasing'},'','Am/Am-Am/Pm Table Pin')
            validateattributes(size(MaskWSValues.AmAmAmPmTable,1),...
            {'numeric'},{'scalar','>=',3},'',...
            'number of Am/Am-Am/Pm Table rows')
            nonLinear=true;
        otherwise

            validateattributes(MaskWSValues.IP3,{'numeric'},...
            {'nonempty','scalar','nonnan','real'},'','IP3');
            switch MaskVals{idxMaskNames.Source_Poly}
            case 'Odd order'
                validateattributes(MaskWSValues.P1dB,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','P1dB');
                validateattributes(MaskWSValues.Psat,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','Psat');
                if~(isinf(MaskWSValues.IP3)&&...
                    isinf(MaskWSValues.P1dB)&&...
                    isinf(MaskWSValues.Psat))
                    nonLinear=true;
                end
            case 'Even and odd order'
                validateattributes(MaskWSValues.IP2,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','IP2');
                if~(isinf(MaskWSValues.IP2)&&...
                    isinf(MaskWSValues.IP3))
                    nonLinear=true;
                end
            end
            if dataSource
                TreatAsLinear=~nonLinear;
            end
        end

        BlocksAddNoise=MaskWSValues.AddNoise;
        auxData=get_param([block,'/AuxData'],'UserData');
        if dataSource


            Z0=auxData.Spars.Impedance;
        else


            Z0=50;
        end
        if BlocksAddNoise
            if dataSource&&...
                strcmpi(MaskVals{idxMaskNames.DataSource},...
                'Data file')&&...
                ~isempty(auxData)&&isfield(auxData,'Noise')&&...
                isfield(auxData.Noise,'HasNoisefileData')&&...
                auxData.Noise.HasNoisefileData==true
                noiseFromFile=true;
                NoiseDist='';
                formNF='vector';
                sparStr1={'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)';'NF'};
                sparStr2={'None';'S(1,1)';'S(1,2)';'S(2,1)';...
                'S(2,2)';'NF'};
            else
                noiseFromFile=false;
                NoiseDist=MaskVals{idxMaskNames.NoiseDist};
                formNF='vector';
                if strcmpi(NoiseDist,'White')
                    formNF='scalar';
                end
                if(strcmpi(formNF,'vector')&&(~nonLinear))
                    sparStr1={'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)';'NF'};
                    sparStr2={'None';'S(1,1)';'S(1,2)';'S(2,1)';...
                    'S(2,2)';'NF'};
                else
                    sparStr1={'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)'};
                    sparStr2={'None';'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)'};
                end
            end
        else
            noiseFromFile=false;
            NoiseDist='';
            formNF='';
            sparStr1={'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)'};
            sparStr2={'None';'S(1,1)';'S(1,2)';'S(2,1)';'S(2,2)'};
        end
        mask=Simulink.Mask.get(block);
        maskPars=mask.Parameters;
        maskPars(idxMaskNames.('YParam1')).TypeOptions=sparStr1;
        maskPars(idxMaskNames.('YParam2')).TypeOptions=sparStr2;

        spotNoise=strcmpi(MaskVals{idxMaskNames.NoiseType},...
        'Spot noise data');
        if~BlocksAddNoise
            mask.BlockDVGIcon='RFBlksIcons.amplifier';
        elseif~noiseFromFile
            if~spotNoise


                if isempty(MaskWSValues.NF)||...
                    ~isnumeric(MaskWSValues.NF)||...
                    (strcmpi(formNF,'scalar')&&...
                    ~isscalar(MaskWSValues.NF))||...
                    all(MaskWSValues.NF(:)<=0)
                    mask.BlockDVGIcon='RFBlksIcons.amplifier';
                else
                    mask.BlockDVGIcon='RFBlksIcons.amplifierwithnoise';
                end
            else



                if isempty(MaskWSValues.MinNF)||...
                    isempty(MaskWSValues.RN)||...
                    ~isnumeric(MaskWSValues.MinNF)||...
                    ~isnumeric(MaskWSValues.RN)||...
                    (strcmpi(formNF,'scalar')&&...
                    ~isscalar(MaskWSValues.MinNF))||...
                    (numel(MaskWSValues.MinNF)~=...
                    numel(MaskWSValues.RN))||...
                    (all(MaskWSValues.MinNF(:)<=0)&&...
                    all(MaskWSValues.RN(:)<=0))
                    mask.BlockDVGIcon='RFBlksIcons.amplifier';
                else
                    mask.BlockDVGIcon='RFBlksIcons.amplifierwithnoise';
                end
            end
        else
            if(isfield(auxData.Noise,'Fmin')&&...
                all(auxData.Noise.Fmin==-inf))&&...
                (isfield(auxData.Noise,'Rn')&&...
                all(auxData.Noise.Rn<=0))
                mask.BlockDVGIcon='RFBlksIcons.amplifier';
            else
                mask.BlockDVGIcon='RFBlksIcons.amplifierwithnoise';
            end
        end


        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')





            if dataSource


                Zin_mid=Z0;
                Zout=Z0;
            else



                Zin_mid=simrfV2checkimpedance(MaskWSValues.Zin,0,...
                'Input impedance of the amplifier',0,1);
                Zout=simrfV2checkimpedance(MaskWSValues.Zout,0,...
                'Output impedance of the amplifier',1,0);
            end



            [NoiseBlk_params,NoiseBlk,repNoiseBlk,NoiseBlk_lib]=...
            get_noise_data(block,top_sys,MaskWSValues,auxData,...
            BlocksAddNoise,noiseFromFile,spotNoise,NoiseDist,...
            formNF,Z0,Zin_mid,dataSource,nonLinear);


            isZin=true;
            [zin_param_name,zin_str,zin_source_block,zin_source_lib]=...
            get_z_str(isZin,Zin_mid,TreatAsLinear,dataSource);

            if strcmpi(NoiseBlk,'Front ZinNoise')
                ZinBlk='Mid ZinNoise';
            else
                ZinBlk='Front ZinNoise';
            end
            replace_block_if_diff(block,ZinBlk,zin_source_lib,...
            zin_source_block);
            if~isempty(zin_param_name)
                simrfV2_set_param([block,'/',ZinBlk],zin_param_name,zin_str);
            end


            [refin_type,refin_source_block,refin_source_lib]=...
            get_ref_data(TreatAsLinear,dataSource,Single_Sparam,...
            isTimeDomainFit);
            replace_block_if_diff(block,'Refin',refin_source_lib,...
            refin_source_block);
            if(~strcmp(refin_type,'PT'))
                simrfV2sparam_simple([block,'/Refin'],block,1,...
                isTimeDomainFit);
            end


            isZin=false;
            [zout_param_name,zout_str,zout_source_block,...
            zout_source_lib]=get_z_str(isZin,Zout,TreatAsLinear,...
            dataSource);
            replace_block_if_diff(block,'Zout',zout_source_lib,...
            zout_source_block);
            if~isempty(zout_param_name)
                simrfV2_set_param([block,'/Zout'],zout_param_name,zout_str);
            end


            [refout_type,refout_source_block,refout_source_lib]=...
            get_ref_data(TreatAsLinear,dataSource,Single_Sparam,...
            isTimeDomainFit);
            replace_block_if_diff(block,'Refout',refout_source_lib,...
            refout_source_block);
            if any(strcmp(refout_type,{'s','D','F'}))
                if~(MaskWSValues.ConstS21NL)
                    S21abs=squeeze(abs(auxData.Spars.Parameters(2,1,:)));

                    if~(MaskWSValues.SetOpFreqAsMaxS21)
                        freqs=auxData.Spars.Frequencies;
                        opFreq=...
                        simrfV2convert2baseunit(MaskWSValues.OpFreq,...
                        MaskWSValues.OpFreq_unit);
                        if((opFreq>min(freqs))&&(opFreq<max(freqs)))
                            S21absScalar=interp1(freqs,S21abs,opFreq);
                            freq_used=opFreq;
                        else
                            if(opFreq<=min(freqs))
                                [~,freqInd]=min(freqs);
                            else
                                [~,freqInd]=max(freqs);
                            end
                            S21absScalar=S21abs(freqInd);
                            freq_used=freqs(freqInd);
                        end
                    else
                        [~,idxmax]=max(abs(auxData.Spars.Parameters(2,1,:)));
                        S21absScalar=S21abs(idxmax);
                        freq_used=auxData.Spars.Frequencies(idxmax);
                    end
                    if isTimeDomainFit&&dataSource
                        spars=simrfV2_sparm_from_ratmodel(...
                        cacheData.RationalModel,2,freq_used);
                        S21absScalar=abs(spars(2,1));
                    end
                    simrfV2sparam_simple([block,'/Refout'],block,2,...
                    isTimeDomainFit,S21absScalar);
                else
                    simrfV2sparam_simple([block,'/Refout'],block,2,...
                    isTimeDomainFit);
                end
            end


            S21normScalar=1;
            if(MaskWSValues.ConstS21NL&&...
                ~(MaskWSValues.MagModeling)&&...
                (any(strcmp(refout_type,{'s','D','F'}))))
                S21norm=squeeze(auxData.Spars.Parameters(2,1,:)./...
                abs(auxData.Spars.Parameters(2,1,:)));
                S21norm(~isfinite(S21norm))=1;

                if~(MaskWSValues.SetOpFreqAsMaxS21)
                    freqs=auxData.Spars.Frequencies;
                    opFreq=simrfV2convert2baseunit(MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit);
                    if((opFreq>min(freqs))&&(opFreq<max(freqs)))
                        S21normScalar=interp1(freqs,S21norm,opFreq);
                    else
                        if(opFreq<=min(freqs))
                            [~,freqInd]=min(freqs);
                        else
                            [~,freqInd]=max(freqs);
                        end
                        S21normScalar=S21norm(freqInd);
                    end
                else
                    [~,idxmax]=max(abs(auxData.Spars.Parameters(2,1,:)));
                    S21normScalar=S21norm(idxmax);
                end
            end
            if(S21normScalar==1)
                linphase_source_block='simrfV2private/InterPassThrough2P';
                linphase_source_lib='simrfV2private';
            else
                linphase_source_block='simrfV2_lib/Sparameters/F2PORT_RF';
                linphase_source_lib='simrfV2_lib';
            end
            replace_block_if_diff(block,'Linear Phase',...
            linphase_source_lib,linphase_source_block);
            if(S21normScalar~=1)
                LinPhfreqs='[0, 1]';
                LinPhS(:,:,1)=[0,1;1,0];
                LinPhS(:,:,2)=[0,1;S21normScalar,0];
                LinPhS_1D=simrfV2_sparams3d_to_1d(LinPhS);
                set_param([block,'/Linear Phase'],'ZO',['['...
                ,num2str(zout_str,16),' ',num2str(zout_str,16),']'],...
                'freqs',LinPhfreqs,'S',simrfV2vector2str(LinPhS_1D));
            end


            replace_block_if_diff(block,NoiseBlk,NoiseBlk_lib,repNoiseBlk);
            if isfield(NoiseBlk_params,'CholCa')
                simrfV2_set_param([block,'/',NoiseBlk],...
                'CholCovariance',...
                three_dim_mat_2_str(NoiseBlk_params.CholCa),...
                'freqs',...
                simrfV2vector2str(NoiseBlk_params.blockFreq),...
                'impulse_length',...
                simrfV2vector2str(NoiseBlk_params.impulse_length));
            end


            switch SourceAmpGain
            case 'AM/AM-AM/PM table'
                Srclib=('simrfV2private');
                DstBlk='AMAM_AMPM';
                SrcBlk=[Srclib,'/',DstBlk];
                nl_params_str=[...
                {'Table'},mat2str(MaskWSValues.AmAmAmPmTable,16)...
                ,'Zin',num2str(MaskWSValues.Zin,16)...
                ,'Zout',num2str(MaskWSValues.Zout,16)];
            otherwise

                [nl_params_str,SrcBlk,Srclib,DstBlk]=...
                simrfV2_compute_coeffs(block,isTimeDomainFit,...
                TreatAsLinear,Single_Sparam);
            end
            replace_block_if_diff(block,current_nl,Srclib,SrcBlk);
            set_param([block,'/',current_nl],'Name',DstBlk);

            if~strcmpi(get_param(top_sys,'SimulationStatus'),'stopped')
                if(TreatAsLinear)
                    if isTimeDomainFit
                        simrfV2sparamblockinit(block);
                    else
                        simrfV2sparam_freq_domain_blockinit(block,...
                        [block,'/',DstBlk],...
                        simrfV2getblockmaskwsvalues(block));
                    end
                else
                    simrfV2_set_param([block,'/',DstBlk],nl_params_str{:});
                end
            end
        end

        if strcmpi(get_param(top_sys,'SimulationStatus'),'stopped')
            dialog=simrfV2_find_dialog(block);
            if~isempty(dialog)
                dialog.refresh;
            end
        end
    case 'simrfDelete'

    case 'simrfCopy'
        auxData=get_param([block,'/AuxData'],'UserData');
        if isfield(auxData,'Plot')
            simrfV2Constants=simrfV2_constants();
            auxData.Plot=simrfV2Constants.Plot;
            set_param([block,'/AuxData'],'UserData',auxData);
        end

    case 'simrfDefault'

    end





end

function[z_param_name,z_str,z_source_block,z_source_lib]=...
    get_z_str(isZin,Z,TreatAsLinear,dataSource)

    if isZin
        interZType='InterZShunt';
        NoZval=inf;
    else
        interZType='InterZSeries';
        NoZval=0;
    end
    if TreatAsLinear

        z_param_name='';
        z_str='';
        z_source_block='simrfV2private/InterZNoZ';
        z_source_lib='simrfV2private';
    else
        if dataSource


            z_param_name='R';
            z_str=num2str(real(Z),16);
            z_source_block=['simrfV2private/',interZType,'R'];
            z_source_lib='simrfV2private';
        else


            if isequal(Z,NoZval)
                z_param_name='';
                z_str='';
                z_source_block='simrfV2private/InterZNoZ';
                z_source_lib='simrfV2private';
            elseif isreal(Z)
                z_param_name='R';
                z_str=num2str(Z,16);
                z_source_block=['simrfV2private/',interZType,'R'];
                z_source_lib='simrfV2private';
            else
                z_param_name='Impedance';
                z_str=sprintf('%20.15g + 1i*%20.15g',real(Z),...
                imag(Z));
                z_source_block=['simrfV2private/',interZType,'Z'];
                z_source_lib='simrfV2private';
            end
        end
    end
end

function[ref_type,ref_source_block,ref_source_lib]=...
    get_ref_data(TreatAsLinear,dataSource,Single_Sparam,...
    isTimeDomainFit)

    if~TreatAsLinear&&dataSource
        if~isTimeDomainFit
            ref_type='F';
            ref_source_block='simrfV2_lib/Sparameters/F3PORT_RF';
            ref_source_lib='simrfV2_lib';
        elseif isTimeDomainFit&&~Single_Sparam
            ref_type='s';
            ref_source_block='simrfV2_lib/Sparameters/S3PORT_RF';
            ref_source_lib='simrfV2_lib';
        elseif isTimeDomainFit&&Single_Sparam
            ref_type='D';
            ref_source_block='simrfV2_lib/Sparameters/D3PORT_RF';
            ref_source_lib='simrfV2_lib';
        end
    else
        ref_type='PT';
        ref_source_block='simrfV2private/InterPassThrough3P';
        ref_source_lib='simrfV2private';
    end
end

function[NoiseBlk_params,NoiseBlk,repNoiseBlk,NoiseBlk_lib]=...
    get_noise_data(block,top_sys,MaskWSValues,auxData,...
    BlocksAddNoise,noiseFromFile,spotNoise,NoiseDist,formNF,Z0,...
    Zin_mid,dataSource,nonLinear)%#ok<INUSD> 
    nonLinear=false;

    if BlocksAddNoise
        if~noiseFromFile
            if spotNoise
                if strcmpi(NoiseDist,'White')
                    blockFreq=1;
                else
                    blockFreq=simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreq,...
                    MaskWSValues.CarrierFreq_unit);
                    blockFreq=blockFreq(:)';
                end
                validateattributes(...
                MaskWSValues.CarrierFreq,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                ['Frequencies corresponding to '...
                ,'Spot noise data']);
                minNF=MaskWSValues.MinNF(:)';
                validateattributes(minNF,{'numeric'},...
                {'nonempty',formNF,'real','nonnegative',...
                'finite'},'','Amplifier Minimum noise figure');
                if(length(minNF)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Minimum noise figure','Frequencies'));
                end
                Fmin=10.^(minNF/10);
                Gopt=MaskWSValues.Gopt(:).';
                validateattributes(Gopt,{'numeric'},...
                {'nonempty',formNF,'finite'},'',...
                'Optimal reflection coefficient');
                if(length(Gopt)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Optimal reflection coefficient',...
                    'Frequencies'));
                end
                Yopt=(1-Gopt)./(1+Gopt)/Z0;
                RN=MaskWSValues.RN(:)';
                validateattributes(RN,{'numeric'},...
                {'nonempty',formNF,'real','nonnegative',...
                'finite'},'',...
                'Equivalent normalized noise resistance');
                if(length(RN)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Equivalent normalized noise resistance',...
                    'Frequencies'));
                end
                Rn=Z0*RN;


                blockNF=10*log10(Fmin+...
                (Rn./real(1/Z0)).*abs((1/Z0)-Yopt).^2);
            else
                if strcmpi(NoiseDist,'White')
                    blockFreq=1;
                else
                    blockFreq=simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreq,...
                    MaskWSValues.CarrierFreq_unit);
                    blockFreq=blockFreq(:)';
                end
                validateattributes(...
                MaskWSValues.CarrierFreq,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                ['Frequencies corresponding to '...
                ,'Noise figure data']);
                blockNF=MaskWSValues.NF(:)';
            end
        else
            Yopt=(1-auxData.Noise.Gopt)./(1+auxData.Noise.Gopt)/Z0;
            Fmin=10.^(auxData.Noise.Fmin/10);
            Rn=Z0*auxData.Noise.RN;
            blockNF=auxData.Noise.NF;

            blockFreq=auxData.Noise.Freq;
        end
        validateattributes(blockNF,{'numeric'},...
        {'nonempty',formNF,'real','nonnegative','finite'},'',...
        'Amplifier Noise figure');
        if(length(blockNF)~=length(blockFreq))
            error(message(...
            'simrf:simrfV2errors:VectorLengthNotSameAs',...
            'Noise figure','Frequencies'));
        end
    end



    AddNoise=false;
    if((BlocksAddNoise)&&...
        (noiseFromFile||(spotNoise||any(blockNF~=0))))

        [~,~,AddNoise,envtempK,~,step]=...
        simrfV2_find_solverparams(top_sys,block,1);
    end


    if AddNoise
        T=envtempK;
        RF_Const=simrfV2_constants();
        K=value(RF_Const.Boltz,'J/K');
        if((inside_mixer(block))||((~noiseFromFile)&&(~spotNoise)))



            if((nonLinear)&&(~isscalar(blockNF)))

                if(MaskWSValues.SetOpFreqAsMaxS21)


                    [blockNF,blockNFMaxInd]=max(blockNF);
                    blockFreq=blockFreq(blockNFMaxInd);
                else
                    opFreq=simrfV2convert2baseunit(...
                    MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit);
                    if((opFreq>=min(blockFreq))&&...
                        (opFreq<=max(blockFreq)))
                        blockNF=interp1(blockFreq,blockNF,opFreq);
                        blockFreq=opFreq;
                    else
                        if(opFreq<min(blockFreq))
                            [blockFreq,BlockFreqInd]=min(blockFreq);
                        else
                            [blockFreq,BlockFreqInd]=max(blockFreq);
                        end
                        blockNF=blockNF(BlockFreqInd);
                    end
                end
            end
            Fmin=10.^(blockNF/10);
            if(inside_mixer(block))


                Fmin=[(2*Fmin-1),Fmin];
                blockFreq=[0,1];
            end
            Rn=real(Z0)*(Fmin-1)/4;
            Yopt=1/Z0;
            VnVariance=4*K*T*Rn;
            YCorr=2/real(Z0)-Yopt;






            CholCa=zeros(2,2,length(VnVariance));
            CholCa(1,1,:)=sqrt(VnVariance);
            if((~dataSource)&&(Zin_mid==Z0))








                NoiseBlk='Mid ZinNoise';
                repNoiseBlk='simrfV2private/InterNoiseOnlyVn';
            else









                NoiseBlk='Front ZinNoise';
                repNoiseBlk='simrfV2private/InterNoiseNoIn';
                CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
            end
            NoiseBlk_lib='simrfV2private';







            constNoise=isConst(VnVariance,4*K*T*50)&&isConst(YCorr,1/50);
        else



            if((nonLinear)&&(~isscalar(blockNF)))

                if(MaskWSValues.SetOpFreqAsMaxS21)


                    [blockNF,blockNFMaxInd]=max(blockNF);
                    Fmin=Fmin(blockNFMaxInd);
                    Yopt=Yopt(blockNFMaxInd);
                    Rn=Rn(blockNFMaxInd);
                    blockFreq=blockFreq(blockNFMaxInd);
                else
                    opFreq=simrfV2convert2baseunit(...
                    MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit);
                    if((opFreq>=min(blockFreq))&&...
                        (opFreq<=max(blockFreq)))
                        blockNF=interp1(blockFreq,blockNF,opFreq);
                        Fmin=interp1(blockFreq,Fmin,opFreq);
                        Yopt=interp1(blockFreq,Yopt,opFreq);
                        Rn=interp1(blockFreq,Rn,opFreq);
                        blockFreq=opFreq;
                    else
                        if(opFreq<min(blockFreq))
                            [blockFreq,BlockFreqInd]=min(blockFreq);
                        else
                            [blockFreq,BlockFreqInd]=max(blockFreq);
                        end
                        blockNF=blockNF(BlockFreqInd);
                        Fmin=Fmin(BlockFreqInd);
                        Yopt=Yopt(BlockFreqInd);
                        Rn=Rn(BlockFreqInd);
                    end
                end
            end
            covPosDef=all(((Fmin-1)-4*Rn.*real(Yopt))<0);
            if~covPosDef



                if noiseFromFile
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDef'],...
                    auxData.filename,block));
                else
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDefNoFile'],block));
                end
                Fmin=10.^(blockNF/10);
                Rn=real(Z0)*(Fmin-1)/4;
                Yopt=1/Z0;
                YCorr=2/real(Z0)-Yopt;

                Gn=(Fmin-1).*(real(1/Z0)-(1/real(Z0)));

            else
                YCorr=((Fmin-1)./(2*Rn))-Yopt;



                Gn=(Fmin-1).*(real(Yopt)-((Fmin-1)./(4*Rn)));

            end

            VnVariance=4*K*T*Rn;
            InVariance=4*K*T*Gn;

            if((~covPosDef)||(all(abs(Gn)<eps(abs(real(Yopt))))))


                CholCa=zeros(2,2,length(VnVariance));
                CholCa(1,1,:)=sqrt(VnVariance);
                if(((~covPosDef)||...
                    (all(abs(YCorr-1/Z0)<eps(abs(1/Z0)))))&&...
                    ((~dataSource)&&(Zin_mid==Z0)))







                    NoiseBlk='Mid ZinNoise';
                    repNoiseBlk='simrfV2private/InterNoiseOnlyVn';
                else




                    NoiseBlk='Front ZinNoise';
                    repNoiseBlk='simrfV2private/InterNoiseNoIn';
                    CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
                end
                NoiseBlk_lib='simrfV2private';

                constNoise=isConst(VnVariance,4*K*T*50)&&...
                isConst(YCorr,1/50);
            else
                NoiseBlk='Front ZinNoise';


                repNoiseBlk='simrfV2private/InterNoiseFull';
                NoiseBlk_lib='simrfV2private';
                CholCa=zeros(2,2,length(VnVariance));
                CholCa(1,1,:)=sqrt(VnVariance);
                CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
                CholCa(2,2,:)=sqrt(InVariance);

                constNoise=isConst(VnVariance,4*K*T*50)&&...
                isConst(YCorr,1/50)&&...
                isConst(InVariance,4*K*T/50);
            end
        end
        if((~constNoise)&&((noiseFromFile&&~nonLinear)||...
            ~noiseFromFile&&strcmpi(NoiseDist,'Colored')))
            if MaskWSValues.NoiseAutoImpulseLength



                impulse_length=-128*step;
            else


                impulse_length=-simrfV2convert2baseunit(...
                MaskWSValues.NoiseImpulseLength,...
                MaskWSValues.NoiseImpulseLength_unit);

                if impulse_length>0
                    error(message(['simrf:'...
                    ,'simrfV2errors:'...
                    ,'NegativeImpulseLength']));
                end
            end
        else
            impulse_length=0;
        end
        NoiseBlk_params=struct('CholCa',CholCa,'blockFreq',blockFreq,...
        'impulse_length',impulse_length);
    else
        if(dataSource)
            NoiseBlk='Front ZinNoise';





        else
            NoiseBlk='Mid ZinNoise';




        end
        repNoiseBlk='simrfV2private/InterNoiseNoNoise';
        NoiseBlk_lib='simrfV2private';
        NoiseBlk_params=struct();
    end
end

function flag=inside_mixer(block)

    parent=get_param(block,'Parent');
    dp=get_param(parent,'ObjectParameters');
    if isfield(dp,'ReferenceBlock')
        parent_type=get_param(parent,'ReferenceBlock');
        flag=strcmpi(parent_type,'simrfV2elements/Mixer');
    else
        flag=false;
    end
end

function valIsConst=isConst(val,nominalVal)

    stdVal=std(val);
    meanAbsVal=mean(abs(val));
    valIsConst=((meanAbsVal<nominalVal*eps)||...
    ((stdVal/meanAbsVal)<1e8*eps));
end

function out=three_dim_mat_2_str(in)
    freqsLen=size(in,3);
    out='cat(3';
    for fidx=1:freqsLen
        out=sprintf('%s%s%s',out,', ',mat2str(squeeze(in(:,:,fidx))));
    end
    out=[out,')'];
end

function replace_block_if_diff(block,RepBlk,SrcLib,SrcBlk)

    RepBlkFullPath=find_system(block,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'Name',RepBlk);
    if((~isempty(RepBlkFullPath))&&...
        (~strcmpi(get_param(RepBlkFullPath{1},'ReferenceBlock'),SrcBlk)))
        load_system(SrcLib)
        replace_block(block,'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Name',RepBlk,SrcBlk,'noprompt');
    end
end