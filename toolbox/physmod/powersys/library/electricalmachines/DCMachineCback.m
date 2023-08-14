function DCMachineCback(block,option,update)





    if strcmp(option,'Discrete')


        return
    end

    switch get_param(bdroot(block),'SimulationStatus')
    case{'initializing','updating'}
        return
    end

    if~exist('update','var')
        update='';
    end



    WantTorqueInput=strcmp(get_param(block,'MechanicalLoad'),'Torque TL');
    WantShaftInput=strcmp(get_param(block,'MechanicalLoad'),'Mechanical rotational port');
    WantWound=strcmp(get_param(block,'FieldType'),'Wound');
    WantTorqueConstant=strcmp(get_param(block,'MachineConstant'),'Torque constant (N.m/A)');

    MV=get_param(block,'Maskvisibilities');

    if WantWound
        MV{7}='on';
        MV{8}='on';
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
        MV{16}='off';
    else
        MV{7}='off';
        MV{8}='off';
        MV{9}='on';
        if WantTorqueConstant
            MV{11}='on';
            MV{10}='off';
        else
            MV{11}='off';
            MV{10}='on';
        end
        MV{16}='off';
    end
    if WantTorqueInput||WantShaftInput
        MV{12}='on';
        MV{13}='on';
        MV{14}='on';
        MV{15}='on';
    else
        MV{12}='off';
        MV{13}='off';
        MV{14}='off';
        MV{15}='off';
    end

    set_param(block,'Maskvisibilities',MV);



    MaskEnables=get_param(block,'MaskEnables');
    powerlibroot=which('powersysdomain');
    MachineParametersDirectory=[powerlibroot(1:end-16),'MachineParameters',filesep];
    PresetModel=get_param(block,'PresetModel');

    if~strcmp(PresetModel,'No')
        Indice=eval(PresetModel(1:2));

        switch update
        case 'UpdateBlock'
            load([MachineParametersDirectory,'DCparameters']);
            set_param(block,'FieldType','Wound');
            set_param(block,'RLa',mat2str([Machines(Indice).Ra,Machines(Indice).La],4));
            set_param(block,'RLf',mat2str([Machines(Indice).Rf,Machines(Indice).Lf],4));
            set_param(block,'Laf',mat2str(Machines(Indice).Laf,4));
            set_param(block,'J',mat2str(Machines(Indice).J,4));
            set_param(block,'Bm',mat2str(Machines(Indice).Bm,4));
            set_param(block,'Tf',mat2str(Machines(Indice).Tf,4));
        end

        MaskEnables{3}='off';
        MaskEnables{6}='off';
        MaskEnables{7}='off';
        MaskEnables{8}='off';
        MaskEnables{9}='off';
        MaskEnables{10}='off';
        MaskEnables{11}='off';
        MaskEnables{12}='off';
        MaskEnables{13}='off';
        MaskEnables{14}='off';


    end

    if strcmp(PresetModel,'No')
        for i=1:length(MaskEnables);
            MaskEnables{i}='on';
            if~WantWound
                set_param(block,'PresetModel','No');
                MaskEnables{1}='off';
            else
                MaskEnables{1}='on';
            end
        end
    end

    set_param(block,'MaskEnables',MaskEnables);
