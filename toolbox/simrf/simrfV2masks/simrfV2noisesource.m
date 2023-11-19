function simrfV2noisesource(block,action)

    top_sys=bdroot(block);
    if strcmpi(top_sys,'simrfV2sources1')
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

        InternalGrounding=strcmpi(...
        MaskVals{idxMaskNames.InternalGrounding},'on');
        NoiseType=MaskVals{idxMaskNames.NoiseType};



        if any(strcmp(NoiseType,{'White','Piece-wise linear'}))||...
            ((~(MaskWSValues.AutoImpulseLength))&&...
            (((isnumeric(MaskWSValues.ImpulseLength))&&...
            (isscalar(MaskWSValues.ImpulseLength)))&&...
            (MaskWSValues.ImpulseLength==0)))
            RepBlk='CorrNoise1';
            SrcBlkNoise='WhiteNoise1';
        else
            RepBlk='WhiteNoise1';
            SrcBlkNoise='CorrNoise1';
        end
        replace_noise_complete=simrfV2repblk(struct(...
        'RepBlk',RepBlk,...
        'SrcBlk',['simrfV2private/',SrcBlkNoise],...
        'SrcLib','simrfV2private',...
        'DstBlk',SrcBlkNoise),block);



        switch MaskVals{idxMaskNames.SimulinkInputSignalType}
        case{'Ideal voltage'}
            RepBlk='Controlled Current Source';
            SrcBlk='Controlled Voltage Source';
            DstBlkPort1='LConn';
            DstBlkPortIdx1=1;
            DstBlkPort2='RConn';
            DstBlkPortIdx2=2;
            orientation='down';
        case 'Ideal current'
            RepBlk='Controlled Voltage Source';
            SrcBlk='Controlled Current Source';
            DstBlkPort1='RConn';
            DstBlkPortIdx1=2;
            DstBlkPort2='LConn';
            DstBlkPortIdx2=1;
            orientation='up';
        end

        replace_src_complete=simrfV2repblk(struct(...
        'RepBlk',RepBlk,...
        'SrcBlk',['simrfV2_lib/Sources/',SrcBlk],...
        'SrcLib','simrfV2_lib','DstBlk',SrcBlk),block);



        if replace_src_complete
            set_param([block,'/',SrcBlk],'Orientation',orientation);

            simrfV2connports(struct('DstBlk',SrcBlk,...
            'DstBlkPortStr',DstBlkPort1,'DstBlkPortIdx',...
            DstBlkPortIdx1,'SrcBlk','+','SrcBlkPortStr',...
            'RConn','SrcBlkPortIdx',1),block);
        end

        if replace_src_complete||replace_noise_complete
            simrfV2connports(struct('DstBlk',SrcBlkNoise,...
            'DstBlkPortStr','LConn','DstBlkPortIdx',1,...
            'SrcBlk',SrcBlk,'SrcBlkPortStr','RConn',...
            'SrcBlkPortIdx',1),block);
        end


        if InternalGrounding

            DstBlk='Gnd';
            DstBlkPortStr='LConn';
            replace_gnd_complete=simrfV2repblk(struct('RepBlk','-',...
            'SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk',DstBlk),block);
        else

            DstBlk='-';
            DstBlkPortStr='RConn';
            replace_gnd_complete=simrfV2repblk(struct(...
            'RepBlk','Gnd',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk',DstBlk,'Param',...
            {{'Side','Right','Orientation','Left','Port','2'}})...
            ,block);
        end


        if replace_gnd_complete||replace_src_complete
            simrfV2connports(struct('SrcBlk',SrcBlk,'SrcBlkPortStr',...
            DstBlkPort2,'SrcBlkPortIdx',DstBlkPortIdx2,'DstBlk',...
            DstBlk,'DstBlkPortStr',DstBlkPortStr,...
            'DstBlkPortIdx',1),block);
        end


        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')
            blockname=[block,'/',SrcBlkNoise,'/Simulink-PS Converter'];
            switch NoiseType
            case{'White'}
                validateattributes(...
                MaskWSValues.NoisePSD,...
                {'numeric'},{'nonempty','scalar','finite',...
                'real','nonnegative'},'','PSD value');

                set_param(blockname,'NoiseDistribution','white');
                set_param(blockname,'NoiseParameters',...
                simrfV2vector2str(...
                MaskWSValues.NoisePSD));
                set_param(blockname,'PseudoPeriodic','off');
            case{'Piece-wise linear','Colored'}
                freqs=simrfV2convert2baseunit(...
                MaskWSValues.CarrierFreq,...
                MaskWSValues.CarrierFreq_unit);

                freqs=freqs(:)';
                psd=MaskWSValues.NoisePSD(:)';
                validateattributes(...
                psd,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'','PSD value');
                validateattributes(...
                MaskWSValues.CarrierFreq,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                'Frequencies corresponding to noise PSD values');
                if(length(psd)~=length(freqs))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Noise PSD','Frequencies'));
                end




                if strcmp(SrcBlkNoise,'WhiteNoise1')

                    set_param(blockname,'NoiseDistribution','pwl');
                    set_param(blockname,'NoiseParameters',...
                    simrfV2vector2str([freqs,psd]));
                    set_param(blockname,'PseudoPeriodic','off');
                else



                    [~,~,~,~,~,step]=...
                    simrfV2_find_solverparams(bdroot(block),...
                    block,1);
                    if MaskWSValues.AutoImpulseLength



                        impulse_length=128*step;
                    else
                        validateattributes(...
                        MaskWSValues.ImpulseLength,...
                        {'numeric'},{'nonempty','scalar',...
                        'real','finite'},'',...
                        'Phase noise impulse response duration');
                        impulse_length=simrfV2convert2baseunit(...
                        MaskWSValues.ImpulseLength,...
                        MaskWSValues.ImpulseLength_unit);
                        if impulse_length<0
                            error(message(['simrf:'...
                            ,'simrfV2errors:'...
                            ,'NegativeImpulseLength']));
                        end
                    end





                    if(std(psd)<1e-8*mean(psd))
                        impulse_length=0;
                    end





                    NoiseBlock=[block,'/',SrcBlkNoise];
                    set_param(NoiseBlock,...
                    'freqs',simrfV2vector2str(freqs),...
                    'covariance',simrfV2vector2str(psd),...
                    'impulse_length',...
                    simrfV2vector2str(-impulse_length));
                end
            end
        end

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end
end