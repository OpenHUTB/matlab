function AsynchronousMachineCback(block,Units,Option)







    if~exist('Option','var')
        Option='';
    end

    aMaskObj=Simulink.Mask.get(block);
    OldOptionControl=aMaskObj.getDialogControl('OldOption');
    NewOptionControl=aMaskObj.getDialogControl('NewOption');
    AdvancedTab=aMaskObj.getDialogControl('Advanced');
    Squirrel=aMaskObj.getDialogControl('Squirrel');
    Wound=aMaskObj.getDialogControl('Wound');

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

    OlSetting=get_param(block,'IterativeModel');
    switch OlSetting
    case 'Forward Euler'
        OldOptionControl.Visible='on';
        NewOptionControl.Visible='off';
    case{'Trapezoidal non iterative','Trapezoidal iterative (alg. loop)'}
        OldOptionControl.Visible='off';
        NewOptionControl.Visible='on';
    case '-1'
        OldOptionControl.Visible='off';
        NewOptionControl.Visible='on';
    end

    RotorType=get_param(block,'RotorType');
    IsDoubleCage=strcmp(RotorType,'Double squirrel-cage');
    IsSingleCage=strcmp(RotorType,'Squirrel-cage');
    IsWound=strcmp(RotorType,'Wound');

    WantTorqueInput=strcmp(get_param(block,'MechanicalLoad'),'Torque Tm');
    WantShaftInput=strcmp(get_param(block,'MechanicalLoad'),'Mechanical rotational port');
    SetSaturation=strcmp('on',get_param(block,'SimulateSaturation'));



    MaskVisibilities=get_param(block,'Maskvisibilities');
    if WantTorqueInput||WantShaftInput
        MaskVisibilities{14+1}='on';
        MaskVisibilities{15+1}='off';
    else
        MaskVisibilities{14+1}='off';
        MaskVisibilities{15+1}='on';
    end

    if IsDoubleCage
        MaskVisibilities{10+1}='off';
        MaskVisibilities{11+1}='on';
        MaskVisibilities{12+1}='on';
    else
        MaskVisibilities{10+1}='on';
        MaskVisibilities{11+1}='off';
        MaskVisibilities{12+1}='off';
    end



    MaskVisibilities{5}='on';

    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        MaskVisibilities{5}='off';
    elseif PowerguiInfo.Discrete
        if PowerguiInfo.AutomaticDiscreteSolvers
            MaskVisibilities{5}='off';
        else
            IM=getSPSmaskvalues(block,{'IterativeDiscreteModel'});
            if strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust')
                MaskVisibilities{5}='off';
            end
        end
    end

    if IsWound
        Squirrel.Visible='off';
        Wound.Visible='on';
        MaskVisibilities{9}='on';
    else
        Squirrel.Visible='on';
        Wound.Visible='off';
        MaskVisibilities{9}='off';
    end

    set_param(block,'Maskvisibilities',MaskVisibilities);


    switch Option

    case 'UpdateBlock'

        ports=get_param(block,'ports');
        HaveRotorPorts=ports(7)==3;

        if~IsWound&&HaveRotorPorts

            PortHandles=get_param([block,'/ASM'],'PortHandles');
            ligne1=get_param(PortHandles.RConn(1),'line');
            ligne2=get_param(PortHandles.RConn(2),'line');
            ligne3=get_param(PortHandles.RConn(3),'line');

            if ligne1~=-1
                delete_line(ligne1);
                delete_line(ligne2);
                delete_line(ligne3);
                delete_block([block,'/a']);
                delete_block([block,'/b']);
                delete_block([block,'/c']);
            end

        end

        if IsWound&&~HaveRotorPorts

            add_block('built-in/PMIOPort',[block,'/a']);
            set_param([block,'/a'],'Position',[220,25,250,45],'side','Right','orientation','left');
            add_block('built-in/PMIOPort',[block,'/b']);
            set_param([block,'/b'],'Position',[220,60,250,80],'side','Right','orientation','left');
            add_block('built-in/PMIOPort',[block,'/c']);
            set_param([block,'/c'],'Position',[220,95,250,115],'side','Right','orientation','left');

            ASMPortHandles=get_param([block,'/ASM'],'PortHandles');
            aPortHandle=get_param([block,'/a'],'PortHandles');
            bPortHandle=get_param([block,'/b'],'PortHandles');
            cPortHandle=get_param([block,'/c'],'PortHandles');

            add_line(block,ASMPortHandles.RConn(1),aPortHandle.RConn)
            add_line(block,ASMPortHandles.RConn(2),bPortHandle.RConn)
            add_line(block,ASMPortHandles.RConn(3),cPortHandle.RConn)

        end

    end




    powerlibroot=which('powersysdomain');
    MachineParametersDirectory=[powerlibroot(1:end-16),'MachineParameters',filesep];
    PresetModel=get_param(block,'PresetModel');
    WantPresetModel=~strcmp(PresetModel,'No');
    SimulationIsStopped=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));

    MaskEnables=get_param(block,'MaskEnables');


    if IsSingleCage
        MaskEnables{2}='on';
    else
        MaskEnables{2}='off';
    end

    if WantPresetModel&&IsSingleCage
        if SimulationIsStopped

            Indice=eval(PresetModel(1:2));

            if~exist('Units','var')
                Units=get_param(block,'Units');
            end

            switch Option
            case 'UpdateBlock'

                if strcmp(Units,'pu')
                    load([MachineParametersDirectory,'ASMparameters_PU']);
                else
                    load([MachineParametersDirectory,'ASMparameters_SI']);

                    Machines(Indice).H=Machines(Indice).J;%#ok
                    Machines(Indice).F=Machines(Indice).B;
                end


                set_param(block,'NominalParameters',mat2str([Machines(Indice).P,Machines(Indice).V,Machines(Indice).f],4));
                set_param(block,'Stator',mat2str([Machines(Indice).Rs,Machines(Indice).Lls],4));
                set_param(block,'Rotor',mat2str([Machines(Indice).Rr,Machines(Indice).Llr],4));
                set_param(block,'Lm',mat2str(Machines(Indice).Lm,4));

                set_param(block,'Mechanical',mat2str([Machines(Indice).H,Machines(Indice).F,Machines(Indice).ppole],4));
                set_param(block,'PolePairs',mat2str(Machines(Indice).ppole,4));
            end

            MaskEnables{4}='off';
            MaskEnables{8}='off';
            MaskEnables{9+1}='off';
            MaskEnables{10+1}='off';
            MaskEnables{11+1}='off';
            MaskEnables{12+1}='off';
            MaskEnables{13+1}='off';
            MaskEnables{14+1}='off';
            MaskEnables{15+1}='off';

        end
    else
        MaskEnables{4}='on';
        MaskEnables{8}='on';
        MaskEnables{9+1}='on';
        MaskEnables{10+1}='on';
        MaskEnables{11+1}='on';
        MaskEnables{12+1}='on';

        if SetSaturation
            MaskEnables{13+1}='off';
        else
            MaskEnables{13+1}='on';
        end

        MaskEnables{14+1}='on';
        MaskEnables{15+1}='on';

    end

    if SetSaturation
        MaskEnables{18+1}='on';
    else
        MaskEnables{18+1}='off';
    end

    MaskEnables{19+1}='on';

    set_param(block,'MaskEnables',MaskEnables);
