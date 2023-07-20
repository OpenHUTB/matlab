function SynchronousMachineCback(block,Units,Option)





    if~exist('Option','var')
        Option='';
    end

    aMaskObj=Simulink.Mask.get(block);
    OldOptionControl=aMaskObj.getDialogControl('OldOption');
    NewOptionControl=aMaskObj.getDialogControl('NewOption');
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

    if~exist('Units','var')
        Units=get_param(block,'Units');
    end

    RoundRotor=strcmp('Round',get_param(block,'RotorType'));
    WantTorqueInput=strcmp('Mechanical power Pm',get_param(block,'MechanicalLoad'));
    WantShaftInput=strcmp('Mechanical rotational port',get_param(block,'MechanicalLoad'));



    if strcmp('on',get_param(block,'SetSaturation'))
        Saturation='on';
    else
        Saturation='off';
    end

    if WantTorqueInput||WantShaftInput
        Mechanical='on';
        PolePairsVisible='off';
    else
        Mechanical='off';
        PolePairsVisible='on';
    end

    switch Units
    case{'SI fundamental parameters','per unit fundamental parameters'}
        if RoundRotor
            Dampers2='on';
            Dampers1='off';
        else
            Dampers2='off';
            Dampers1='on';
        end
    end

    MaskVisibilities=get_param(block,'Maskvisibilities');

    switch Units

    case 'SI fundamental parameters'


        MaskVisibilities{10}=Dampers2;
        MaskVisibilities{11}=Dampers1;
        MaskVisibilities{12}=Mechanical;
        MaskVisibilities{13}=PolePairsVisible;
        MaskVisibilities{16}='on';

        LFoffset=23;

    case 'per unit fundamental parameters'


        MaskVisibilities{10}=Dampers2;
        MaskVisibilities{11}=Dampers1;
        MaskVisibilities{12}=Mechanical;
        MaskVisibilities{13}=PolePairsVisible;
        MaskVisibilities{16}='on';

        LFoffset=22;

    case 'per unit standard parameters'

        Shortd=strcmp(get_param(block,'dAxisTimeConstants'),'Short-circuit');
        Shortq=strcmp(get_param(block,'qAxisTimeConstants'),'Short-circuit');

        if RoundRotor
            Reactances1='on';
            Reactances2='off';
        else
            Reactances1='off';
            Reactances2='on';
        end

        TimeConstants1='off';
        TimeConstants2='off';
        TimeConstants3='off';
        TimeConstants4='off';
        TimeConstants5='off';
        TimeConstants6='off';
        TimeConstants7='off';
        TimeConstants8='off';

        switch mat2str([Shortd+0,Shortq+0,RoundRotor+0])
        case '[0 0 0]'
            TimeConstants1='on';
        case '[0 0 1]'
            TimeConstants2='on';
        case '[0 1 0]'
            TimeConstants3='on';
        case '[0 1 1]'
            TimeConstants4='on';
        case '[1 0 0]'
            TimeConstants5='on';
        case '[1 0 1]'
            TimeConstants6='on';
        case '[1 1 0]'
            TimeConstants7='on';
        case '[1 1 1]'
            TimeConstants8='on';
        end

        MaskVisibilities{8}=Reactances1;
        MaskVisibilities{9}=Reactances2;
        MaskVisibilities{12}=TimeConstants1;
        MaskVisibilities{13}=TimeConstants2;
        MaskVisibilities{14}=TimeConstants3;
        MaskVisibilities{15}=TimeConstants4;
        MaskVisibilities{16}=TimeConstants5;
        MaskVisibilities{17}=TimeConstants6;
        MaskVisibilities{18}=TimeConstants7;
        MaskVisibilities{19}=TimeConstants8;
        MaskVisibilities{21}=Mechanical;
        MaskVisibilities{22}=PolePairsVisible;
        MaskVisibilities{25}='on';

        LFoffset=31;

    end


    switch get_param(block,'BusType')
    case 'swing'
        MaskVisibilities{LFoffset+1}='off';
        MaskVisibilities{LFoffset+2}='off';
        MaskVisibilities{LFoffset+3}='off';
        MaskVisibilities{LFoffset+4}='off';
    case 'PV'
        MaskVisibilities{LFoffset+1}='on';
        MaskVisibilities{LFoffset+2}='off';
        MaskVisibilities{LFoffset+3}='on';
        MaskVisibilities{LFoffset+4}='on';
    case 'PQ'
        MaskVisibilities{LFoffset+1}='on';
        MaskVisibilities{LFoffset+2}='on';
        MaskVisibilities{LFoffset+3}='off';
        MaskVisibilities{LFoffset+4}='off';
    end




    set_param(block,'Maskvisibilities',MaskVisibilities);




    powerlibroot=which('powersysdomain');
    MachineParametersDirectory=[powerlibroot(1:end-16),'MachineParameters',filesep];
    PresetModel=get_param(block,'PresetModel');
    SimulationIsStopped=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));
    MaskEnables=get_param(block,'MaskEnables');

    if~strcmp(PresetModel,'No')&&SimulationIsStopped

        Indice=eval(PresetModel(1:2));

        switch Units

        case 'per unit fundamental parameters'

            switch Option
            case 'UpdateBlock'

                load([MachineParametersDirectory,'SMparametersFUN_PU']);

                set_param(block,'RotorType','Salient-pole');
                set_param(block,'NominalParameters',mat2str([Machines(Indice).Pn,Machines(Indice).Vn,Machines(Indice).fn],4));
                set_param(block,'Stator',mat2str([Machines(Indice).Rs,Machines(Indice).Ll,Machines(Indice).Lmd,Machines(Indice).Lmq],4));
                set_param(block,'Field',mat2str([Machines(Indice).Rf,Machines(Indice).Llfd],4));
                set_param(block,'Dampers1',mat2str([Machines(Indice).Rkd,Machines(Indice).Llkd,Machines(Indice).Rkq1,Machines(Indice).Llkq1],4));
                set_param(block,'Mechanical',mat2str([Machines(Indice).H,Machines(Indice).F,Machines(Indice).p],4));
                set_param(block,'PolePairs',mat2str(Machines(Indice).p,4));
            end

            MaskEnables{4}='off';
            MaskEnables{5}='off';
            MaskEnables{6}='off';
            MaskEnables{7}='off';
            MaskEnables{9}='off';
            MaskEnables{10}='off';
            MaskEnables{11}='off';
            MaskEnables{16}='off';

        case 'SI fundamental parameters'

            switch Option
            case 'UpdateBlock'

                load([MachineParametersDirectory,'SMparametersFUN_SI']);

                set_param(block,'RotorType','Salient-pole');
                set_param(block,'NominalParameters',mat2str([Machines(Indice).Pn,Machines(Indice).Vn,Machines(Indice).fn],4));
                set_param(block,'Stator',mat2str([Machines(Indice).Rs,Machines(Indice).Ll,Machines(Indice).Lmd,Machines(Indice).Lmq],4));
                set_param(block,'Field',mat2str([Machines(Indice).Rf,Machines(Indice).Llfd],4));
                set_param(block,'Dampers1',mat2str([Machines(Indice).Rkd,Machines(Indice).Llkd,Machines(Indice).Rkq1,Machines(Indice).Llkq1],4));
                set_param(block,'Mechanical',mat2str([Machines(Indice).J,Machines(Indice).B,Machines(Indice).p],4));
                set_param(block,'PolePairs',mat2str(Machines(Indice).p,4));
            end

            MaskEnables{4}='off';
            MaskEnables{5}='off';
            MaskEnables{6}='off';
            MaskEnables{7}='off';
            MaskEnables{9}='off';
            MaskEnables{10}='off';
            MaskEnables{11}='off';
            MaskEnables{16}='off';

        case 'per unit standard parameters'

            switch Option
            case 'UpdateBlock'
                load([MachineParametersDirectory,'SMparametersSTD_PU']);

                set_param(block,'RotorType','Salient-pole');
                set_param(block,'dAxisTimeConstants','Short-circuit');
                set_param(block,'qAxisTimeConstants','Short-circuit');
                set_param(block,'NominalParameters',mat2str([Machines(Indice).Pn,Machines(Indice).Vn,Machines(Indice).fn],4));
                set_param(block,'Reactances2',mat2str([Machines(Indice).Xd,Machines(Indice).Xpd,Machines(Indice).Xsd,Machines(Indice).Xq,Machines(Indice).Xsq,Machines(Indice).Xl],4));
                set_param(block,'TimeConstants7',mat2str([Machines(Indice).Tpd,Machines(Indice).Tsd,Machines(Indice).Tsq],4));
                set_param(block,'StatorResistance',mat2str(Machines(Indice).Rs));
                set_param(block,'Mechanical',mat2str([Machines(Indice).H,Machines(Indice).F,Machines(Indice).p],4));
                set_param(block,'PolePairs',mat2str(Machines(Indice).p,4));
            end

            MaskEnables{4}='off';
            MaskEnables{5}='off';
            MaskEnables{7}='off';
            MaskEnables{8}='off';
            MaskEnables{9}='off';
            MaskEnables{16}='off';
            MaskEnables{18}='off';
            MaskEnables{19}='off';
            MaskEnables{20}='off';

            MaskEnables{25}='off';

        end

    end

    if strcmp(PresetModel,'No')
        if RoundRotor
            MaskEnables{1}='off';
        else
            MaskEnables{1}='on';
        end
        switch Units
        case{'per unit fundamental parameters','SI fundamental parameters'}
            MaskEnables{4}='on';
            MaskEnables{5}='on';
            MaskEnables{6}='on';
            MaskEnables{7}='on';
            MaskEnables{9}='on';
            MaskEnables{10}='on';
            MaskEnables{11}='on';
            MaskEnables{16}=Saturation;

        case 'per unit standard parameters'
            MaskEnables{4}='on';
            MaskEnables{5}='on';
            MaskEnables{7}='on';
            MaskEnables{8}='on';
            MaskEnables{9}='on';
            MaskEnables{16}='on';
            MaskEnables{18}='on';
            MaskEnables{19}='on';
            MaskEnables{20}='on';
            MaskEnables{25}=Saturation;
        end
    end

    MaskEnables{end-8}='on';
    MaskEnables{end-7}='on';

    set_param(block,'MaskEnables',MaskEnables);