function simrfV2sinesource1(block,action)





    top_sys=bdroot(block);
    if strcmpi(top_sys,'simrfV2sources1')
        return
    end





    switch(action)
    case 'simrfInit'
        [~,~,~,~,~,~,spf]=...
        simrfV2_find_solverparams(bdroot(block),block,1);

        if spf>1
            error(message('simrf:simrfV2errors:FrameBasedBlockNotSupported',...
            'Sinusoid block'));
        end


        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskWSValues=simrfV2getblockmaskwsvalues(block);

        InternalGrounding=strcmpi(...
        MaskVals{idxMaskNames.InternalGrounding},'on');


        switch MaskVals{idxMaskNames.SineSourceType}
        case 'Ideal voltage'
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
        'SrcLib','simrfV2_lib',...
        'DstBlk',SrcBlk),block);



        if replace_src_complete
            set_param([block,'/',SrcBlk],'Orientation',orientation);
            simrfV2connports(struct('DstBlk','Simulink-PS Converter',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
            'SrcBlk',SrcBlk,'SrcBlkPortStr','RConn',...
            'SrcBlkPortIdx',1),block);

            simrfV2connports(struct('DstBlk',SrcBlk,...
            'DstBlkPortStr',DstBlkPort1,'DstBlkPortIdx',...
            DstBlkPortIdx1,'SrcBlk','RF+','SrcBlkPortStr',...
            'RConn','SrcBlkPortIdx',1),block);
        end


        if InternalGrounding

            negDstBlk='Gnd';
            negDstBlkPortStr='LConn';
            replace_gnd_complete=simrfV2repblk(struct('RepBlk','RF-',...
            'SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk',negDstBlk),block);
        else

            negDstBlk='RF-';
            negDstBlkPortStr='RConn';
            replace_gnd_complete=simrfV2repblk(struct(...
            'RepBlk','Gnd',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk',negDstBlk,'Param',...
            {{'Side','Right','Orientation','Left','Port','2'}}),...
            block);
        end


        if replace_gnd_complete||replace_src_complete
            simrfV2connports(struct('DstBlk',SrcBlk,'DstBlkPortStr',...
            DstBlkPort2,'DstBlkPortIdx',DstBlkPortIdx2,'SrcBlk',...
            negDstBlk,'SrcBlkPortStr',negDstBlkPortStr,...
            'SrcBlkPortIdx',1),block);
        end


        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')

            CarrierFreq=simrfV2checkfreqs(...
            MaskWSValues.CarrierFreq,'gtez');
            CarrierFreq=simrfV2convert2baseunit(CarrierFreq,...
            MaskVals{idxMaskNames.CarrierFreq_unit});
            carrierlength=length(CarrierFreq);
            index_dc=find(CarrierFreq==0);

            switch lower(MaskVals{idxMaskNames.SineSourceType})
            case 'ideal voltage'
                VO_I=simrfV2checkparam(MaskWSValues.VO_I,...
                'Offset in-phase','finite',carrierlength);
                VO_Q=simrfV2checkparam(MaskWSValues.VO_Q,...
                'Offset quadrature','finite',carrierlength);
                VA_I=simrfV2checkparam(MaskWSValues.VA_I,...
                'Sinusoidal amplitude in-phase','finite',...
                carrierlength);
                VA_Q=simrfV2checkparam(MaskWSValues.VA_Q,...
                'Sinusoidal amplitude quadrature','finite',...
                carrierlength);

                if~isempty(index_dc)
                    if VO_Q(index_dc)~=0||VA_Q(index_dc)~=0
                        error(message(...
                        'simrf:simrfV2errors:dcquadrature',...
                        'voltage'))
                    end
                end
                offset_I=simrfV2vector2str(...
                simrfV2convert2baseunit(VO_I,...
                MaskVals{idxMaskNames.VO_I_unit}));
                offset_Q=simrfV2vector2str(...
                simrfV2convert2baseunit(VO_Q,...
                MaskVals{idxMaskNames.VO_Q_unit}));
                amp_I=simrfV2vector2str(...
                simrfV2convert2baseunit(VA_I,...
                MaskVals{idxMaskNames.VA_I_unit}));
                amp_Q=simrfV2vector2str(...
                simrfV2convert2baseunit(VA_Q,...
                MaskVals{idxMaskNames.VA_Q_unit}));

            case 'ideal current'
                IO_I=simrfV2checkparam(MaskWSValues.IO_I,...
                'Offset in-phase','finite',carrierlength);
                IO_Q=simrfV2checkparam(MaskWSValues.IO_Q,...
                'Offset quadrature','finite',carrierlength);
                IA_I=simrfV2checkparam(MaskWSValues.IA_I,...
                'Sinusoidal amplitude in-phase','finite',...
                carrierlength);
                IA_Q=simrfV2checkparam(MaskWSValues.IA_Q,...
                'Sinusoidal amplitude quadrature','finite',...
                carrierlength);
                if~isempty(index_dc)
                    if IO_Q(index_dc)~=0||IA_Q(index_dc)~=0
                        error(message(...
                        'simrf:simrfV2errors:dcquadrature',...
                        'current'))
                    end
                end

                offset_I=simrfV2vector2str(...
                simrfV2convert2baseunit(IO_I,...
                MaskVals{idxMaskNames.IO_I_unit}));
                offset_Q=simrfV2vector2str(...
                simrfV2convert2baseunit(IO_Q,...
                MaskVals{idxMaskNames.IO_Q_unit}));
                amp_I=simrfV2vector2str(...
                simrfV2convert2baseunit(IA_I,...
                MaskVals{idxMaskNames.IA_I_unit}));
                amp_Q=simrfV2vector2str(...
                simrfV2convert2baseunit(IA_Q,...
                MaskVals{idxMaskNames.IA_Q_unit}));
            end

            Fmod=simrfV2checkparam(MaskWSValues.Fmod,...
            'Sinusoidal modulation frequency','gtez',carrierlength);
            Fmod=simrfV2convert2baseunit(Fmod,...
            MaskVals{idxMaskNames.Fmod_unit});

            TD=simrfV2checkparam(MaskWSValues.TD,...
            'Time delay','finite',carrierlength);
            TD=simrfV2convert2baseunit(TD,...
            MaskVals{idxMaskNames.TD_unit});

            omega=simrfV2vector2str(2*pi*Fmod);
            theta=simrfV2vector2str(-2*pi*Fmod.*TD);


            set_param([block,'/Sine_real'],'Amplitude',amp_I,...
            'Bias',offset_I,'Frequency',omega,'Phase',theta,...
            'SampleTime','0')
            set_param([block,'/Sine_imag'],'Amplitude',amp_Q,...
            'Bias',offset_Q,'Frequency',omega,'Phase',theta,...
            'SampleTime','0')


            set_param([block,'/Simulink-PS Converter'],'Frequencies',...
            simrfV2vector2str(CarrierFreq,'%20.15g'));
            set_param([block,'/Simulink-PS Converter'],...
            'PseudoPeriodic','on');
        end

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end
end