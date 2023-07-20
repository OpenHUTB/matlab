function vC0d=VariableCapacitorCback(action,block,methode,vC0,C0,iC0)





    switch action

    case 'Parameters'

        Initialize=get_param(block,'Initialize');

        Parameters=Simulink.Mask.get(block).Parameters;

        Vc0=strcmp(get_param(block,'MaskNames'),'vC0')==1;
        C0=strcmp(get_param(block,'MaskNames'),'C0')==1;

        Parameters(Vc0).Visible=Initialize;
        Parameters(C0).Visible=Initialize;

        vC0d=0;

    case 'Initialize'
        switch get_param(block,'Initialize')
        case 'on'
            PowerguiInfo=getPowerguiInfo(bdroot(block),block);
            switch methode
            case 1
                vC0d=vC0/PowerguiInfo.Ts-iC0/C0;
            case 2
                vC0d=vC0/PowerguiInfo.Ts-iC0/C0/2;
            end
        case 'off'
            switch methode
            case 1
                vC0d=-iC0/C0;
            case 2
                vC0d=-iC0/C0/2;
            end
        end

    end