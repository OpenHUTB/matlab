function PVArrayPlot(Block,Option)








    Ncell=str2num(get_param(Block,'Ncell'));%#ok<*ST2NM>
    Voc=str2num(get_param(Block,'Voc'));
    Isc=str2num(get_param(Block,'Isc'));
    Vm=str2num(get_param(Block,'Vm'));
    Im=str2num(get_param(Block,'Im'));
    alpha_Isc=str2num(get_param(Block,'alpha_Isc'));
    beta_Voc=str2num(get_param(Block,'beta_Voc'));

    IL=str2num(get_param(Block,'IL'));
    I0=str2num(get_param(Block,'I0'));
    nI=str2num(get_param(Block,'nI'));
    Rsh=str2num(get_param(Block,'Rsh'));
    Rs=str2num(get_param(Block,'Rs'));

    ModuleName=get_param(Block,'ModuleName');

    switch Option

    case 'detailed'

        PlotType=get_param(Block,'PlotType');
        Nser=str2num(get_param(Block,'Nser'));
        Npar=str2num(get_param(Block,'Npar'));
        S_vec=str2num(get_param(Block,'S_vec'));
        Temp_C_vec=str2num(get_param(Block,'Temp_C_vec'));

        if any(S_vec<0)
            error(message('physmod:powersys:common:GreaterThan',Block,'Irradiances (W/m2)','0'));
        end

        if any(Temp_C_vec<0)
            error(message('physmod:powersys:common:GreaterThan',Block,'T_cell (deg. C)','0'));
        end



        hfig=findobj('Name',PlotType);
        if isempty(hfig)
            hfig=figure;
            set(hfig,'Name',PlotType,'Units','normalized','OuterPosition',[0.4,0.5,0.3,0.5]);
        end

        figure(hfig);
        Tref_C=25;
        clf(hfig);

        switch PlotType
        case{'one module @ 25 deg.C & specified irradiances','array @ 25 deg.C & specified irradiances'}

            ksun=0;

            for S=S_vec
                S_pu=S/1000;
                ksun=ksun+1;
                [V_PV,I_PV]=PVArrayParam(S,Tref_C,IL,I0,nI,Rs,Rsh,Voc,Vm,Im,alpha_Isc,beta_Voc,Ncell);
                P_PV=V_PV.*I_PV;



                switch PlotType

                case 'one module @ 25 deg.C & specified irradiances'

                    subplot(211)

                    if S_pu==1
                        h=plot(V_PV,I_PV,'r',[0,Vm,Voc],[Isc,Im,0],'ro');
                        set(h,'LineWidth',2.0);
                        h=text(Voc/15,Isc*1.1,'1 kW/m^2');
                        set(h,'Color',[1,0,0]);
                    else
                        plot(V_PV,I_PV,'-b')
                        text(Voc/15,Isc*(S_pu+0.1),sprintf('%g kW/m^2',S_pu))
                    end
                    if ksun==1,hold on;end

                    subplot(212)

                    if S_pu==1
                        plot(V_PV,P_PV,'r',[0,Vm,Voc],[0,Im*Vm,0],'ro');
                        set(h,'LineWidth',2.0);
                        h=text(Vm*1.02,Vm*Im,'1 kW/m^2');
                        set(h,'Color',[1,0,0]);
                    else
                        n=find(P_PV==max(P_PV));
                        plot(V_PV,P_PV,'-b',V_PV(n),P_PV(n),'mo')
                        text(Vm*1.02,Vm*Im*S_pu,sprintf('%g kW/m^2',S_pu))
                    end

                    if ksun==1,hold on;end

                    subplot(211)

                    ylabel('Current (A)')
                    xlabel('Voltage (V)')
                    h=title(sprintf('Module type: %s',ModuleName));
                    set(h,'Interpreter','none');

                    subplot(212)

                    ylabel('Power (W)')
                    xlabel('Voltage (V)')

                case 'array @ 25 deg.C & specified irradiances'

                    subplot(211)

                    if S_pu==1
                        h=plot(V_PV*Nser,I_PV*Npar,'r',[0,Vm,Voc]*Nser,[Isc,Im,0]*Npar,'ro');
                        set(h,'LineWidth',2.0);
                        h=text(Voc/15*Nser,Isc*1.05*Npar,'1 kW/m^2');
                        set(h,'Color',[1,0,0]);
                    else
                        plot(V_PV*Nser,I_PV*Npar,'-b')
                        text(Voc*Nser/15,Isc*Npar*(S_pu+0.05),sprintf('%g kW/m^2',S_pu))
                    end
                    if ksun==1,hold on;end

                    subplot(212)

                    if S_pu==1
                        h=plot(V_PV*Nser,P_PV*Nser*Npar,'r',[0,Vm,Voc]*Nser,[0,Im*Vm,0]*Nser*Npar,'ro');
                        set(h,'LineWidth',2.0);
                        h=text(Vm*Nser*1.02,Vm*Im*Nser*Npar,'1 kW/m^2');
                        set(h,'Color',[1,0,0]);
                    else
                        n=find(P_PV==max(P_PV));
                        plot(V_PV*Nser,P_PV*Nser*Npar,'-b',V_PV(n)*Nser,P_PV(n)*Nser*Npar,'mo')
                        text(Vm*Nser*1.02,Vm*Im*Nser*Npar*S_pu,sprintf('%g kW/m^2',S_pu))
                    end
                    if ksun==1,hold on;end

                    subplot(211)
                    ylabel('Current (A)')
                    xlabel('Voltage (V)')
                    h=title(sprintf('Array type: %s;\n%d series modules; %d parallel strings',ModuleName,Nser,Npar));
                    set(h,'Interpreter','none');
                    axis_xy=axis;
                    axis_xy(4)=Isc*Npar*1.2;

                    subplot(212)
                    ylabel('Power (W)')
                    xlabel('Voltage (V)')

                end
            end


            P211=subplot(211);
            YLim=P211.YLim;
            P211.YLim=[YLim(1),YLim(2)*1.1];

            P212=subplot(212);
            YLim=P212.YLim;
            P212.YLim=[YLim(1),YLim(2)*1.1];


        case 'array @ 1000 W/m2 & specified temperatures'



            for ktemp=1:length(Temp_C_vec)
                Tcell_C=Temp_C_vec(ktemp);
                Voc_T=Voc+beta_Voc*(Tcell_C-Tref_C);
                Isc_T=Isc+alpha_Isc*(Tcell_C-Tref_C);

                [V_PV,I_PV]=PVArrayParam(1000,Tcell_C,IL,I0,nI,Rs,Rsh,Voc,Vm,Im,alpha_Isc,beta_Voc,Ncell);
                P_PV=V_PV.*I_PV;

                subplot(211)
                if Tcell_C==25
                    h=plot(V_PV*Nser,I_PV*Npar,'r',[0,Vm,Voc]*Nser,[Isc,Im,0]*Npar,'ro');
                    set(h,'LineWidth',2.0);
                    h=text(Voc*Nser*0.95,Isc*Npar/10*(1+ktemp),sprintf('%g ^oC',Tcell_C));
                    set(h,'Color',[1,0,0]);
                else
                    n=find(P_PV==max(P_PV));
                    plot(V_PV*Nser,I_PV*Npar,'-b',[0,V_PV(n),Voc_T]*Nser,[Isc_T,I_PV(n),0]*Npar,'ro')
                    text(Voc_T*Nser*0.95,Isc*Npar/10*(1+ktemp),sprintf('%g ^oC',Tcell_C));
                end
                if ktemp==1,hold on;end

                subplot(212)
                if Tcell_C==25
                    h=plot(V_PV*Nser,P_PV*Nser*Npar,'r',[0,Vm,Voc]*Nser,[0,Im*Vm,0]*Nser*Npar,'ro');
                    set(h,'LineWidth',2.0);
                    h=text(Vm*Nser,0.9*Vm*Im*Nser*Npar,sprintf('%g ^oC',Tcell_C));
                    set(h,'Color',[1,0,0]);
                else
                    Vm_T=V_PV(n);
                    plot(V_PV*Nser,P_PV*Nser*Npar,'-b',V_PV(n)*Nser,P_PV(n)*Nser*Npar,'mo',Voc_T*Nser,0,'ro')
                    text(Vm_T*Nser,0.9*Vm_T*Im*Nser*Npar,sprintf('%g ^oC',Tcell_C));
                end
                if ktemp==1,hold on;end
            end

            subplot(211)
            ylabel('Current (A)')
            xlabel('Voltage (V)')
            h=title(sprintf('Array type: %s;\n%d series modules; %d parallel strings',ModuleName,Nser,Npar));
            set(h,'Interpreter','none');
            subplot(212)
            ylabel('Power (W)')
            xlabel('Voltage (V)')

        end

    case 'OneModule'






        switch get_param(bdroot(Block),'SimulationStatus')
        case 'initializing'
            return
        end

        hfig=findobj('Name','Module I-V & P-V characteristics');
        if isempty(hfig)
            hfig=figure;
            set(hfig,'Name','Module I-V & P-V characteristics','Units','normalized','OuterPosition',[0.7,0.5,0.3,0.5]);
        end

        figure(hfig);

        Sref=1000;
        Tref_C=25;
        [V_PV,I_PV]=PVArrayParam(Sref,Tref_C,IL,I0,nI,Rs,Rsh,Voc,Vm,Im,alpha_Isc,beta_Voc,Ncell);


        subplot(211)
        h=plot(V_PV,I_PV,'b',[0,Vm,Voc],[Isc,Im,0],'ro');
        set(h,'LineWidth',2.0);
        ylabel('Current (A)')
        xlabel('Voltage (V)')
        h=title(ModuleName);
        set(h,'Interpreter','none');
        Isc_Obtained=I_PV(1);
        Voc_Obtained=V_PV(end);
        P_PV=V_PV.*I_PV;
        n=find(P_PV==max(P_PV));
        Vm_Obtained=V_PV(n);
        Im_Obtained=I_PV(n);

        Error_Voc=(Voc_Obtained-Voc)/Voc;
        Error_Isc=(Isc_Obtained-Isc)/Isc;
        Error_Vm=(Vm_Obtained-Vm)/Vm;
        Error_Im=(Im_Obtained-Im)/Im;
        Error_Voc_Isc_Vm_Im=[Error_Voc,Error_Isc,Error_Vm,Error_Im];
        Error_Threshold_Red=0.02;


        h=text(0.4*Voc,0.7*Isc,sprintf('Error Voc = %-6.2f %%',Error_Voc*100));
        set(h,'FontName','Courrier','FontSize',9);
        if abs(Error_Voc_Isc_Vm_Im(1))>Error_Threshold_Red
            set(h,'Color',[1,0,0]);
        end
        h=text(0.4*Voc,0.6*Isc,sprintf('Error Isc = %-6.2f %%',Error_Isc*100));
        set(h,'FontName','Courrier','FontSize',9);
        if abs(Error_Voc_Isc_Vm_Im(2))>Error_Threshold_Red
            set(h,'Color',[1,0,0]);
        end
        h=text(0.4*Voc,0.5*Isc,sprintf('Error Vmp = %-6.2f %%',Error_Vm*100));
        set(h,'FontName','Courrier','FontSize',9);
        if abs(Error_Voc_Isc_Vm_Im(3))>Error_Threshold_Red
            set(h,'Color',[1,0,0]);
        end
        h=text(0.4*Voc,0.4*Isc,sprintf('Error Imp = %-6.2f %%',Error_Im*100));
        set(h,'FontName','Courrier','FontSize',9);
        if abs(Error_Voc_Isc_Vm_Im(4))>Error_Threshold_Red
            set(h,'Color',[1,0,0]);
        end


        subplot(212)
        h=plot(V_PV,P_PV,'b',[1e-6,Vm,Voc],[0,Vm*Im,0],'ro');
        set(h,'LineWidth',2.0);
        ylabel('Power (W)')
        xlabel('Voltage (V)')


        n=find(abs(Error_Voc_Isc_Vm_Im)>0.05,1);
        if~isempty(n)
            error(message('physmod:powersys:common:GenericError',Block,sprintf('Error exceeds 5%% on the [Voc Isc Vm Im] parameters')));
        end
    end