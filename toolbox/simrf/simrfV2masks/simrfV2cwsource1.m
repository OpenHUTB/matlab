function simrfV2cwsource1(block,action)





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


        switch MaskVals{idxMaskNames.CWSourceType}
        case{'Ideal voltage','Power'}
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
        replace_src_complete=simrfV2repblk(struct('RepBlk',RepBlk,...
        'SrcBlk',['simrfV2_lib/Sources/',SrcBlk],...
        'SrcLib','simrfV2_lib','DstBlk',SrcBlk),block);


        current_rseries=simrfV2_find_repblk(block,'^(Zis0|Resistor)$');
        if strcmpi(MaskVals{idxMaskNames.CWSourceType},'Power')

            replace_rseries='Resistor';
            replace_r_complete=simrfV2repblk(struct('RepBlk',...
            current_rseries,'SrcBlk',...
            'simrfV2_lib/Elements/R_RF',...
            'SrcLib','simrfV2_lib',...
            'DstBlk',replace_rseries),block);
        else

            replace_rseries='Zis0';
            replace_r_complete=simrfV2repblk(struct(...
            'RepBlk',current_rseries,...
            'SrcBlk','simrfV2_lib/Elements/SHORT_RF',...
            'SrcLib','simrfV2_lib','DstBlk',replace_rseries),block);
        end


        if replace_src_complete
            set_param([block,'/',SrcBlk],'Orientation',orientation);
            simrfV2connports(struct('DstBlk','Simulink-PS Converter',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
            'SrcBlk',SrcBlk,'SrcBlkPortStr','RConn',...
            'SrcBlkPortIdx',1),block);
        end

        if replace_src_complete||replace_r_complete
            simrfV2connports(struct('DstBlk',SrcBlk,...
            'DstBlkPortStr',DstBlkPort1,'DstBlkPortIdx',...
            DstBlkPortIdx1,'SrcBlk',replace_rseries,...
            'SrcBlkPortStr','LConn','SrcBlkPortIdx',1),block);
        end

        if replace_r_complete
            simrfV2connports(struct('DstBlk',replace_rseries,...
            'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
            'SrcBlk','RF+','SrcBlkPortStr','RConn',...
            'SrcBlkPortIdx',1),block);
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
            'SrcLib','nesl_utility_internal','DstBlk',negDstBlk,...
            'Param',...
            {{'Side','Right','Orientation','Left','Port','2'}})...
            ,block);
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

            switch MaskVals{idxMaskNames.CWSourceType}
            case 'Ideal voltage'
                Inphase=simrfV2checkparam(MaskWSValues.IVoltage,...
                'Constant in-phase value','finite',...
                carrierlength);
                Quadphase=simrfV2checkparam(...
                MaskWSValues.QVoltage,...
                'Constant quadrature value','finite',...
                carrierlength);

                if~isempty(index_dc)
                    if Quadphase(index_dc)~=0
                        error(message(...
                        'simrf:simrfV2errors:dcquadrature',...
                        'voltage'))
                    end
                end

                Inphase=simrfV2convert2baseunit(Inphase,...
                MaskVals{idxMaskNames.IVoltage_unit});
                Quadphase=simrfV2convert2baseunit(Quadphase,...
                MaskVals{idxMaskNames.QVoltage_unit});

            case 'Power'
                Z0=simrfV2checkimpedance(MaskWSValues.Z0,1,...
                'Resistance in the CW source');
                MagPower=simrfV2convert2baseunit(...
                MaskWSValues.MagPower,...
                MaskVals{idxMaskNames.MagPower_unit});
                MagPower=simrfV2checkparam(MagPower,...
                'Available power','gtez',carrierlength);

                AnglePower=simrfV2checkparam(...
                MaskWSValues.AnglePower,...
                'Angle','finite',carrierlength);
                check_dc_angle(AnglePower,CarrierFreq);
                [Inphase,Quadphase]=power2voltage(MagPower,...
                AnglePower,Z0);
                set_param([block,'/Resistor'],'R',...
                num2str(Z0,16));

            case 'Ideal current'
                Inphase=simrfV2checkparam(MaskWSValues.ICurrent,...
                'Constant in-phase value','finite',...
                carrierlength);
                Quadphase=simrfV2checkparam(...
                MaskWSValues.QCurrent,...
                'Constant quadrature value','finite',...
                carrierlength);
                if~isempty(index_dc)
                    if Quadphase(index_dc)~=0
                        error(message(...
                        'simrf:simrfV2errors:dcquadrature',...
                        'current'))
                    end
                end

                Inphase=simrfV2convert2baseunit(Inphase,...
                MaskVals{idxMaskNames.ICurrent_unit});
                Quadphase=simrfV2convert2baseunit(Quadphase,...
                MaskVals{idxMaskNames.QCurrent_unit});
            end

            [~,~,AddNoise,~,~,step,spf]=...
            simrfV2_find_solverparams(top_sys,block,1);



            InphaseVec=reshape(repmat(Inphase,spf,1),[],1);
            QuadphaseVec=reshape(repmat(Quadphase,spf,1),[],1);
            set_param([block,'/Constant_real'],'Value',...
            simrfV2vector2str(InphaseVec));
            set_param([block,'/Constant_imag'],'Value',...
            simrfV2vector2str(QuadphaseVec));


            set_param([block,'/Simulink-PS Converter'],'Frequencies',...
            simrfV2vector2str(CarrierFreq));
            set_param([block,'/Simulink-PS Converter'],...
            'PseudoPeriodic','on');

            if((AddNoise)&&(MaskWSValues.AddPhaseNoise))
                [CarrFreqSorted,PhNoFreq,phNoLevIntNorm]=...
                simrfV2getphasenoise(block,MaskWSValues,...
                CarrierFreq,step);
                if~isempty(PhNoFreq)&&~isempty(phNoLevIntNorm)
                    set_param([block,'/Simulink-PS Converter'],...
                    'NoiseDistribution','white');
                    if ssc_rf_set_global_parameter('estimatememory')
                        set_param([block,'/Simulink-PS Converter'],...
                        'NoiseParameters','-1');
                        set_param([block,'/Simulink-PS Converter'],...
                        'UserData',struct('NoiseParameters',...
                        [CarrFreqSorted.',PhNoFreq,phNoLevIntNorm].'));
                    else
                        set_param([block,'/Simulink-PS Converter'],...
                        'NoiseParameters',...
                        mat2str([CarrFreqSorted.',PhNoFreq...
                        ,phNoLevIntNorm].'));
                    end
                else
                    set_param([block,'/Simulink-PS Converter'],...
                    'NoiseDistribution','none');
                    set_param([block,'/Simulink-PS Converter'],...
                    'NoiseParameters','1');
                end
            else
                set_param([block,'/Simulink-PS Converter'],...
                'NoiseDistribution','none');
                set_param([block,'/Simulink-PS Converter'],...
                'NoiseParameters','1');
            end
        end

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end
end


function[Vi,Vq]=power2voltage(MagPower,AnglePower,Z0)

    Vmag=sqrt(4*MagPower*real(Z0));
    Vi=Vmag.*cosd(AnglePower);
    Vq=Vmag.*sind(AnglePower);
end

function check_dc_angle(AnglePower,CarrierFreq)

    idx=find(CarrierFreq==0,1);
    if AnglePower(idx)~=0
        error(message('simrf:simrfV2errors:AngleNotZeroAtDC'));
    end

end