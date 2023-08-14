function phi0d=VariableInductorCback(action,block,methode,iL0,L0,Vl0)





    switch action

    case 'Parameters'

        Initialize=get_param(block,'Initialize');

        Parameters=Simulink.Mask.get(block).Parameters;

        iL0=strcmp(get_param(block,'MaskNames'),'iL0')==1;
        L0=strcmp(get_param(block,'MaskNames'),'L0')==1;

        Parameters(iL0).Visible=Initialize;
        Parameters(L0).Visible=Initialize;

        phi0d=0;

    case 'Initialize'

        switch get_param(block,'Initialize')
        case 'on'
            PowerguiInfo=getPowerguiInfo(bdroot(block),block);
            switch methode
            case 1
                phi0d=(iL0*L0)/PowerguiInfo.Ts-Vl0;
            case 2
                phi0d=(iL0*L0)/PowerguiInfo.Ts-Vl0/2;
            end
        case 'off'
            switch methode
            case 1
                phi0d=-Vl0;
            case 2
                phi0d=-Vl0/2;
            end
        end

    end