function[WantBlockChoice,Ts,sps]=PWMGeneratorMultilevelInit(block,BridgeType,NumberOfBridges,Fc,ShowCarriersOutport,Ts)








    Cr_IsOutport=strcmp('Outport',get_param([block,'/Cr'],'BlockType'));
    if ShowCarriersOutport
        if~Cr_IsOutport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Cr','BlockType','Terminator','Outport','noprompt');
            set_param([block,'/','Cr'],'Port','2')
        end
    else
        if Cr_IsOutport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Cr','BlockType','Outport','Terminator','noprompt')
        end
    end



    Erreur.identifier='SpecializedPowerSystems:PWMGeneratorBlock:ParameterError';
    BK=strrep(block,char(10),char(32));

    if Fc<=0
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The carriers frequency must be >0',BK);
        psberror(Erreur);
        return
    end

    if isnan(Fc)
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The carriers frequency must be a positive number',BK);
        psberror(Erreur);
        return
    end

    if isinf(Fc)
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The carriers frequency must have a finite value',BK);
        psberror(Erreur);
        return
    end

    if NumberOfBridges<=0
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of bridges must be >0',BK);
        psberror(Erreur);
        return
    end

    if isnan(NumberOfBridges)
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of bridges must be a positive integer number',BK);
        psberror(Erreur);
        return
    end

    if isinf(NumberOfBridges)
        Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of bridges must have a finite value',BK);
        psberror(Erreur);
        return
    end

    sps.n=round(NumberOfBridges);
    sps.Tc=1/Fc;

    switch BridgeType

    case 1

        Pc=(0:360/sps.n:360-360/sps.n)*pi/180;

        sps.Offset_Cr=Pc/(2*pi)*sps.Tc;
        p=0;

        for m=1:2:2*sps.n
            p=p+1;
            sps.SelectPulsesPS(m)=p;
            sps.SelectPulsesPS(m+1)=p+sps.n;
        end

        if Ts==0
            WantBlockChoice='Half Bridge Continuous';
        else
            WantBlockChoice='Half Bridge Discrete';
        end

    case 2

        Pc=(0:180/sps.n:180-180/sps.n)*pi/180;

        sps.Offset_Cr=Pc/(2*pi)*sps.Tc;
        p=0;

        for m=1:4:4*sps.n
            p=p+1;
            sps.SelectPulsesPS(m)=p;
            sps.SelectPulsesPS(m+1)=p+sps.n;
            sps.SelectPulsesPS(m+2)=p+2*sps.n;
            sps.SelectPulsesPS(m+3)=p+3*sps.n;
        end

        if Ts==0
            WantBlockChoice='Full Bridge Continuous';
        else
            WantBlockChoice='Full Bridge Discrete';
        end
    end







    if size(get_param(block,'Blocks'),1)==5;
        delete_block([block,'/SolverOptimization']);
    end

    if Ts==0
        add_block('built-in/Subsystem',[block,'/SolverOptimization']);
        ST1=num2str(1/Fc/2,12);
        for m=1:sps.n
            add_block('built-in/UnitDelay',[[block,'/SolverOptimization'],'/Z',num2str(m)]);
            ST2=num2str(mod(Pc(m)/(2*pi),0.5)/Fc,12);
            set_param([[block,'/SolverOptimization'],'/Z',num2str(m)],'SampleTime',['[',ST1,',',ST2,']']);
            PortHandles1=get_param([[block,'/SolverOptimization'],'/Z',num2str(m)],'PortHandles');
            add_line([block,'/SolverOptimization'],PortHandles1.Outport,PortHandles1.Inport);
        end
    end