function[CCCV,WantBlockChoice,Ts]=CCCV_Param(block,DisplayPlot)






    StoppedSimulation=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));


    mValues=get_param(block,'MaskValues');
    sPreset=mValues{1};

    if StoppedSimulation
        switch sPreset
        case 'Primax P4500F-3-125-10'
            set_param(block,'P_nom','1500');
            set_param(block,'EFF_val','[0.627 0.803 0.855 0.871 0.872 0.864]');
            set_param(block,'EFF_fu','[0.063 0.177 0.293 0.483 0.674 0.914]');
            set_param(block,'s_type','3-phases AC (delta)');
            set_param(block,'n_connect','off');
            set_param(block,'eff_volt','208');
            set_param(block,'in_freq','60');
            set_param(block,'I_THD_val','[0.327 0.394 0.394 0.351 0.289 0.265]');
            set_param(block,'I_THD_fu','[0.056 0.136 0.194 0.303 0.555 0.916]');
            set_param(block,'H_DIST_rt','[0.199 1.297 0.328 0.029 0.416 0.200]');
            set_param(block,'H_DIST_fr','[3 5 7 9 11 13]');
            set_param(block,'PF_val','[0.316 0.532 0.662 0.731 0.780 0.792]');
            set_param(block,'PF_fu','[0.067 0.230 0.445 0.625 0.794 0.919]');
            set_param(block,'Out_mode','Constant Current - Constant Voltage (CCCV)');
            set_param(block,'DynInT','off');
            set_param(block,'I_cst','10');
            set_param(block,'V_cst','138');
            set_param(block,'ABS_en','off');
            set_param(block,'ripple','0.05');
            set_param(block,'swF','1000');
            set_param(block,'overshoot','0');
            set_param(block,'stable_t','5');
            set_param(block,'VoltComp','off');
            set_param(block,'V_comp','0');
            set_param(block,'nom_temp','20');
            mValues=get_param(block,'MaskValues');
        case 'Transtronic 020-0085-00'
            set_param(block,'P_nom','1554');
            set_param(block,'EFF_val','[0.530 0.922 0.848 0.896 0.911 0.902]');
            set_param(block,'EFF_fu','[0.027 0.059 0.130 0.297 0.642 0.991]');
            set_param(block,'s_type','1-phase AC');
            set_param(block,'n_connect','off');
            set_param(block,'eff_volt','240');
            set_param(block,'in_freq','60');
            set_param(block,'I_THD_val','[0.496 0.305 0.173 0.103 0.061 0.065]');
            set_param(block,'I_THD_fu','[0.031 0.104 0.241 0.401 0.599 0.994]');
            set_param(block,'H_DIST_rt','[0.108 0.215 0.132 0.123 0.163 0.167]');
            set_param(block,'H_DIST_fr','[3 5 7 9 11 13]');
            set_param(block,'PF_val','[0.841 0.933 0.966 0.974 0.963 0.990]');
            set_param(block,'PF_fu','[0.029 0.111 0.184 0.316 0.575 0.994]');
            set_param(block,'Out_mode','Constant Current - Constant Voltage (CCCV)');
            set_param(block,'DynInT','off');
            set_param(block,'I_cst','21');
            set_param(block,'V_cst','74');
            set_param(block,'ABS_en','off');
            set_param(block,'ripple','0.01');
            set_param(block,'swF','1000');
            set_param(block,'overshoot','0');
            set_param(block,'stable_t','1.5');
            set_param(block,'VoltComp','off');
            set_param(block,'V_comp','0');
            set_param(block,'nom_temp','20');
            mValues=get_param(block,'MaskValues');
        end
    end

    vP_nom=str2double(mValues{2});
    sS_type=mValues{3};
    vEff_volt=str2double(mValues{5});
    vIn_freq=str2double(mValues{6});
    vIn_i_ripple=str2double(mValues{7});
    vIn_i_freq=str2double(mValues{8});
    bEff_en=strcmp(mValues{9},'on');
    vEff_val=str2num(mValues{10});%#ok<ST2NM>
    vEff_fu=str2num(mValues{11});%#ok<ST2NM>
    bThd_en=strcmp(mValues{12},'on');
    vI_thd_val=str2num(mValues{13});%#ok<ST2NM>
    vI_thd_fu=str2num(mValues{14});%#ok<ST2NM>
    vH_dist_rt=str2num(mValues{15});%#ok<ST2NM>
    vH_dist_fr=str2num(mValues{16});%#ok<ST2NM>
    bPf_en=strcmp(mValues{17},'on');
    vPf_val=str2num(mValues{18});%#ok<ST2NM>
    vPf_fu=str2num(mValues{19});%#ok<ST2NM>
    sOut_mode=mValues{20};
    bDynint=strcmp(mValues{21},'on');
    vI_cst=str2double(mValues{22});
    vV_cst=str2double(mValues{23});
    bAbs_en=strcmp(mValues{24},'on');
    vV_abs=str2double(mValues{25});
    sAbs_end=mValues{26};
    vAbs_time=str2double(mValues{27});
    vAbs_i=str2double(mValues{28});
    vRipple=str2double(mValues{29});
    vSwf=str2double(mValues{30});
    vOvershoot=str2double(mValues{31});
    vStable_t=str2double(mValues{32});




    if vP_nom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nomimal Power','0'));
    end


    if vEff_volt<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Effective voltage','0'));
    end


    bcond=strcmp(sOut_mode,'Constant Current - Constant Voltage (CCCV)');
    vdc=vV_cst;
    if~bDynint&&bcond
        if bAbs_en
            vdc=vV_abs;
            if vV_abs<vV_cst
                error(message('physmod:powersys:common:GreaterThan',block,'Absorption voltage','Float Voltage'));
            end
            bcond=strcmp(sAbs_end,'Time based');
            if bcond&&vAbs_time<=0
                error(message('physmod:powersys:common:GreaterThan',block,'Absorption time','0'));
            else
                if vAbs_i<0
                    error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Absorption current','0'));
                elseif vAbs_i>100
                    error(message('physmod:powersys:common:LesserThanOrEqualTo',block,'Absorption current','100'));
                end
            end
        end
    end


    bcond=strcmp(sOut_mode,'Constant Current - Constant Voltage (CCCV)');
    if~bDynint&&bcond&&vdc*vI_cst>vP_nom
        error(['Nominal Power must be greater than the maximum power '...
        ,'output obtained from Bulk current, Float voltage or '...
        ,'Absorption voltage.']);
    end


    cond=strcmp(sS_type,'DC');
    if cond
        if vIn_i_ripple<0
            error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Input DC current ripple','0'));
        elseif vIn_i_ripple>=100
            error(message('physmod:powersys:common:LesserThan',block,'Input DC current ripple','100'));
        end
        if vIn_i_freq<=0
            error(message('physmod:powersys:common:GreaterThan',block,'Input DC ripple frequency','0'));
        end
    end


    if~cond

        if vIn_freq<=0
            error(message('physmod:powersys:common:GreaterThan',block,'Input frequency','0'));
        end


        if bThd_en
            if~(length(vI_thd_val)==length(vI_thd_fu))
                error('THD parameters must be of equal length.');
            end
            if~all(vI_thd_val>=0&vI_thd_val<=1)||~all(vI_thd_fu>=0&vI_thd_fu<=1)
                error('THD parameters must be contained between 0 and 1.');
            end
            if~(length(vI_thd_fu)==length(unique(vI_thd_fu)))
                error('THD parameters must be unique.');
            end
            if~(length(vH_dist_rt)==length(vH_dist_fr))
                error('Harmonics parameters must be of equal length.');
            end
            if~all(vH_dist_rt>0)
                error(message('physmod:powersys:common:GreaterThan',block,'Harmonics amplitude','0'));
            end
            if~all(vH_dist_fr>1)||~(sum(mod(vH_dist_fr,1))==0)||sum(mod(vH_dist_fr,2)==0)
                error('Harmonics frequencies must be odd integers greater than 1.');
            end
            if~sum(mod(vH_dist_fr,3)>0)&&strcmp(sS_type,'3-phases AC (delta)')
                error(['For a 3-phases AC (delta) configuration, at least one of '...
                ,'the Harmonics frequency must not be a multiple of 3.']);
            end
            if~(length(vH_dist_fr)==length(unique(vH_dist_fr)))
                error('Harmonics frequencies must be unique.');
            end
        end


        if bPf_en
            if~(length(vPf_val)==length(vPf_fu))
                error('Power factor parameters must be of equal length.');
            end
            if~all(vPf_val>=0&vPf_val<=1)||~all(vPf_fu>=0&vPf_fu<=1)
                error('Power factor parameters must be contained between 0 and 1.');
            end
            if~(length(vPf_fu)==length(unique(vPf_fu)))
                error('Power factor parameters must be unique.');
            end
        end
    end


    if bEff_en
        if~(length(vEff_val)==length(vEff_fu))
            error('Efficiency parameters must be of equal length.');
        end
        if~all(vEff_val>=0&vEff_val<=1)||~all(vEff_fu>=0&vEff_fu<=1)
            error('Efficiency parameters must be contained between 0 and 1.');
        end
        if~(length(vEff_fu)==length(unique(vEff_fu)))
            error('Efficiency parameters must be unique.');
        end
    end


    if vRipple<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Output current ripple','0'));
    elseif vRipple>=100
        error(message('physmod:powersys:common:LesserThan',block,'Settling time','100'));
    end


    if vOvershoot<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Overshoot','0'));
    end


    if vStable_t<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Settling time','0'));
    end


    if vSwf<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Output ripple frequency','0'));
    end


    CCCV.kdi=0;
    CCCV.kii=0;
    CCCV.kpi=0;
    CCCV.kdv=0;
    CCCV.kiv=0;
    CCCV.kpv=0;

    CCCV.ac.c_I_THD=0;
    CCCV.ac.c_EFF=0;
    CCCV.ac.c_PF=0;
    CCCV.ac.c_HARMS.a=0;
    CCCV.ac.c_HARMS.f=0;



    if vOvershoot==0
        d=2e-2;
    else
        d=vOvershoot/100;
    end

    l=-log(d)/sqrt(pi^2+(log(d))^2);
    if l<0
        l=1e-3;
    elseif l>0.9
        l=0.9;
    end
    wn=-log(0.02)/(vStable_t*l);

    CCCV.kdi=1;
    CCCV.kii=wn^2;
    CCCV.kpi=2*l*wn;



    CCCV.I.Numerator{1}=CCCV.kii;
    CCCV.I.Denominator{1}=[CCCV.kdi,CCCV.kpi,CCCV.kii];


    vStable_t=1;

    if vOvershoot==0
        d=2e-2;
    else
        d=vOvershoot/100;
    end

    l=-log(d)/sqrt(pi^2+(log(d))^2);
    if l<0
        l=2e-2;
    elseif l>0.9
        l=0.9;
    end
    wn=-log(0.001)/(vStable_t*l);

    CCCV.kdv=1;
    CCCV.kiv=wn^2;
    CCCV.kpv=2*l*wn;




    CCCV.V.Numerator{1}=[CCCV.kiv,CCCV.kiv*CCCV.kpi,CCCV.kiv*CCCV.kii];
    CCCV.V.Denominator{1}=[CCCV.kii,CCCV.kii*CCCV.kpv,CCCV.kiv*CCCV.kii];



    warning off MATLAB:polyfit:PolyNotUnique;


    if bEff_en
        if length(vEff_fu)==1
            vEff_fu=0;
        end

        vEff_val(vEff_val==0)=1e-3;
        vEff_val(vEff_val==1)=1-1e-3;

        mx=min(vEff_fu);
        if mx~=0
            vEff_val=[vEff_val(vEff_fu==mx),vEff_val];
            vEff_fu=[0,vEff_fu];
        end

        Mx=max(vEff_fu);
        if Mx~=1
            vEff_val=[vEff_val,vEff_val(vEff_fu==Mx)];
            vEff_fu=[vEff_fu,1];
        end

        bPoly=0;
        while bPoly<=0
            order=round((length(vEff_fu)/2)+bPoly);
            CCCV.ac.c_EFF=polyfit(vEff_fu,vEff_val,order);
            val=linspace(0,1,1001);
            valPoly=polyval(CCCV.ac.c_EFF,val);
            if min(valPoly)>0&&max(valPoly)<1
                bPoly=1;
            elseif order==0
                warning([block,' could not find '...
                ,'a function matching the user inputs for Efficiency '...
                ,'parameters. Model will run without this parameter.']);
                CCCV.ac.c_THD=0;
                bPoly=1;
            else
                bPoly=bPoly-1;
            end
        end

        CCCV.ac.s_EFF='';
        lCCCV=length(CCCV.ac.c_EFF);
        for i=1:lCCCV
            if i==1
                sAdd='';
            else
                sAdd='+';
            end
            CCCV.ac.s_EFF=[CCCV.ac.s_EFF,sAdd,'CCCV.ac.c_EFF(',num2str(i),')*u^',num2str(lCCCV-i)];
        end
    else
        CCCV.ac.s_EFF='1';
    end

    cond=strcmp(sS_type,'DC');
    if~cond

        if bThd_en
            if length(vI_thd_fu)==1
                vI_thd_fu=0;
            end

            vI_thd_val(vI_thd_val==0)=1e-3;
            vI_thd_val(vI_thd_val==1)=1-1e-3;

            mx=min(vI_thd_fu);
            if mx~=0
                vI_thd_val=[vI_thd_val(vI_thd_fu==mx),vI_thd_val];
                vI_thd_fu=[0,vI_thd_fu];
            end

            Mx=max(vI_thd_fu);
            if Mx~=1
                vI_thd_val=[vI_thd_val,vI_thd_val(vI_thd_fu==Mx)];
                vI_thd_fu=[vI_thd_fu,1];
            end

            bPoly=0;
            while bPoly<=0
                order=round((length(vI_thd_fu)/2)+bPoly);
                CCCV.ac.c_THD=polyfit(vI_thd_fu,vI_thd_val,order);
                val=linspace(0,1,1001);
                valPoly=polyval(CCCV.ac.c_THD,val);
                if min(valPoly)>0&&max(valPoly)<1
                    bPoly=1;
                elseif order==0
                    warning([block,' could not find '...
                    ,'a function matching the user inputs for Total '...
                    ,'harmonic distortion parameters. Model will run '...
                    ,'without this parameter.']);
                    CCCV.ac.c_THD=0;
                    bPoly=1;
                else
                    bPoly=bPoly-1;
                end
            end

            CCCV.ac.s_THD='';
            lCCCV=length(CCCV.ac.c_THD);
            for i=1:lCCCV
                if i==1
                    sAdd='';
                else
                    sAdd='+';
                end
                CCCV.ac.s_THD=[CCCV.ac.s_THD,sAdd,'CCCV.ac.c_THD(',num2str(i),')*u^',num2str(lCCCV-i)];
            end


            cond=strcmp(sS_type,'3-phases AC (delta)');
            if cond
                vH_dist_rt=vH_dist_rt.*(~mod(vH_dist_fr,3)==0);
            end
            CCCV.ac.c_HARMS.a=vH_dist_rt/sqrt(sum(vH_dist_rt.^2));
            CCCV.ac.c_HARMS.f=2*pi*vIn_freq*vH_dist_fr;
        else
            CCCV.ac.s_THD='0';
        end


        if bPf_en
            if length(vPf_fu)==1
                vPf_fu=0;
            end

            vPf_val(vPf_val==0)=1e-3;
            vPf_val(vPf_val==1)=1-1e-3;

            mx=min(vPf_fu);
            if mx~=0
                vPf_val=[vPf_val(vPf_fu==mx),vPf_val];
                vPf_fu=[0,vPf_fu];
            end

            Mx=max(vPf_fu);
            if Mx~=1
                vPf_val=[vPf_val,vPf_val(vPf_fu==Mx)];
                vPf_fu=[vPf_fu,1];
            end

            bPoly=0;
            while bPoly<=0
                order=round((length(vPf_fu)/2)+bPoly);
                CCCV.ac.c_PF=polyfit(vPf_fu,vPf_val,order);
                val=linspace(0,1,1001);
                valPoly=polyval(CCCV.ac.c_PF,val);
                if min(valPoly)>0&&max(valPoly)<1
                    bPoly=1;
                elseif order==0
                    warning([block,' charger could not find '...
                    ,'a function matching the user inputs for Power '...
                    ,'factor parameters. Model will run without this '...
                    ,'parameter.']);
                    CCCV.ac.c_PF=1;
                    bPoly=1;
                else
                    bPoly=bPoly-1;
                end
            end

            CCCV.ac.s_PF='';
            lCCCV=length(CCCV.ac.c_PF);
            for i=1:lCCCV
                if i==1
                    sAdd='';
                else
                    sAdd='+';
                end
                CCCV.ac.s_PF=[CCCV.ac.s_PF,sAdd,'CCCV.ac.c_PF(',num2str(i),')*u^',num2str(lCCCV-i)];
            end
        else
            CCCV.ac.s_PF='1';
        end
    else
        CCCV.ac.s_THD='0';
        CCCV.ac.s_PF='1';
    end

    warning on MATLAB:polyfit:PolyNotUnique;


    if DisplayPlot==1

        hfig=findobj('Name','Battery Charger Simulation Options Curves');

        if isempty(hfig)
            figure('Name','Battery Charger Simulation Options Curves');
        else
            figure(hfig);
            subplot(1,1,1);
            children=get(gca,'children');
            delete(children(:));
            subplot(2,1,1);
            children=get(gca,'children');
            delete(children(:));
            subplot(2,1,2);
            children=get(gca,'children');
            delete(children(:));
        end

        if~strcmp(sS_type,'DC')&&bThd_en
            subplot(2,1,2);

            for i=1:length(CCCV.ac.c_HARMS.f)
                x=[CCCV.ac.c_HARMS.f(i),CCCV.ac.c_HARMS.f(i)]/(2*pi);
                y=[0,CCCV.ac.c_HARMS.a(i)];
                plot(x,y,'k');
                hold on;
            end
            title('Battery Charger Input Current harmonics');
            axis([0,max(CCCV.ac.c_HARMS.f)/(2*pi)+vIn_freq,0,1]);
            xlabel('Frequency (Hz)');
            ylabel('Normalised current (A)');
            grid on;
            set(gca,'xminorgrid','on','yminorgrid','on');
            subplot(2,1,1);
        else
            subplot(1,1,1);
        end
        leg={};
        x=linspace(0,1,222);

        if bEff_en
            yEff=polyval(CCCV.ac.c_EFF,x);
            plot(str2num(mValues{11}),str2num(mValues{10}),'o','color',[0,0.447,0.741]);%#ok<ST2NM>
            leg{length(leg)+1}='Spec. Efficiency';
            hold on;
        else
            yEff=ones(size(x));
        end
        if~strcmp(sS_type,'DC')&&bThd_en
            yThd=polyval(CCCV.ac.c_THD,x);
            plot(str2num(mValues{14}),str2num(mValues{13}),'o','color',[0.85,0.325,0.098]);%#ok<ST2NM>
            leg{length(leg)+1}='Spec. THD';
            hold on;
        else
            yThd=zeros(size(x));
        end
        if~strcmp(sS_type,'DC')&&bPf_en
            yPf=polyval(CCCV.ac.c_PF,x);
            plot(str2num(mValues{19}),str2num(mValues{18}),'o','color',[0.929,0.694,0.125]);%#ok<ST2NM>
            leg{length(leg)+1}='Spec. PF';
            hold on;
        else
            yPf=ones(size(x));
        end

        plot(x(1:3:end),yEff(1:3:end),'.','color',[0,0.447,0.741]);
        leg{length(leg)+1}='Sim. Efficiency';
        hold on;
        if~strcmp(sS_type,'DC')
            plot(x(2:3:end),yThd(2:3:end),'.','color',[0.85,0.325,0.098]);
            leg{length(leg)+1}='Sim. THD';
            plot(x(3:3:end),yPf(3:3:end),'.','color',[0.929,0.694,0.125]);
            leg{length(leg)+1}='Sim. PF';
        end
        title('Battery Charger Input Parameters Curves');
        legend(leg,'Location','east');
        axis([0,1,-0.001,1.01]);
        xlabel('Usage factor (pu)');
        ylabel('Factor unit (0-1)');
        grid on;
        set(gca,'xminorgrid','on','yminorgrid','on');
    end


    if DisplayPlot==2

        hfig=findobj('Name','Battery Charger Charging Cycles');

        if isempty(hfig)
            figure('Name','Battery Charger Charging Cycles');
        else
            figure(hfig);
            subplot(2,1,1);
            children=get(gca,'children');
            delete(children(:));
            subplot(2,1,2);
            children=get(gca,'children');
            delete(children(:));
        end

        iC=zeros(1,60);
        vC=zeros(1,60);
        if bDynint
            tl=1;
            switch sOut_mode
            case 'Constant Current - Constant Voltage (CCCV)'
                iC(1:20)=linspace(1,1,20);
                iC(20:60)=linspace(1,0,41);
                vC(1:20)=linspace(0,1,20);
                vC(20:60)=linspace(1,1,41);
                ytl1={"","","CC"};
                ytl2={"","","CV"};
            case 'Constant Current only (CC)'
                iC(1:60)=linspace(1,1,60);
                vC(1:60)=linspace(0,1,60);
                ytl1={"","","CC"};
                ytl2={};
            case 'Constant Voltage only (CV)'
                iC(1:60)=linspace(1,0,60);
                vC(1:60)=linspace(1,1,60);
                ytl1={};
                ytl2={"","","CV"};
            end
        else
            tl=0;
            switch sOut_mode
            case 'Constant Current - Constant Voltage (CCCV)'
                if bAbs_en
                    iC(1:20)=linspace(vI_cst,vI_cst,20);
                    vC(1:20)=linspace(0,vV_abs,20);
                    switch sAbs_end
                    case 'Time based'
                        iC(20:40)=linspace(vI_cst,vI_cst/5,21);
                        iC(40:60)=linspace(vI_cst/5,0,21);
                        vC(20:40)=linspace(vV_abs,vV_abs,21);
                        vC(40:60)=linspace(vV_cst,vV_cst,21);
                        yt1=vI_cst;
                        if abs(vV_abs/vV_cst-1)>=0.2
                            yt2=[vV_cst,vV_abs];
                        else
                            yt2=vV_cst;
                        end
                    case 'Current based'
                        iC(20:40)=linspace(vI_cst,vI_cst*vAbs_i/100,21);
                        iC(40:60)=linspace(vI_cst*vAbs_i/100,0,21);
                        vC(20:40)=linspace(vV_abs,vV_abs,21);
                        vC(40:60)=linspace(vV_cst,vV_cst,21);
                        if abs(vI_cst/vI_cst*vAbs_i/100-1)>=0.2
                            yt1=[vI_cst*vAbs_i/100,vI_cst];
                        else
                            yt1=vI_cst;
                        end
                        if abs(vV_abs/vV_cst-1)>=0.2
                            yt2=[vV_cst,vV_abs];
                        else
                            yt2=vV_cst;
                        end
                    end
                else
                    iC(1:20)=linspace(vI_cst,vI_cst,20);
                    iC(20:60)=linspace(vI_cst,0,41);
                    vC(1:20)=linspace(0,vV_cst,20);
                    vC(20:60)=linspace(vV_cst,vV_cst,41);
                    yt1=vI_cst;
                    yt2=vV_cst;
                end
            case 'Constant Current only (CC)'
                iC=linspace(vI_cst,vI_cst,60);
                vC=linspace(0,1,60);
                yt1=vI_cst;
                yt2='';
            case 'Constant Voltage only (CV)'
                iC=linspace(1,0,60);
                vC=linspace(vV_cst,vV_cst,60);
                yt1='';
                yt2=vV_cst;
            end
        end

        subplot(2,1,1);
        plot(0:59,iC,'k');
        title('Charger Current');
        xlim([0,59]);
        ylim([0,1.25*max(iC)]);
        xlabel('SOC');
        ylabel('Amperes');

        grid on;
        set(gca,'xminorgrid','on','yminorgrid','on');
        if tl==0

        else

        end

        hold on;
        subplot(2,1,2);
        plot(0:59,vC,'k');
        title('Charger Voltage');
        xlim([0,59]);
        ylim([0,1.25*max(vC)]);
        xlabel('SOC');
        ylabel('Volts');

        grid on;
        set(gca,'xminorgrid','on','yminorgrid','on');
        if tl==0

        else

        end
    end


    sys=bdroot(block);
    PowerguiInfo=powericon('getPowerguiInfo',sys,block);
    Ts=PowerguiInfo.Ts;
    WantDiscreteModel=PowerguiInfo.Discrete;
    if WantDiscreteModel
        WantBlockChoice='Discrete';



        a=0;
        b=0;
        c=CCCV.I.Numerator{1}(1);
        d=CCCV.I.Denominator{1}(1);
        e=CCCV.I.Denominator{1}(2);
        f=CCCV.I.Denominator{1}(3);
        p1=a*(4/Ts^2)+b*(2/Ts)+c;
        p2=2*c-a*(8/Ts^2);
        p3=a*(4/Ts^2)+c-b*(2/Ts);
        p4=d*(4/Ts^2)+e*(2/Ts)+f;
        p5=2*f-d*(8/Ts^2);
        p6=d*(4/Ts^2)+f-e*(2/Ts);

        CCCV.I.Numerator{1}=[p1/p4,p2/p4,p3/p4];
        CCCV.I.Denominator{1}=[p4/p4,p5/p4,p6/p4];


        a=CCCV.V.Numerator{1}(1);
        b=CCCV.V.Numerator{1}(2);
        c=CCCV.V.Numerator{1}(3);
        d=CCCV.V.Denominator{1}(1);
        e=CCCV.V.Denominator{1}(2);
        f=CCCV.V.Denominator{1}(3);

        p1=a*(4/Ts^2)+b*(2/Ts)+c;
        p2=2*c-a*(8/Ts^2);
        p3=a*(4/Ts^2)+c-b*(2/Ts);
        p4=d*(4/Ts^2)+e*(2/Ts)+f;
        p5=2*f-d*(8/Ts^2);
        p6=d*(4/Ts^2)+f-e*(2/Ts);

        CCCV.V.Numerator{1}=[p1/p4,p2/p4,p3/p4];
        CCCV.V.Denominator{1}=[p4/p4,p5/p4,p6/p4];

    else
        WantBlockChoice='Continuous';
    end
    CCCV.Ts=Ts;
    CCCV.WantDiscreteModel=WantDiscreteModel;
end