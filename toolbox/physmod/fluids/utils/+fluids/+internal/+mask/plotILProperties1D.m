function plotILProperties1D(varargin)










    narginchk(1,2)
    nVarargs=length(varargin);
    hBlock=varargin{1};
    if nVarargs<2
        hFigure=figure("Tag","Isothermal Liquid Predefinied Properties (IL) - Plot Fluid Properties");
    else
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="fluids.isothermal_liquid.utilities.isothermal_liquid_predefined_properties"


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Isothermal Liquid Predefinied Properties (IL) - Plot Fluid Properties"
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                string(get_param(hBlock,"ComponentPath"))~="fluids.isothermal_liquid.utilities.isothermal_liquid_predefined_properties"
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


    ssc.p_max_EG=ssc.p_atm+simscape.Value(100,'MPa');
    ssc.p_max_PG=ssc.p_atm+simscape.Value(100,'MPa');
    ssc.p_max_GL=ssc.p_atm+simscape.Value(100,'MPa');



    try
        checkParameters(ssc,str)
    catch exception
        throwAsCaller(exception)
    end


    [pT_valid_val,rho_L_atm_val,beta_L_atm_val,beta_gain_val,nu_atm_val,...
    p_min_val,~,T_sat_val]=fluids_functions.getPropertiesIL(...
    value(ssc.fluid_list,'1'),value(ssc.concentration_param_EG,'1'),...
    value(ssc.concentration_param_PG,'1'),value(ssc.c_mass_SW,'1'),...
    value(ssc.c_mass_EG,'1'),value(ssc.c_mass_PG,'1'),value(ssc.c_mass_GL,'1'),...
    value(ssc.c_vol_EG,'1'),value(ssc.c_vol_PG,'1'),...
    value(ssc.beta_L_atm_EG,'Pa'),value(ssc.beta_L_atm_PG,'Pa'),...
    value(ssc.beta_L_atm_GL,'Pa'),value(ssc.p_min_EG,'Pa'),...
    value(ssc.p_min_PG,'Pa'),value(ssc.p_min_GL,'Pa'),value(ssc.p_max_EG,'Pa'),...
    value(ssc.p_max_PG,'Pa'),value(ssc.p_max_GL,'Pa'),value(ssc.p_atm,'Pa'),...
    value(ssc.T,'K'));


    ssc.pT_valid=simscape.Value(pT_valid_val,'1');
    ssc.rho_L_atm=simscape.Value(rho_L_atm_val,'kg/m^3');
    ssc.beta_L_atm=simscape.Value(beta_L_atm_val,'GPa');
    ssc.beta_gain=simscape.Value(beta_gain_val,'1');
    ssc.nu_atm=simscape.Value(nu_atm_val,'mm^2/s')*ssc.derate_coeff;
    ssc.p_min=simscape.Value(p_min_val,'MPa');
    ssc.p_max=ssc.p_atm+simscape.Value(100,'MPa');
    ssc.T_sat=simscape.Value(T_sat_val,'K');


    assert(value(ssc.pT_valid,'1')==1,message('physmod:fluids:library:PressureTemperatureValidRegion'))



    assertPattern(ssc.p_atm>=ssc.p_min,"GreaterThanOrEqual",str.p_atm,"Minimum valid pressure")


    if(ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.ethylene_glycol)||...
        (ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.propylene_glycol)||...
        (ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.glycerol)
        ssc.bulk_modulus_model=foundation.enum.bulk_modulus_model.const;
    else
        ssc.bulk_modulus_model=foundation.enum.bulk_modulus_model.linear;
    end



    [p_TLU_val,fluidProps]=fluidPropertiesUnitsValues(ssc);


    title_name=fluidNameString(ssc);


    createFigure;


    hPopup=uicontrol('Style','popupmenu','String',fluidProps(:,1),...
    'Units','normalized','Position',[0.2,0.95,0.431,0.05],...
    'Value',1,'Callback',@(hObject,eventData)plotProperties,...
    'FontWeight','bold');


    plotProperties;


    uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
    'Units','normalized','Position',[0.76,0.95,0.2,0.05],...
    'backgroundColor',[1,1,1],...
    'Callback',@(hObject,eventData)fluids.internal.mask.plotILProperties1D(hBlock,hFigure));



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
        title(title_name)
        set(hAxes,'Xscale','log','XLim',[p_TLU_val(1),p_TLU_val(end)],...
        'Units','normalized','OuterPosition',[0.01,0.13,0.95,0.8]);
    end

end





