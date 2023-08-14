function[WantBlockChoice,Ts,sps]=PulseGeneratorThyristorInit(varargin)




    sps=[];

    block=varargin{1};
    GenType=get_param(block,'GenType');

    if size(varargin,2)>1

        [Delta,pwidth,Double_Pulse,Ts]=varargin{2:end};

    else

        MV=get_param(block,'MaskVisibilities');
        switch GenType
        case '6-pulse'
            MV{2}='off';
        case '12-pulse'
            MV{2}='on';
        end
        set_param(block,'MaskVisibilities',MV);
        return

    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        if pwidth<0||pwidth>180
            BK=strrep(block,char(10),char(32));
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The pulse width be  >=0 and <= 180 degrees',BK);
            Erreur.identifier='SpecializedPowerSystems:PulseGeneratorThyristorBlock:ParameterError';
            psberror(Erreur);
            return
        end





        if Delta==1
            sps.D1=1;
        else
            sps.D1=0;
        end
        sps.pwidth=pwidth;
        sps.Double_Pulse=Double_Pulse;

        switch GenType
        case '6-pulse'
            sps.rampOffset=(1:-1/6:1/6)*2*pi-pi/6;
            sps.signalSize=6;
        case '12-pulse'
            sps.rampOffset=[(1:-1/6:1/6),(13/12:-1/6:3/12)-sps.D1*1/6]*2*pi-pi/6;
            sps.signalSize=12;
        end
    end



    ports=get_param(block,'ports');
    NbOut=ports(2);
    switch GenType
    case '6-pulse'
        if NbOut==2
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','PD','BlockType','Outport','Terminator','noprompt');
            set_param([block,'/PY'],'Name','P');
        end

    case '12-pulse'
        if NbOut==1
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','PD','BlockType','Terminator','Outport','noprompt');
            set_param([block,'/PD'],'SampleTime','Ts')
            set_param([block,'/P'],'Name','PY');
        end
    end