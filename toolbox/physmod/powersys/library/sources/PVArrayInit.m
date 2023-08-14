function[k,k1,q,Tref_C,Tref_K,EgRef,dEgdT,Rsh_array5pc,VT_ref,Tsf,Tf,VIdiodePV,WantBlockChoice]=PVArrayInit(block,Nser,Npar,Ncell,Rsh,nI,Tfilter,Voc,I0)





    k=1.3806e-23;
    k1=8.617332478e-5;
    q=1.6022e-19;
    Tref_C=25;
    Tref_K=273.15+Tref_C;
    EgRef=1.121;
    dEgdT=-0.0002677;


    if Nser<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Series-connected modules per string','0'));
    end
    if Npar<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Parallel strings','0'));
    end


    Rsh_array5pc=Rsh*Nser/Npar/0.05;
    VT_ref=nI*k*Tref_K/q*Ncell;

    PVArrayLoadModule(block);
    PVArrayCback(block);

    PowerguiInfo=powericon('getPowerguiInfo',bdroot(block),block);

    if PowerguiInfo.Discrete

        if PowerguiInfo.WantDSS||strcmp(get_param(block,'RobustModel'),'on')

            WantBlockChoice{1}='Discrete DSS Diode Rsh';
            WantBlockChoice{2}='No';
            WantBlockChoice{3}='No';

            Tf=0;
            Tsf=0;

            Tcell_C=getSPSmaskvalues(block,{'RobustCellTemperature'});
            VIdiodePV=PV_VIdiode_T(Tcell_C,I0,nI,Voc,Ncell);
            VIdiodePV(:,1)=VIdiodePV(:,1)*Nser;
            VIdiodePV(:,2)=VIdiodePV(:,2)*Npar;

        else

            VIdiodePV=[];

            switch get_param(block,'BAL')
            case 'on'
                WantBlockChoice{1}='Discrete Diode Rsh BAL';
                WantBlockChoice{2}='No';
                WantBlockChoice{3}='No';
                Tf=0;
                Tsf=PowerguiInfo.Ts;

            otherwise
                WantBlockChoice{1}='Continuous Diode Rsh';
                WantBlockChoice{2}='Filter';
                WantBlockChoice{3}='Filter';
                Tf=Tfilter;
                Tsf=PowerguiInfo.Ts;

            end
        end

    else

        switch get_param(block,'BAL')
        case 'on'
            WantBlockChoice{1}='Continuous Diode Rsh BAL';
            WantBlockChoice{2}='No';
            WantBlockChoice{3}='No';

            Tf=0;
            Tsf=0;

        otherwise
            WantBlockChoice{1}='Continuous Diode Rsh';
            WantBlockChoice{2}='Filter';
            WantBlockChoice{3}='Filter';
            Tf=Tfilter;
            Tsf=0;
        end
        VIdiodePV=[];
    end
    WantBlockChoice{4}='PVArray';



    ports=get_param(block,'ports');
    HaveTemperatureInput=(ports(1)==2);

    if PowerguiInfo.WantDSS||strcmp(get_param(block,'RobustModel'),'on')

        if HaveTemperatureInput
            replace_block(block,'Followlinks','on','Name','TempC','BlockType','Inport','Constant','noprompt');
            set_param([block,'/TempC'],'Value','RobustCellTemperature');
        end
    else

        if~HaveTemperatureInput
            replace_block(block,'Followlinks','on','Name','TempC','BlockType','Constant','Inport','noprompt');
        end
    end



    function[VIdiodePV]=PV_VIdiode_T(Tcell_C,I0,nI,Voc,Ncell)














        Tref_K=25+273.15;
        Tcell_K=Tcell_C+273.15;

        k=1.3806e-23;
        k1=8.617332478e-5;
        q=1.6022e-19;
        EgRef=1.121;
        dEgdT=-0.0002677;

        VT_ref=Ncell*nI*k*Tref_K/q;

        E_g=EgRef*(1+dEgdT*(Tcell_K-Tref_K));
        VT=VT_ref*(Tcell_K/Tref_K);
        I0=I0*((Tcell_K/Tref_K)^3)*exp((EgRef/(k1*Tref_K))-(E_g/(k1*Tcell_K)));

















        Vd=[-1,0:0.1*Voc:0.6*Voc,0.7*Voc:Voc/200:Voc]';
        Id=I0*(exp(Vd/VT)-1);
        VIdiodePV=[Vd,Id];