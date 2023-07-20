function plotILProperties(varargin)










    narginchk(1,2)
    nVarargs=length(varargin);
    hBlock=varargin{1};
    if nVarargs<2
        hFigure=figure("Tag","Isothermal Liquid Properties (IL) - Plot Fluid Properties");
    else
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="foundation.isothermal_liquid.utilities.isothermal_liquid_properties"


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Isothermal Liquid Properties (IL) - Plot Fluid Properties"
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                string(get_param(hBlock,"ComponentPath"))~="foundation.isothermal_liquid.utilities.isothermal_liquid_properties"
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,'UniformOutput',false),...
    blockParams.Row);


    str=cell2struct(blockParams.Prompt,blockParams.Row);


    ssc.p_max=ssc.p_atm+simscape.Value(100,'MPa');



    try
        checkParameters(ssc,str)
    catch exception
        throwAsCaller(exception)
    end


    [p_TLU_val,fluidProps]=fluidPropertiesUnitsValues(ssc);


    createFigure;


    hPopup=uicontrol('Style','popupmenu','String',fluidProps(:,1),...
    'Units','normalized','Position',[0.2,0.95,0.431,0.05],...
    'Value',1,'Callback',@(hObject,eventData)plotProperties,...
    'FontWeight','bold');


    plotProperties;


    uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
    'Units','normalized','Position',[0.76,0.95,0.2,0.05],...
    'backgroundColor',[1,1,1],...
    'Callback',@(hObject,eventData)foundation.internal.mask.plotILProperties(hBlock,hFigure));



    function createFigure
        clf(hFigure)
        set(hFigure,'Name',get_param(hBlock,'Name'),'Toolbar','figure','Units','normalized')


        fluidInfo={
        "Density: "+num2str(fluidProps{1,4},5)+" (kg/m^3)"
        "Bulk modulus: "+num2str(fluidProps{2,4},5)+" (GPa)"
        "Kinematic viscosity: "+num2str(value(ssc.nu_atm,'mm^2/s'),5)+" (mm^2/s)"
        };


        hp=uipanel('Parent',hFigure,'Units','normalized','OuterPosition',[0.0,0.0,1.0,0.13]);

        uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.0,0.6,0.6,0.4],'Style','text','String','At atmospheric pressure: ',...
        'FontSize',10,'FontWeight','bold','HorizontalAlignment','left');

        uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.0,0.3,0.6,0.4],'Style','text','String',fluidInfo{1},...
        'FontSize',10,'FontWeight','normal','HorizontalAlignment','left');

        uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.0,0.0,0.6,0.4],'Style','text','String',fluidInfo{2},...
        'FontSize',10,'FontWeight','normal','HorizontalAlignment','left');

        uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.5,0.3,0.6,0.4],'Style','text','String',fluidInfo{3},...
        'FontSize',10,'FontWeight','normal','HorizontalAlignment','left');


        setappdata(hFigure,"blockPath",getfullname(hBlock))
    end



    function plotProperties

        idx=get(hPopup,'Value');

        hAxes=gca;
        plot(hAxes,p_TLU_val,fluidProps{idx,2},'LineStyle','-','LineWidth',1.5)
        hold on
        if ssc.air_fraction>0
            plot(hAxes,p_TLU_val,fluidProps{idx,3},'LineStyle','--','LineWidth',1)
            legend('With Entrained Air','No Entrained Air','Location','best')
        end
        hold off

        grid on
        xlabel('Pressure (MPa)')
        ylabel(fluidProps{idx,1})

        set(hAxes,'Xscale','log','XLim',[p_TLU_val(1),p_TLU_val(end)],...
        'Units','normalized','OuterPosition',[0.01,0.13,0.95,0.8]);
    end

end





function checkParameters(ssc,str)

    ssc.p_min_linear=ssc.p_atm-ssc.beta_L_atm/ssc.beta_gain;
    str.p_min_linear='Atmospheric pressure - (Liquid isothermal bulk modulus at atmospheric pressure (no entrained air))/Isothermal bulk modulus vs. pressure increase gain';

    assertPattern(ssc.rho_L_atm>0,"GreaterThanZero",str.rho_L_atm)
    assertPattern(ssc.beta_L_atm>0,"GreaterThanZero",str.beta_L_atm)
    assertPattern(ssc.nu_atm>0,"GreaterThanZero",str.nu_atm)
    assertPattern(ssc.air_fraction>=0,"GreaterThanOrEqualZero",str.air_fraction)
    assertPattern(ssc.air_fraction<1,"LessThan",str.air_fraction,"1")
    assertPattern(ssc.polytropic_index>=1,"GreaterThanOrEqual",str.polytropic_index,"1")
    assertPattern(ssc.rho_g_atm>0,"GreaterThanZero",str.rho_g_atm)

    if ssc.bulk_modulus_model==foundation.enum.bulk_modulus_model.linear

        assertPattern(ssc.beta_gain>0,"GreaterThanZero",str.beta_gain)
        assertPattern(ssc.p_min>ssc.p_min_linear,"GreaterThan",str.p_min,str.p_min_linear)
    end

    if ssc.air_dissolution_model==simscape.enum.onoff.on
        assertPattern(ssc.p_crit>ssc.p_atm,"GreaterThan",str.p_crit,str.p_atm)
    end

    assertPattern(ssc.p_atm>=ssc.p_min,"GreaterThanOrEqual",str.p_atm,"Minimum valid pressure")
    assertPattern(ssc.p_min>0,"GreaterThanZero",str.p_min)

