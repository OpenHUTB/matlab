function simrfV2gatewayout1(block,action)







    top_sys=bdroot(block);
    if strcmpi(top_sys,'simrfV2util1')
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

        useInternalGnd=strcmpi(MaskVals{idxMaskNames.InternalGrounding},'on');
        sensorType=lower(MaskVals{idxMaskNames.SensorType});
        outputFormat=lower(MaskVals{idxMaskNames.OutputFormat});
        isPower=strcmpi(sensorType,'Power');
        isUpdating=regexpi(get_param(top_sys,'SimulationStatus'),...
        '^(updating|initializing)$');




        if getSimulinkBlockHandle([block,'/Res1'])>0
            oldSensorType='Power';
        elseif getSimulinkBlockHandle([block,'/Voltage Sensor'])>0
            oldSensorType='ideal voltage';
        else
            oldSensorType='ideal current';
        end
        notSameSensor=~strcmpi(sensorType,oldSensorType);


        pc=get_param([block,'/Reshape'],'PortConnectivity');
        dst=get_param(pc(2).DstBlock,'Name');
        switch dst
        case 'SL'
            oldOutputFormat='complex baseband';
        case 'CP_RI'
            oldOutputFormat='in-phase and quadrature baseband';
        case 'CP_MA'
            oldOutputFormat='magnitude and angle baseband';
        case 'Calc_RP'
            oldOutputFormat='real passband';
        otherwise
            oldOutputFormat='unknown';
        end
        notSameOutput=~strcmpi(outputFormat,oldOutputFormat);


        if getSimulinkBlockHandle([block,'/RF-'])<0
            oldInternalGrounding=true;
        else
            oldInternalGrounding=false;
        end
        notSameGrounding=(useInternalGnd~=oldInternalGrounding);




        if notSameSensor||notSameGrounding||notSameOutput
            if useInternalGnd
                m='port_label(''LConn'',1,'''')';
            else
                m='port_label(''LConn'',1,'''')';
                m=sprintf('%s\nport_label(''LConn'',2,'''')',m);
            end
            switch outputFormat
            case 'complex baseband'
                m=sprintf('%s\nport_label(''Output'',1,''BB'')',m);
            case 'magnitude and angle baseband'
                m=sprintf('%s\nport_label(''Output'',1,''Mag'')',m);
                m=sprintf('%s\nport_label(''Output'',2,''Ang'')',m);
            case 'in-phase and quadrature baseband'
                m=sprintf('%s\nport_label(''Output'',1,''I'')',m);
                m=sprintf('%s\nport_label(''Output'',2,''Q'')',m);
            case 'real passband'
                m=sprintf('%s\nport_label(''Output'',1,''PB'')',m);
            end
            simrfV2_set_param(block,'MaskDisplay',m)
        end

        if notSameSensor||notSameGrounding

            switch sensorType
            case{'ideal voltage','power'}
                RepBlk='Current Sensor';
                SrcBlk='Voltage Sensor';
            case 'ideal current'
                RepBlk='Voltage Sensor';
                SrcBlk='Current Sensor';




                Res1=getSimulinkBlockHandle([block,'/Res1']);
                if Res1>0
                    simrfV2_delete_lines_from_block(block,'Res1')
                    delete_block([block,'/Res1'])
                end
            end

            replace_src_complete=simrfV2repblk(struct(...
            'RepBlk',RepBlk,...
            'SrcBlk',['simrfV2_lib/Sources/',SrcBlk],...
            'SrcLib','simrfV2_lib',...
            'DstBlk',SrcBlk),block);



            if replace_src_complete

                set_param([block,'/',SrcBlk],'BlockMirror','off')
                set_param([block,'/',SrcBlk],'BlockRotation','90')
                simrfV2connports(struct(...
                'DstBlk','PS-Simulink Converter',...
                'DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1,...
                'SrcBlk',SrcBlk,...
                'SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block)
                simrfV2connports(struct(...
                'DstBlk','RF+',...
                'DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1,...
                'SrcBlk',SrcBlk,...
                'SrcBlkPortStr','LConn',...
                'SrcBlkPortIdx',1),block)
            end


            if useInternalGnd

                negDstBlk='Gnd';
                negDstBlkPortStr='LConn';
                replace_gnd_complete=simrfV2repblk(struct(...
                'RepBlk','RF-',...
                'SrcBlk','simrfV2elements/Gnd',...
                'SrcLib','simrfV2elements',...
                'DstBlk',negDstBlk),block);
            else

                negDstBlk='RF-';
                negDstBlkPortStr='RConn';
                replace_gnd_complete=simrfV2repblk(struct(...
                'RepBlk','Gnd',...
                'SrcBlk','nesl_utility_internal/Connection Port',...
                'SrcLib','nesl_utility_internal',...
                'DstBlk',negDstBlk,...
                'Param',...
                {{'Side','Left','Orientation','right','Port','2'}}),...
                block);
            end


            Res1=getSimulinkBlockHandle([block,'/Res1']);
            if isPower
                if Res1<0
                    add_block(...
                    'simrfV2_lib/Elements/R_RF',...
                    [block,'/Res1'],'Position',[80,80,120,120])
                    set_param([block,'/Res1'],'Orientation','up')
                    simrfV2connports(struct(...
                    'DstBlk','Res1',...
                    'DstBlkPortStr','LConn',...
                    'DstBlkPortIdx',1,...
                    'SrcBlk',SrcBlk,...
                    'SrcBlkPortStr','RConn',...
                    'SrcBlkPortIdx',2),block)
                    simrfV2connports(struct(...
                    'DstBlk','Res1',...
                    'DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1,...
                    'SrcBlk',SrcBlk,...
                    'SrcBlkPortStr','LConn',...
                    'SrcBlkPortIdx',1),block)
                end
            elseif Res1>0
                simrfV2_delete_lines_from_block(block,'Res1')
                delete_block([block,'/Res1'])
            end


            if replace_gnd_complete||replace_src_complete
                simrfV2connports(struct(...
                'DstBlk',SrcBlk,...
                'DstBlkPortStr','RConn',...
                'DstBlkPortIdx',2,...
                'SrcBlk',negDstBlk,...
                'SrcBlkPortStr',negDstBlkPortStr,...
                'SrcBlkPortIdx',1),block)
            end
        end

        if notSameOutput

            simrfV2_delete_lines_from_block(block,'Reshape',{'Outport'})
            switch oldOutputFormat
            case 'complex baseband'

            case 'magnitude and angle baseband'
                simrfV2_delete_lines_from_block(block,'CP_MA',{'Outport'})
                delete_block([block,'/CP_MA'])

            case 'in-phase and quadrature baseband'
                simrfV2_delete_lines_from_block(block,'CP_RI',{'Outport'})
                delete_block([block,'/CP_RI'])

            case 'real passband'
                simrfV2_delete_lines_from_block(block,'Calc_RP',...
                {'Outport'})
                delete_block([block,'/Calc_RP'])


                simrfV2_delete_lines_from_block(block,'Gain',{'Inport'});
                add_block('simulink/Signal Routing/Demux',...
                [block,'/Demux'],'Position',[350,76,355,114])
                add_line(block,'PS-Simulink Converter/1','Demux/1',...
                'autorouting','on')
                add_block(...
                'simulink/Math Operations/Real-Imag to Complex',...
                [block,'/RI_CP'],'Position',[400,83,430,112])
                add_line(block,'Demux/1','RI_CP/1','autorouting','on')
                add_line(block,'Demux/2','RI_CP/2','autorouting','on')
                add_line(block,'RI_CP/1','Gain/1','autorouting','on')
            end


            out1=simrfV2_find_repblk(block,'^(I|Mag|SL)$');
            out2=simrfV2_find_repblk(block,'^(Q|Ang)$');
            switch outputFormat
            case 'complex baseband'
                set_param([block,'/',out1],'Name','SL')
                if~isempty(out2)
                    delete_block([block,'/',out2])
                end
                add_line(block,'Reshape/1','SL/1','autorouting','on')

            case 'magnitude and angle baseband'
                add_block(['simulink/Math Operations/Complex to '...
                ,'Magnitude-Angle'],...
                [block,'/CP_MA'],'Position',[535,75,565,105])
                set_param([block,'/',out1],'Name','Mag')
                if isempty(out2)
                    add_block('simulink/Ports & Subsystems/Out1',...
                    [block,'/','Ang'],'Position',[630,135,660,150])
                else
                    set_param([block,'/',out2],'Name','Ang')
                end
                add_line(block,'Reshape/1','CP_MA/1','autorouting','on')
                add_line(block,'CP_MA/1','Mag/1','autorouting','on')
                add_line(block,'CP_MA/2','Ang/1','autorouting','on')

            case 'in-phase and quadrature baseband'
                add_block(...
                'simulink/Math Operations/Complex to Real-Imag',...
                [block,'/CP_RI'],'Position',[535,75,565,105])
                set_param([block,'/',out1],'Name','I')
                if isempty(out2)
                    add_block('simulink/Ports & Subsystems/Out1',...
                    [block,'/Q'],'Position',[630,135,660,150])
                else
                    set_param([block,'/',out2],'Name','Q')
                end
                add_line(block,'Reshape/1','CP_RI/1','autorouting','on')
                add_line(block,'CP_RI/1','I/1','autorouting','on')
                add_line(block,'CP_RI/2','Q/1','autorouting','on')

            case 'real passband'

                simrfV2_delete_lines_from_block(block,'Demux')
                delete_block([block,'/Demux'])
                simrfV2_delete_lines_from_block(block,'RI_CP')
                delete_block([block,'/RI_CP'])
                add_line(block,'PS-Simulink Converter/1','Gain/1',...
                'autorouting','on')
                load_system('simrfV2private')
                add_block('simrfV2private/Calc_RP',...
                [block,'/Calc_RP'],'Position',[540,80,585,110])
                set_param([block,'/',out1],'Name','SL')
                if~isempty(out2)
                    delete_block([block,'/',out2])
                end
                add_line(block,'Reshape/1','Calc_RP/1','autorouting','on')
                add_line(block,'Calc_RP/1','SL/1','autorouting','on')
            end
        end



        if isUpdating

            outputfreq=...
            simrfV2checkfreqs(MaskWSValues.CarrierFreq,'gtez');
            outputfreq=simrfV2convert2baseunit(outputfreq,...
            MaskVals{idxMaskNames.CarrierFreq_unit});
        end

        [~,~,~,~,normalize,simrf_step,spf]=...
        simrfV2_find_solverparams(top_sys,block,1);

        if strcmpi(outputFormat,'Real Passband')
            mask_resample_step=MaskWSValues.StepSize;
            mask_resample_step_unit=MaskVals{idxMaskNames.StepSize_unit};

            if isUpdating
                outputfreq_rad=...
                simrfV2vector2str(2*pi*outputfreq,'%20.15g');
                numOutput=numel(outputfreq);

                phase_sin=...
                simrfV2vector2str(pi*ones(1,numOutput),'%20.15g');
                phase_cos=...
                simrfV2vector2str((pi/2)*ones(1,numOutput),'%20.15g');
                bias=simrfV2vector2str(zeros(1,numOutput));



                if spf>1
                    error(message(...
                    'simrf:simrfV2errors:FrameBasedRealPassbandOutput'));
                else
                    set_param([block,'/Reshape'],'OutputDimensionality',...
                    '1-D array');
                end
                if normalize
                    amp=sqrt(2)*ones(1,numOutput);
                    amp(outputfreq==0)=1;
                else
                    amp=ones(1,numOutput);
                end
                amp=simrfV2vector2str(amp);


                if MaskWSValues.AutoStep

                    resample_step=min(1/max(outputfreq)/8,simrf_step);
                    mask_resample_step=resample_step;
                    mask_resample_step_unit='s';
                elseif mask_resample_step~=-1
                    resample_step=...
                    simrfV2convert2baseunit(mask_resample_step,...
                    mask_resample_step_unit);
                else


                    resample_step=simrf_step;
                    mask_resample_step_unit='s';
                end
                resample_step_str=simrfV2vector2str(resample_step);

                set_param([block,'/Calc_RP'],...
                'ResampleStep',resample_step_str,...
                'Amplitude',amp,...
                'Bias',bias,...
                'OutputFreq',outputfreq_rad,...
                'PhaseCos',phase_cos,...
                'PhaseSin',phase_sin)
            end

            auxData=get_param(block,'UserData');
            auxData.AutoStepValue=mask_resample_step;
            auxData.AutoStepValueUnit=mask_resample_step_unit;
            set_param(block,'UserData',auxData)
        else
            nCols=numel(MaskWSValues.CarrierFreq);
            if spf>1
                outDims=sprintf('[%d,%d]',spf,nCols);
            else
                outDims=sprintf('[%d]',nCols);
            end
            set_param([block,'/Reshape'],'OutputDimensionality',...
            'Customize','OutputDimensions',outDims);
        end

        if isUpdating

            set_param([block,'/PS-Simulink Converter'],...
            'Frequencies',simrfV2vector2str(outputfreq,'%20.15g'))


            if isPower

                ZL=simrfV2checkimpedance(MaskWSValues.ZL,1);
                outputgain=num2str(sqrt(real(ZL))/ZL,16);
                set_param([block,'/Res1'],'R',num2str(real(ZL),16))
            else
                outputgain='1';
            end
            set_param([block,'/Gain'],'Gain',outputgain)
        end

        set_param([block,'/PS-Simulink Converter'],'PseudoPeriodic','on')

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end

end

function simrfV2_delete_lines_from_block(parent,name,portnames)
    if nargin<3
        portnames={'Inport','Outport','LConn','RConn'};
    end
    if~isempty(name)
        myblock=[parent,'/',name];
        ph=get_param(myblock,'PortHandles');
        for ii=1:numel(portnames)
            simrfV2deletelines(get_param(ph.(portnames{ii}),'Line'))
        end
    end
end
