function plotTurbineMap(varargin)





    if isstruct(varargin{1})
        h=varargin{1};
    else
        h.hBlock=varargin{1};
        h.hFigure=[];
        h.hReload=[];
        h.hbp1=[];
        h.hbp2=[];
        h.hEditText=[];
        h.p_diff_plot=simscape.Value(1,'MPa');
    end

    if ischar(h.hBlock)||isstring(h.hBlock)
        h.hBlock=getSimulinkBlockHandle(h.hBlock);
    end


    if~is_simulink_handle(h.hBlock)||...
        (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.turbine"&&...
        string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.turbine")


        if~isempty(h.hFigure)&&isgraphics(h.hFigure,"figure")&&...
            string(h.hFigure.Tag)=="Turbine (G) or Turbine (2P) - Plot Turbine Map"
            blockPath=getappdata(h.hFigure,"blockPath");
            h.hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(h.hBlock)||...
                (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.turbine"&&...
                string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.turbine")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(h.hBlock);


    for j=1:height(blockParams)
        param_name=blockParams.Properties.RowNames{j};
        paramValue=blockParams{param_name,'Value'}{1};
        blockStruct.(param_name)=simscapeParameter(blockParams,param_name);
        blockStruct.([param_name,'_prompt'])=blockParams.Prompt{param_name};
    end


    checkParameters(blockStruct);


    createFigure(h);


    plotProperties(blockStruct);

end


function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end

function checkParameters(blockStruct)

    parameterization=value(blockStruct.parameterization,'1');


    pr_mdot_TLU_str="Pressure ratio vector, pr";
    mdot_TLU_str="Corrected mass flow rate vector, mdot(pr)";
    pr_eta_TLU_str="Pressure ratio vector, pr";
    eta_TLU_str="Isentropic efficiency vector, eta(pr)";
    omega_TLU_2_str="Corrected speed vector";
    pr_mdot_TLU_2_str="Pressure ratio table, pr(N,beta)";
    mdot_TLU_2_str="Corrected mass flow rate table, mdot(N,beta)";
    mdot_TLU_2_row_str="rows in the Corrected mass flow rate table, mdot(N,beta)";
    mdot_TLU_2_col_str="columns in the Corrected mass flow rate table, mdot(N,beta)";
    pr_eta_TLU_2_str="Pressure ratio table, pr(N,beta)";
    eta_TLU_2_str="Isentropic efficiency table, eta(N,beta)";
    eta_TLU_2_row_str="rows in the Isentropic efficiency table, eta(N,beta)";
    eta_TLU_2_col_str="columns in the Isentropic efficiency table, eta(N,beta)";
    pr_mdot_col_str="Number of columns in the Pressure ratio table, pr(N,beta)";
    pr_eta_col_str="Number of columns in the Pressure ratio table, pr(N,beta)";
    pr_nom_str="Nominal pressure ratio";
    mdot_nom_str="Nominal corrected mass flow rate";
    efficiency_constant_str="Constant isentropic efficiency";

    p_reference_str="Reference pressure for corrected flow";
    T_reference_str="Reference temperature for corrected flow";
    mechanical_efficiency_str="Mechanical efficiency";
    area_A_str="Inlet area at port A";
    area_B_str="Inlet area at port B";
    min_vane_opening_str="Minimum vane opening";
    max_vane_opening_str="Maximum vane opening";


    assert(value(blockStruct.p_reference,'MPa')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_reference_str))
    assert(value(blockStruct.T_reference,'K')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',T_reference_str))
    assert(value(blockStruct.mechanical_efficiency,'1')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',mechanical_efficiency_str))
    assert(value(blockStruct.area_A,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',area_A_str))
    assert(value(blockStruct.area_B,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',area_B_str))
    assert(value(blockStruct.min_vane_opening,'1')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',min_vane_opening_str))
    assert(value(blockStruct.max_vane_opening,'1')>=value(blockStruct.min_vane_opening,'1'),...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',max_vane_opening_str,min_vane_opening_str))

    if parameterization==fluids.gas.turbomachinery.enum.TurbineParameterization.Analytical


        assert(all(all(value(blockStruct.pr_nom,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',pr_nom_str))
        assert(all(all(value(blockStruct.mdot_nom,'kg/s')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mdot_nom_str))
        assert(all(all(value(blockStruct.efficiency_constant,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',efficiency_constant_str))
        assert(all(all(value(blockStruct.efficiency_constant,'1')<=1)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual',efficiency_constant_str,'1'))

    elseif parameterization==fluids.gas.turbomachinery.enum.TurbineParameterization.Tabulated1D


        assert(length(blockStruct.pr_mdot_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',pr_mdot_TLU_str,"2"))
        assert(length(blockStruct.mdot_TLU)==length(blockStruct.pr_mdot_TLU),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',mdot_TLU_str,pr_mdot_TLU_str))
        assert(length(blockStruct.pr_eta_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',pr_eta_TLU_str,"2"))
        assert(length(blockStruct.eta_TLU)==length(blockStruct.pr_eta_TLU),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',eta_TLU_str,pr_eta_TLU_str))


        assert(all(diff(value(blockStruct.pr_mdot_TLU,'1'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',pr_mdot_TLU_str))
        assert(all(diff(value(blockStruct.mdot_TLU,'kg/s'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',mdot_TLU_str))
        assert(all(diff(value(blockStruct.pr_eta_TLU,'1'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',pr_eta_TLU_str))


        assert(all(value(blockStruct.pr_mdot_TLU,'1')>=1),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqual',pr_mdot_TLU_str,'1'))
        assert(all(value(blockStruct.mdot_TLU,'kg/s')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mdot_TLU_str))
        assert(all(value(blockStruct.pr_eta_TLU,'1')>1),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThan',pr_eta_TLU_str,'1'))
        assert(all(value(blockStruct.eta_TLU,'1')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',eta_TLU_str))
        assert(all(value(blockStruct.eta_TLU,'1')<=1),...
        message('physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual',eta_TLU_str,'1'))

    else


        assert(length(blockStruct.omega_TLU_2)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',omega_TLU_2_str,"2"))
        assert(length(blockStruct.pr_mdot_TLU_2(1,:))>=2,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',pr_mdot_col_str,"2"))
        assert(all(size(blockStruct.pr_mdot_TLU_2)==[length(blockStruct.mdot_TLU_2(:,1)),length(blockStruct.mdot_TLU_2(1,:))]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',pr_mdot_TLU_2_str,mdot_TLU_2_col_str,mdot_TLU_2_row_str))
        assert(length(blockStruct.pr_eta_TLU_2(1,:))>=2,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',pr_eta_col_str,"2"))
        assert(all(size(blockStruct.pr_eta_TLU_2)==[length(blockStruct.eta_TLU_2(:,1)),length(blockStruct.eta_TLU_2(1,:))]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',pr_eta_TLU_2_str,eta_TLU_2_col_str,eta_TLU_2_row_str))


        assert(all(diff(value(blockStruct.omega_TLU_2,'rpm'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',omega_TLU_2_str))
        assert(all(all(diff(value(blockStruct.pr_mdot_TLU_2,'1'),1,2)>0)),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',pr_mdot_TLU_2_str))
        assert(all(all(diff(value(blockStruct.pr_eta_TLU_2,'1'),1,2)>0)),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',pr_eta_TLU_2_str))


        assert(all(all(value(blockStruct.pr_mdot_TLU_2,'1')>1)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThan',pr_mdot_TLU_2_str,'1'))
        assert(all(all(value(blockStruct.mdot_TLU_2,'kg/s')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mdot_TLU_2_str))
        assert(all(all(value(blockStruct.pr_eta_TLU_2,'1')>1)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThan',pr_eta_TLU_2_str,'1'))
        assert(all(all(value(blockStruct.eta_TLU_2,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',eta_TLU_2_str))
        assert(all(all(value(blockStruct.eta_TLU_2,'1')<=1)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual',eta_TLU_2_str,'1'))

    end
end


function createFigure(h)

    if isempty(h.hFigure)
        h.hFigure=figure("Tag","Turbine (G) or Turbine (2P) - Plot Turbine Map");


        h.hReload=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
        'Units','normalized','Position',[0.2,0.935,0.2,0.05],...
        'backgroundColor',[1,1,1],...
        'Callback',{@pushbuttonCallback,h});


        h.hEditText.Callback{2}=h;
        h.hReload.Callback{2}=h;
    else
        if~isgraphics(h.hFigure,'figure')
            h.hFigure=figure('Name',get_param(h.hBlock,'Name'));
        end
    end

    hAxes=gca;
    cla(hAxes);


    setappdata(h.hFigure,"blockPath",getfullname(h.hBlock));
end

function plotProperties(blockStruct)

    LineColors=get(gca,'ColorOrder');

    parameterization=value(blockStruct.parameterization,'1');

    if logical(parameterization==1)


        ax(1)=subplot(2,1,2);
        pr_nom=value(blockStruct.pr_nom,'1');
        mdot_nom_unit=char(unit(blockStruct.mdot_nom));
        mdot_nom=value(blockStruct.mdot_nom,mdot_nom_unit);
        eta=value(blockStruct.efficiency_constant,'1');
        pr_vect=linspace(1,2*pr_nom,100);

        mdot=mdot_nom.*((1-(1./pr_vect).^2)./(1-(1/pr_nom)^2)).^0.5;

        opening=0.2:0.2:1;
        for k=1:length(opening)
            h=plot(pr_vect,opening(k)*mdot,'Color',LineColors(1,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on;
            text(pr_vect(end-1)+0.02,opening(k)*mdot(end-1),[num2str(opening(k)*100),'%'])
        end

        h.DisplayName='Vane Opening (%)';
        h.Annotation.LegendInformation.IconDisplayStyle='on';


        hold off;
        xlabel('Pressure Ratio')
        ylabel({'Corrected Mass',['Flow Rate (',mdot_nom_unit,')']});
        legend('show','Location','best');
        lim=axis;
        xspan=lim(2)-lim(1);
        yspan=lim(4)-lim(3);
        scalemargin=0.1;
        axis([lim(1)-scalemargin*xspan,lim(2)+scalemargin*xspan,lim(3)-scalemargin*yspan,lim(4)+scalemargin*yspan]);
        lim_m=axis;
        grid on;


        ax(2)=subplot(2,1,1);
        h=plot([1,2*pr_nom],[eta,eta],'Color',LineColors(3,:),'LineWidth',1);
        h.DisplayName='Constant Efficiency';
        lim_e=axis;
        axis([lim_m(1),lim_m(2),lim_e(3),lim_e(4)]);
        ylabel('Isentropic Efficiency');
        legend('show','Location','southeast');
        title('Analytical Turbine');
        grid on;
        linkaxes(ax,'x')

    elseif logical(parameterization==2)


        ax(1)=subplot(2,1,2);

        pr_mdot=value(blockStruct.pr_mdot_TLU,'1');
        mdot_unit=char(unit(blockStruct.mdot_TLU));
        mdot=value(blockStruct.mdot_TLU,mdot_unit);
        pr_choke=pr_mdot(end);
        pr_max=max(max(value(blockStruct.pr_mdot_TLU,'1')),max(value(blockStruct.pr_eta_TLU,'1')));
        pr_mdot=[pr_mdot,pr_max];
        mdot=[mdot,mdot(end)];

        opening=0.2:0.2:1;
        for k=1:length(opening)
            h=plot(pr_mdot,opening(k)*mdot,'Color',LineColors(1,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on;
            text(pr_mdot(end-1)+0.02,opening(k)*mdot(end-1),[num2str(opening(k)*100),'%'])
        end

        h.DisplayName='Vane Opening (%)';
        h.Annotation.LegendInformation.IconDisplayStyle='on';



        h=plot([pr_choke,pr_choke],ax(1).YLim,'k:','LineWidth',1);
        h.Annotation.LegendInformation.IconDisplayStyle='off';
        text(pr_choke-0.01,0.1,'Choked','HorizontalAlignment','right');


        hold off;
        xlabel('Pressure Ratio')
        ylabel({'Corrected Mass',['Flow Rate (',mdot_unit,')']});
        legend('show','Location','best');
        grid on;


        ax(2)=subplot(2,1,1);

        pr_eta=value(blockStruct.pr_eta_TLU,'1');
        eta=value(blockStruct.eta_TLU,'1');
        pr_eta=[pr_eta,pr_max];
        eta=[eta,eta(end)];
        plot(pr_eta,eta,'Color',LineColors(3,:),'LineWidth',1);
        ylabel('Isentropic Efficiency');
        title('Turbine Map');
        grid on;
        linkaxes(ax,'x')

    else


        ax(1)=subplot(2,1,2);

        omega_unit=char(unit(blockStruct.omega_TLU_2));
        omega=value(blockStruct.omega_TLU_2,omega_unit);
        pr_mdot=value(blockStruct.pr_mdot_TLU_2,'1');
        mdot_unit=char(unit(blockStruct.mdot_TLU_2));
        mdot=value(blockStruct.mdot_TLU_2,mdot_unit);
        pr_choke=pr_mdot(end);

        for k=1:size(pr_mdot,1)
            h=plot(pr_mdot(k,:),mdot(k,:),'Color',LineColors(1,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on
            text(pr_mdot(k,end),mdot(k,end),num2str(omega(k)));
        end

        h.DisplayName=['Turbine Speed (',omega_unit,')'];
        h.Annotation.LegendInformation.IconDisplayStyle='on';


        hold off;
        xlabel('Pressure Ratio')
        ylabel({'Corrected Mass',['Flow Rate (',mdot_unit,')']});
        legend('show','Location','best');
        grid on;


        ax(2)=subplot(2,1,1);

        pr_eta=value(blockStruct.pr_eta_TLU_2,'1');
        eta=value(blockStruct.eta_TLU_2,'1');
        for k=1:size(pr_eta,1)

            h=plot(pr_eta(k,:),eta(k,:),'Color',LineColors(3,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on;
            text(pr_eta(k,end),eta(k,end),num2str(omega(k)));
        end

        h.DisplayName=['Turbine Speed (',omega_unit,')'];
        h.Annotation.LegendInformation.IconDisplayStyle='on';

        hold off;
        ylabel('Isentropic Efficiency');
        legend('show','Location','best');
        grid on;
        title('Turbine Map');
        linkaxes(ax,'x');
    end


end

function pushbuttonCallback(~,~,h)
    fluids.internal.mask.plotTurbineMap(h);
end