end



function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function[p_plot_val,fluidProps]=fluidPropertiesUnitsValues(ssc)


    p_plot_val=logspace(log10(value(ssc.p_min,'Pa')),log10(value(ssc.p_max,'Pa')),200);


    rho_mix_plot_val=foundation.internal.mask.mixture_density(value(ssc.rho_L_atm,'kg/m^3'),...
    value(ssc.beta_L_atm,'Pa'),value(ssc.beta_gain,'1'),...
    value(ssc.air_fraction,'1'),p_plot_val,value(ssc.p_atm,'Pa'),...
    value(ssc.p_crit,'Pa'),value(ssc.rho_g_atm,'kg/m^3'),...
    value(ssc.polytropic_index,'1'),value(ssc.air_dissolution_model,'1'),...
    ssc.bulk_modulus_model);


    rho_L_plot_val=foundation.internal.mask.mixture_density(value(ssc.rho_L_atm,'kg/m^3'),...
    value(ssc.beta_L_atm,'Pa'),value(ssc.beta_gain,'1'),...
    0,p_plot_val,value(ssc.p_atm,'Pa'),...
    value(ssc.p_crit,'Pa'),value(ssc.rho_g_atm,'kg/m^3'),...
    value(ssc.polytropic_index,'1'),value(ssc.air_dissolution_model,'1'),...
    ssc.bulk_modulus_model);


    rho_mix_atm_val=foundation.internal.mask.mixture_density(value(ssc.rho_L_atm,'kg/m^3'),...
    value(ssc.beta_L_atm,'Pa'),value(ssc.beta_gain,'1'),...
    value(ssc.air_fraction,'1'),value(ssc.p_atm,'Pa'),value(ssc.p_atm,'Pa'),...
    value(ssc.p_crit,'Pa'),value(ssc.rho_g_atm,'kg/m^3'),...
    value(ssc.polytropic_index,'1'),value(ssc.air_dissolution_model,'1'),...
    ssc.bulk_modulus_model);


    beta_mix_plot_val=foundation.internal.mask.mixture_bulk_modulus(value(ssc.beta_L_atm,'Pa'),...
    value(ssc.beta_gain,'1'),value(ssc.air_fraction,'1'),p_plot_val,...
    value(ssc.p_atm,'Pa'),value(ssc.p_crit,'Pa'),value(ssc.polytropic_index,'1'),...
    value(ssc.air_dissolution_model,'1'),ssc.bulk_modulus_model);


    beta_L_plot_val=foundation.internal.mask.mixture_bulk_modulus(value(ssc.beta_L_atm,'Pa'),...
    value(ssc.beta_gain,'1'),0,p_plot_val,...
    value(ssc.p_atm,'Pa'),value(ssc.p_crit,'Pa'),value(ssc.polytropic_index,'1'),...
    value(ssc.air_dissolution_model,'1'),ssc.bulk_modulus_model);


    beta_mix_atm_val=foundation.internal.mask.mixture_bulk_modulus(value(ssc.beta_L_atm,'Pa'),...
    value(ssc.beta_gain,'1'),value(ssc.air_fraction,'1'),value(ssc.p_atm,'Pa'),...
    value(ssc.p_atm,'Pa'),value(ssc.p_crit,'Pa'),value(ssc.polytropic_index,'1'),...
    value(ssc.air_dissolution_model,'1'),ssc.bulk_modulus_model);


    p_plot_val=p_plot_val/1e6;
    rho_mix_plot_val=rho_mix_plot_val*1;
    rho_L_plot_val=rho_L_plot_val*1;
    rho_mix_atm_val=rho_mix_atm_val*1;
    beta_mix_plot_val=beta_mix_plot_val/1e9;
    beta_L_plot_val=beta_L_plot_val/1e9;
    beta_mix_atm_val=beta_mix_atm_val/1e9;

    fluidProps={
    "Density (kg/m^3)",rho_mix_plot_val,rho_L_plot_val,rho_mix_atm_val;
    "Isothermal Bulk Modulus (GPa)",beta_mix_plot_val,beta_L_plot_val,beta_mix_atm_val;
    };

end