function checkParameters(ssc,str)

    if ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.mitsw

        assertPattern(ssc.c_mass_SW>0,"GreaterThanZero",str.c_mass_SW)
        assertPattern(ssc.c_mass_SW<=0.12,"LessThanOrEqual",str.c_mass_SW,"0.12")

    elseif ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.ethylene_glycol

        assertPattern(ssc.beta_L_atm_EG>0,"GreaterThanZero",str.beta_L_atm_EG)
        assertPattern(ssc.p_min_EG<=ssc.p_atm,"LessThanOrEqual",str.p_min_EG,str.p_atm)
        if ssc.concentration_param_EG==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_concentration.volume_fraction
            assertPattern(ssc.c_vol_EG>0,"GreaterThanZero",str.c_vol_EG)
            assertPattern(ssc.c_vol_EG<=1,"LessThanOrEqual",str.c_vol_EG,"1")
        else
            assertPattern(ssc.c_mass_EG>0,"GreaterThanZero",str.c_mass_EG)
            assertPattern(ssc.c_mass_EG<=0.6,"LessThanOrEqual",str.c_mass_EG,"0.6")
        end

    elseif ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.propylene_glycol

        assertPattern(ssc.beta_L_atm_PG>0,"GreaterThanZero",str.beta_L_atm_PG)
        assertPattern(ssc.p_min_PG<=ssc.p_atm,"LessThanOrEqual",str.p_min_PG,str.p_atm)
        if ssc.concentration_param_PG==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_concentration.volume_fraction
            assertPattern(ssc.c_vol_PG>=0.1,"GreaterThanOrEqual",str.c_vol_PG,"0.1")
            assertPattern(ssc.c_vol_PG<=0.6,"LessThanOrEqual",str.c_vol_PG,"0.6")
        else
            assertPattern(ssc.c_mass_PG>0,"GreaterThanZero",str.c_mass_PG)
            assertPattern(ssc.c_mass_PG<=0.6,"LessThanOrEqual",str.c_mass_PG,"0.6")
        end

    elseif ssc.fluid_list==fluids.isothermal_liquid.utilities.enum.isothermal_liquid_fluid_list.glycerol

        assertPattern(ssc.c_mass_GL>0,"GreaterThanZero",str.c_mass_GL)
        assertPattern(ssc.c_mass_GL<=0.6,"LessThanOrEqual",str.c_mass_GL,"0.6")
        assertPattern(ssc.beta_L_atm_GL>0,"GreaterThanZero",str.beta_L_atm_GL)
        assertPattern(ssc.p_min_GL<=ssc.p_atm,"LessThanOrEqual",str.p_min_GL,str.p_atm)

    end

    assertPattern(ssc.derate_coeff>0,"GreaterThanZero",str.derate_coeff)
    assertPattern(ssc.air_fraction>=0,"GreaterThanOrEqualZero",str.air_fraction)
    assertPattern(ssc.air_fraction<1,"LessThan",str.air_fraction,"1")
    assertPattern(ssc.polytropic_index>=1,"GreaterThanOrEqual",str.polytropic_index,"1")

    assertPattern(ssc.rho_g_atm>0,"GreaterThanZero",str.rho_g_atm)

    if ssc.air_dissolution_model==simscape.enum.onoff.on
        assertPattern(ssc.p_crit>ssc.p_atm,"GreaterThan",str.p_crit,str.p_atm)
    end

end




function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function title_name=fluidNameString(ssc)


    map_obj=fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.displayText();
    fluid_name=map_obj(char(...
    fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list(value(ssc.fluid_list,'1'))));


    if ssc.fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw
        concen="   ("+num2str(value(ssc.c_mass_SW,'1')*100)+" mass%)";
    elseif ssc.fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        if ssc.concentration_param_EG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            concen="   ("+num2str(value(ssc.c_vol_EG,'1')*100)+" vol%)";
        else
            concen="   ("+num2str(value(ssc.c_mass_EG,'1')*100)+" mass%)";
        end
    elseif ssc.fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        if ssc.concentration_param_PG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            concen="   ("+num2str(value(ssc.c_vol_PG,'1')*100)+" vol%)";
        else
            concen="   ("+num2str(value(ssc.c_mass_PG,'1')*100)+" mass%)";
        end
    elseif ssc.fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        concen="  ("+num2str(value(ssc.c_mass_GL,'1')*100)+" mass%)";
    else
        concen="";
    end


    title_name(1)="\color{black}"+fluid_name+concen;
    title_name(2)="\color[rgb]{0 0.447 0.7410} \fontsize{10} T = "...
    +num2str(value(ssc.T,'K'))+" K,   Entrained air = "+num2str(value(ssc.air_fraction,'1'));

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