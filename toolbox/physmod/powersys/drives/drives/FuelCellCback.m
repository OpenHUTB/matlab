function FuelCellCback(block,CallBack)








    switch CallBack

    case 'Preset'



        ME=get_param(block,'MaskEnables');
        T='off';

        switch get_param(block,'PresetModel')
        case 'No (User-Defined)'
            T='on';
        end

        ME{2}=T;

        for i=4:12
            ME{i}=T;
        end
        set_param(block,'MaskEnables',ME);

    case 'Visibilities'



        MV=get_param(block,'MaskVisibilities');
        DisplayUnderShoot='off';
        T='off';

        MaskObj=Simulink.Mask.get(block);
        ViewCellParametersButton=MaskObj.getDialogControl('ViewParam');
        PlotGraphButton=MaskObj.getDialogControl('plot_graph');

        switch get_param(block,'Detailed')
        case 'Detailed'
            T='on';
            if strcmp(get_param(block,'FlowRateAir'),'on')
                DisplayUnderShoot=get_param(block,'FCDyn');
            end
            ViewCellParametersButton.Visible='on';
            PlotGraphButton.Visible='on';
        otherwise
            ViewCellParametersButton.Visible='off';
            PlotGraphButton.Visible='off';
        end

        for i=7:19
            MV{i}=T;
        end

        MV{21}=get_param(block,'FCDyn');
        MV{22}=DisplayUnderShoot;
        MV{23}=DisplayUnderShoot;

        set_param(block,'MaskVisibilities',MV);

    case 'Inputs'

        DetailedLevel=get_param(block,'Detailed');


        SignalList={'SignX','SignY','FlowRateH2','FlowRateAir','SystemTemp','SystemPH2','SystemPAir'};
        ValueList={'FC.x*100','FC.y*100','FC.Uf_H2','FC.Uf_O2','FC.Tnom','FC.Pf','FC.PAir'};
        NameList={'x_H2','y_O2','FuelFr','AirFr','T','Pfuel','PAir'};

        for i=1:7

            blockName=[block,'/',NameList{i}];
            BlkType=get_param(blockName,'BlockType');
            CheckBox=get_param(block,SignalList{i});

            if strcmp(CheckBox,'on')&&strcmp(BlkType,'Constant')&&strcmp(DetailedLevel,'Detailed')
                replace_block(blockName,'Name',NameList{i},'Inport','noprompt');
            elseif(strcmp(CheckBox,'off')||strcmp(DetailedLevel,'Simplified'))&&strcmp(BlkType,'Inport')
                replace_block(blockName,'Name',NameList{i},'Constant','noprompt');
                set_param(blockName,'Value',ValueList{i})
            end

        end

    case 'PlotGraph'

        Eoc=getSPSmaskvalues(block,{'Eoc'});
        NomVI=getSPSmaskvalues(block,{'NomVI'});
        EndVI=getSPSmaskvalues(block,{'EndVI'});
        Nc=getSPSmaskvalues(block,{'Nc'});
        n=getSPSmaskvalues(block,{'n'});
        Top=getSPSmaskvalues(block,{'TOp'});
        AirFr=getSPSmaskvalues(block,{'AirFr'});
        SuppPress=getSPSmaskvalues(block,{'SuppPress'});
        Comp=getSPSmaskvalues(block,{'Comp'});
        WantFlowRateH2=get_param(block,'FlowRateH2');
        WantFlowRateAir=get_param(block,'FlowRateAir');

        FC=FuelCellInit(block,Eoc,NomVI,EndVI,Nc,n,Top,AirFr,SuppPress,Comp,WantFlowRateH2,WantFlowRateAir);


        set(0,'ShowHiddenHandles','on')
        hFCfig=findobj('Name','Fuel Cell curves');

        set(0,'ShowHiddenHandles','off')

        blockObj=get_param(block,'Object');
        dlg=DAStudio.ToolRoot.getOpenDialogs(blockObj.getDialogSource);
        imd=DAStudio.imDialog.getIMWidgets(dlg);
        imd.clickApply(dlg)


        i=0:FC.Imax/100:FC.Imax;
        Efc=FC.OCV+FC.NcAnom*log(FC.i0nom)-FC.NcAnom*log(max(i,FC.i0nom))-FC.Rohm*i;

        if isempty(hFCfig)
            figure('Name','Fuel Cell curves')
        end
        subplot(2,1,1);
        plot(i,Efc)
        hold on
        plot(FC.Imax,FC.Vmin,'*','LineWidth',4)
        text(FC.Imax,FC.Vmin,['(',num2str(FC.Imax),',',num2str(FC.Vmin),')'],'VerticalAlignment','bottom')
        plot(FC.Inom,FC.Vnom,'*','LineWidth',4)
        text(FC.Inom,FC.Vnom,['(',num2str(FC.Inom),',',num2str(FC.Vnom),')'],'VerticalAlignment','bottom')
        hold off
        title('Stack voltage vs current')
        ylabel('Voltage(V)')
        xlabel('Current(A)')
        grid on
        subplot(2,1,2)
        plot(i,Efc.*i/1000)
        hold on
        plot(FC.Imax,FC.Imax*FC.Vmin/1000,'*','LineWidth',4)
        text(FC.Imax,FC.Imax*FC.Vmin/1000,['(',num2str(FC.Imax*FC.Vmin/1000),'kW)'],'VerticalAlignment','top')
        plot(FC.Inom,FC.Inom*FC.Vnom/1000,'*','LineWidth',4)
        text(FC.Inom,FC.Inom*FC.Vnom/1000,['(',num2str(FC.Inom*FC.Vnom/1000),'kW)'],'VerticalAlignment','top')
        hold off
        title('Stack power vs current')
        ylabel('Power(kW)')
        xlabel('Current(A)')
        grid on

    case 'ViewParam'

        Eoc=getSPSmaskvalues(block,{'Eoc'});
        NomVI=getSPSmaskvalues(block,{'NomVI'});
        EndVI=getSPSmaskvalues(block,{'EndVI'});
        Nc=getSPSmaskvalues(block,{'Nc'});
        n=getSPSmaskvalues(block,{'n'});
        Top=getSPSmaskvalues(block,{'TOp'});
        AirFr=getSPSmaskvalues(block,{'AirFr'});
        SuppPress=getSPSmaskvalues(block,{'SuppPress'});
        Comp=getSPSmaskvalues(block,{'Comp'});
        WantFlowRateH2=get_param(block,'FlowRateH2');
        WantFlowRateAir=get_param(block,'FlowRateAir');

        FC=FuelCellInit(block,Eoc,NomVI,EndVI,Nc,n,Top,AirFr,SuppPress,Comp,WantFlowRateH2,WantFlowRateAir);

        str=sprintf([
        'Fuel cell nominal parameters:',...
        '\n   Stack Power:',...
        '\n         -Nominal = ',num2str(FC.Pnom),' W',...
        '\n         -Maximal = ',num2str(FC.Vmin*FC.Imax),' W',...
        '\n   Fuel Cell Resistance = ',num2str(FC.Rohm),' ohms',...
        '\n   Nerst voltage of one cell [En] = ',num2str(FC.Ennom),' V',...
        '\n   Nominal Utilization:',...
        '\n         -Hydrogen (H2)= ',num2str(FC.Uf_H2*100,4),' %%',...
        '\n         -Oxidant  (O2)= ',num2str(FC.Uf_O2*100,4),' %%',...
        '\n   Nominal Consumption:',...
        '\n         -Fuel = ',num2str(FC.Vslpm_Fuel,4),' slpm',...
        '\n         -Air  = ',num2str(FC.Vslpm_Air,4),' slpm',...
        '\n   Exchange current [i0] = ',num2str(FC.i0nom),' A',...
        '\n   Exchange coefficient [alpha] = ',num2str(FC.alpha),' ',...
        '\n   \n',...
        'Fuel cell signal variation parameters:',...
        '\n   Fuel composition [x_H2] = ',num2str(FC.x*100,4),' %%',...
        '\n   Oxidant composition [y_O2] = ',num2str(FC.y*100,4),' %%',...
        '\n   Fuel flow rate [FuelFr] at nominal Hydrogen utilization:',...
        '\n         -Nominal = ',num2str(FC.FuelFr_Nom,4),' lpm',...
        '\n         -Maximum = ',num2str(FC.FuelFr_Max,4),' lpm',...
        '\n   Air flow rate [AirFr] at nominal Oxidant utilization:',...
        '\n         -Nominal = ',num2str(FC.AirFr_Nom,4),' lpm',...
        '\n         -Maximum = ',num2str(FC.AirFr_Max,4),' lpm',...
        '\n   System Temperature [T] = ',num2str(FC.Tnom),' Kelvin',...
        '\n   Fuel supply pressure [Pfuel] = ',num2str(FC.Pf),' bar',...
        '\n   Air supply pressure [PAir] = ',num2str(FC.PAir),' bar',...
        ]);
        msgbox(str,'Fuel Cell parameters');

    end