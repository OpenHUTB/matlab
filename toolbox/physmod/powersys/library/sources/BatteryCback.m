function BatteryCback(block,Parameter,varargin)






    switch Parameter

    case 0




        NomV=getSPSmaskvalues(block,{'NomV'});
        MaxQ=getSPSmaskvalues(block,{'MaxQ'});
        NomQ=getSPSmaskvalues(block,{'NomQ'});
        MinV=getSPSmaskvalues(block,{'MinV'});
        FullV=getSPSmaskvalues(block,{'FullV'});
        Dis_rate=getSPSmaskvalues(block,{'Dis_rate'});
        R=getSPSmaskvalues(block,{'R'});
        Normal_OP=getSPSmaskvalues(block,{'Normal_OP'});
        expZone=getSPSmaskvalues(block,{'expZone'});

        BatteryParam(NomV,NomQ,MaxQ,MinV,FullV,Dis_rate,R,Normal_OP,expZone,block,1);

    case 1

        ME=get_param(block,'MaskEnables');
        MV=get_param(block,'MaskVisibilities');

        aMaskObj=Simulink.Mask.get(block);
        TemperatureTabControl=aMaskObj.getDialogControl('Temperature');
        TempTabControl=aMaskObj.getDialogControl('Tempcontainer');
        AgingTabControl=aMaskObj.getDialogControl('Aging');
        AgeTabControl=aMaskObj.getDialogControl('Agecontainer');

        if isempty(varargin)
            UsePresetModel=strcmp(get_param(block,'PresetModel'),'on');
        else
            UsePresetModel=varargin{1};
        end

        ME{3}='on';
        ME{4}='on';
        ME{5}='on';
        ME{6}='on';
        ME{9}='on';

        if license('test','Optimization_Toolbox')&&~isempty(ver('optim'))
            ME{19}='on';
            ME{20}='on';
            ME{21}='on';
            ME{22}='on';
            ME{23}='on';
            ME{24}='on';
            ME{25}='on';
            ME{26}='on';
            ME{27}='on';
            ME{28}='on';
        else
            ME{19}='on';
            ME{20}='off';
            ME{21}='off';
            ME{22}='off';
            ME{23}='off';
            ME{24}='off';
            ME{25}='off';
            ME{26}='off';
            ME{27}='off';
            ME{28}='off';
        end

        switch get_param(block,'BatType')

        case 'Lithium-Ion'

            TempTabControl.Visible='on';
            AgeTabControl.Visible='on';

            switch get_param(block,'ShowTempParam')
            case 'on'
                TemperatureTabControl.Visible='on';
                MV{3}='on';

                switch get_param(block,'ThermalPreset')
                case 'no'
                    ME{5}='on';
                    ME{6}='on';
                otherwise
                    ME{5}='off';
                    ME{6}='off';
                    ME{9}='off';
                    UsePresetModel=1;

                    ME{20}='off';
                    ME{21}='off';
                    ME{22}='off';
                    ME{23}='off';
                    ME{24}='off';
                    ME{25}='off';
                    ME{26}='off';
                    ME{27}='off';
                    ME{28}='off';
                end

            otherwise
                TemperatureTabControl.Visible='off';
                MV{3}='off';
            end
            switch get_param(block,'ShowAgeParam')
            case 'on'
                AgingTabControl.Visible='on';
            otherwise
                AgingTabControl.Visible='off';
            end

        otherwise
            TempTabControl.Visible='off';
            TemperatureTabControl.Visible='off';
            AgeTabControl.Visible='off';
            AgingTabControl.Visible='off';
        end

        if UsePresetModel
            ME{10}='off';
            ME{11}='off';
            ME{12}='off';
            ME{13}='off';
            ME{14}='off';
            ME{15}='off';
            ME{16}='off';
        else
            ME{9}='on';
            ME{10}='on';
            ME{11}='on';
            ME{12}='on';
            ME{13}='on';
            ME{14}='on';
            ME{15}='on';
            ME{16}='on';
        end

        set_param(block,'MaskEnables',ME);
        set_param(block,'MaskVisibilities',MV);

    case 3

        blockName=[block,'/','Ta'];
        BlkType=get_param(blockName,'BlockType');

        ShowTempParam=strcmp(get_param(block,'ShowTempParam'),'on');
        SimT=strcmp(get_param(block,'BatType'),'Lithium-Ion');

        if ShowTempParam&&SimT
            if strcmp(BlkType,'Constant')
                replace_block(blockName,'Name','Ta','Inport','noprompt');
            end
        else
            if strcmp(BlkType,'Inport')
                replace_block(blockName,'Name','Ta','Constant','noprompt');
                set_param(blockName,'Value','Batt.Ta')
            end
        end
    end