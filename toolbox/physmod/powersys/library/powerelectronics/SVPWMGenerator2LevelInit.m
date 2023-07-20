function[WantBlockChoice,Ts,sps]=SVPWMGenerator2LevelInit(varargin)




    sps=[];

    block=varargin{1};

    if size(varargin,2)>1

        [InputType,SwitchingPattern,Fc,ParUref,Ts]=varargin{2:end};

    else

        InputType=get_param(block,'InputType');
        MV=get_param(block,'MaskVisibilities');
        switch InputType
        case{'Magnitude-Angle (rad)','alpha-beta components'}
            MV{4}='off';

        case 'Internally generated'
            MV{4}='on';
        end
        set_param(block,'MaskVisibilities',MV);
        return

    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:SVPWMGenerator2LevelBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if Fc<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The chopping frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if length(ParUref)~=3
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the ''Output voltage'' parameter must be 3',BK);
            powericon('psberror',Erreur.message,Erreur.identifier,'NoUiwait');
        end

        if ParUref(1)<0||ParUref(1)>1
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The modulation index m must be 0 <= m < =1',BK);
            psberror(Erreur);
            return
        end

        if ParUref(3)<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The frequency of the output voltage must be >=0',BK);
            psberror(Erreur);
            return
        end

        sps.InputType=InputType;
        sps.SwitchingPattern=SwitchingPattern;
        sps.Fc=Fc;
        sps.m=ParUref(1);
        sps.Pha=ParUref(2);
        sps.Freq=ParUref(3);
        if sps.Freq==0
            sps.Phase=90;
        end

    end



    InputType=get_param(block,'InputType');
    PortHandles=get_param(block,'PortHandles');
    HaveNoInports=isempty(PortHandles.Inport);
    HaveInports=~HaveNoInports;

    portStr={'port_label(''output'',1,''P'')'};
    switch InputType
    case 'Magnitude-Angle (rad)'
        portStr=[portStr;{'port_label(''input'',1,''|U|'')'}];
        portStr=[portStr;{'port_label(''input'',2,''\angleU'', ''texmode'', ''on'')'}];
        try
            set_param([block,'/Ualpha'],'Name','Umag');
            set_param([block,'/Ubeta'],'Name','Uangle');
        catch ME %#ok display a message is not necessary.
        end
        if HaveNoInports
            replace_block(block,'Followlinks','on','Name','Umag','BlockType','Constant','Inport','noprompt');
            replace_block(block,'Followlinks','on','Name','Uangle','BlockType','Constant','Inport','noprompt');
            set_param([block,'/Umag'],'SampleTime','Ts')
            set_param([block,'/Uangle'],'SampleTime','Ts')
        end
    case 'alpha-beta components'
        portStr=[portStr;{'port_label(''input'',1,''U\alpha'', ''texmode'', ''on'')'}];
        portStr=[portStr;{'port_label(''input'',2,''U\beta'', ''texmode'', ''on'')'}];
        try
            set_param([block,'/Umag'],'Name','Ualpha');
            set_param([block,'/Uangle'],'Name','Ubeta');
        catch ME %#ok  display a message is not necessary.
        end
        if HaveNoInports
            replace_block(block,'Followlinks','on','Name','Ualpha','BlockType','Constant','Inport','noprompt');
            replace_block(block,'Followlinks','on','Name','Ubeta','BlockType','Constant','Inport','noprompt');
            set_param([block,'/Ualpha'],'SampleTime','Ts')
            set_param([block,'/Ubeta'],'SampleTime','Ts')
        end
    case 'Internally generated'
        try
            replace_block(block,'Followlinks','on','Name','Umag','BlockType','Inport','Constant','noprompt');
            replace_block(block,'Followlinks','on','Name','Uangle','BlockType','Inport','Constant','noprompt');
            set_param([block,'/Umag'],'SampleTime','Ts')
            set_param([block,'/Uangle'],'SampleTime','Ts')
        catch ME %#ok  display a message is not necessary.
        end
        try
            replace_block(block,'Followlinks','on','Name','Ualpha','BlockType','Inport','Constant','noprompt');
            replace_block(block,'Followlinks','on','Name','Ubeta','BlockType','Inport','Constant','noprompt');
            set_param([block,'/Ualpha'],'SampleTime','Ts')
            set_param([block,'/Ubeta'],'SampleTime','Ts')
        catch ME %#ok  display a message is not necessary.
        end
    end
    set_param(block,'MaskDisplay',char(portStr));
