function PMSynchronousMachineCback(block,option,Update)









    if~exist('option','var')



        UpdatePorts=0;
    else
        UpdatePorts=strcmp(option,'UpdatePorts');
    end

    if~exist('Update','var')
        Update='';
    end

    aMaskObj=Simulink.Mask.get(block);
    AdvancedTab=aMaskObj.getDialogControl('Advanced');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        switch get_param(block,'Tsblock')
        case '-1'
            AdvancedTab.Visible='off';
        otherwise
            AdvancedTab.Visible='on';
        end
    else
        if PowerguiInfo.AutomaticDiscreteSolvers
            AdvancedTab.Visible='off';
        else
            AdvancedTab.Visible='on';
        end
    end




    ports=get_param(block,'ports');
    HaveThreePhases=ports(6)==3||ports(6)==4;
    HaveFivePhases=ports(6)==5||ports(6)==6;



    Want3Phases=strcmp(get_param(block,'NbPhases'),'3');
    if HaveFivePhases&&Want3Phases&&UpdatePorts

        PortHandles=get_param([block,'/PMSM'],'PortHandles');
        ligne2=get_param(PortHandles.RConn(2),'line');
        ligne3=get_param(PortHandles.RConn(3),'line');

        if ligne2~=-1

            delete_line(ligne2);
            delete_line(ligne3);
            delete_block([block,'/D']);
            delete_block([block,'/E']);
        end

    end



    Want5Phases=strcmp(get_param(block,'NbPhases'),'5');
    if HaveThreePhases&&Want5Phases&&UpdatePorts

        add_block('built-in/PMIOPort',[block,'/D']);
        set_param([block,'/D'],'Position',[255,70,285,90],'side','Left','orientation','Left');
        add_block('built-in/PMIOPort',[block,'/E']);
        set_param([block,'/E'],'Position',[255,110,285,130],'side','Left','orientation','Left');

        PMSMPortHandles=get_param([block,'/PMSM'],'PortHandles');
        DPortHandle=get_param([block,'/D'],'PortHandles');
        EPortHandle=get_param([block,'/E'],'PortHandles');

        add_line(block,PMSMPortHandles.RConn(2),DPortHandle.RConn)
        add_line(block,PMSMPortHandles.RConn(3),EPortHandle.RConn)

    end



    MV=get_param(block,'Maskvisibilities');

    WantTorqueInput=strcmp(get_param(block,'MechanicalLoad'),'Torque Tm');
    WantShaftInput=strcmp(get_param(block,'MechanicalLoad'),'Mechanical rotational port');
    WantSinusoidalFlux=strcmp(get_param(block,'FluxDistribution'),'Sinusoidal');
    WantRound=strcmp(get_param(block,'RotorType'),'Round');

    MV{8}='on';

    if WantTorqueInput||WantShaftInput
        MV{17}='on';
        MV{18}='off';
    else
        MV{17}='off';
        MV{18}='on';
    end

    if Want5Phases

        MV{2}='off';
        MV{3}='off';
        MV{5}='on';
        MV{9}='off';
        MV{10}='off';
        MV{11}='on';
        MV{16}='off';
        MV{19}='off';
        MV{20}='on';

    else

        MV{2}='on';

        if WantSinusoidalFlux

            MV{3}='on';
            MV{5}='on';
            MV{9}='off';

            if WantRound
                MV{10}='off';
                MV{11}='on';
                MV{16}='off';
            else
                MV{10}='on';
                MV{11}='off';
                MV{16}='off';
            end

        else

            MV{3}='off';
            MV{5}='off';
            MV{9}='on';
            MV{10}='off';
            MV{11}='off';
            MV{16}='on';

        end

        MV{19}='on';
        MV{20}='off';

    end




    MaskEnables=get_param(block,'MaskEnables')';
    PresetModel=get_param(block,'PresetModel');
    WantPreset=~strcmp(PresetModel,'No');
    MachineConstant=get_param(block,'MachineConstant');

    MaskEnables{2}='on';
    MaskEnables{3}='on';
    MaskEnables{4}='on';
    MaskEnables{5}='on';
    MaskEnables{6}='off';
    MaskEnables{8}='on';
    MaskEnables{9}='on';
    MaskEnables{10}='on';
    MaskEnables{11}='on';
    MaskEnables{12}='on';

    MaskEnables{13}='on';
    MaskEnables{14}='on';
    MaskEnables{15}='on';

    switch MachineConstant

    case 'Flux linkage established by magnets (V.s)'
        MV{13}='on';
        MV{14}='off';
        MV{15}='off';
    case 'Voltage Constant (V_peak L-L / krpm)'
        MV{13}='off';
        MV{14}='on';
        MV{15}='off';
    case 'Torque Constant (N.m / A_peak)'
        MV{13}='off';
        MV{14}='off';
        MV{15}='on';

    end

    MaskEnables{16}='on';
    MaskEnables{17}='on';
    MaskEnables{18}='on';

    if Want3Phases&&WantPreset&&WantSinusoidalFlux

        MaskEnables{8}='off';
        MaskEnables{9}='off';
        MaskEnables{10}='off';
        MaskEnables{11}='off';
        MaskEnables{12}='off';
        MaskEnables{13}='off';
        MaskEnables{14}='off';
        MaskEnables{15}='off';
        MaskEnables{16}='off';
        MaskEnables{17}='off';
        MaskEnables{18}='off';

    end

    set_param(block,'Maskvisibilities',MV);
    set_param(block,'MaskEnables',MaskEnables);



    SimulationIsStopped=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));
    Update=strcmp(Update,'UpdateBlock');

    if Update&&WantPreset&&SimulationIsStopped&&(Want3Phases||Want5Phases)&&WantSinusoidalFlux

        Indice=eval(PresetModel(1:2));

        powerlibroot=which('powersysdomain');
        MachineParametersDirectory=[powerlibroot(1:end-16),'MachineParameters',filesep];

        load([MachineParametersDirectory,'PMSMparameters_SI']);
        set_param(block,'Resistance',mat2str(Machines(Indice).R,4));

        if WantRound
            set_param(block,'La',mat2str(Machines(Indice).Ld,4));
        else
            set_param(block,'dqInductances',mat2str([0.95*Machines(Indice).Ld,1.05*Machines(Indice).Ld],4));
        end

        set_param(block,'MachineConstant','Flux linkage established by magnets (V.s)');
        if Want5Phases
            set_param(block,'Flux',mat2str((3/5)*Machines(Indice).Lambda,4));
        else
            set_param(block,'Flux',mat2str(Machines(Indice).Lambda,4));
        end
        set_param(block,'Mechanical',mat2str([Machines(Indice).J,Machines(Indice).B,Machines(Indice).p,0],4));
        set_param(block,'PolePairs',mat2str(Machines(Indice).p,4));

    end