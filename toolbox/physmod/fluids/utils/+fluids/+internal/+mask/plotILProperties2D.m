function plotILProperties2D(varargin)
















    nVarargs=length(varargin);
    if nVarargs==2
        hBlock=varargin{1};
        hFigure=varargin{2};
    else
        hBlock=varargin{1};
        hFigure=[];
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="fluids.isothermal_liquid.utilities.isothermal_liquid_predefined_properties"


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Isothermal Liquid Properties (IL) - Plot Fluid Properties"
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


    fluid_list=simscapeParameter(blockParams,'fluid_list');
    concentration_param_EG=simscapeParameter(blockParams,'concentration_param_EG');
    concentration_param_PG=simscapeParameter(blockParams,'concentration_param_PG');
    c_mass_SW=simscapeParameter(blockParams,'c_mass_SW');
    c_mass_EG=simscapeParameter(blockParams,'c_mass_EG');
    c_mass_PG=simscapeParameter(blockParams,'c_mass_PG');
    c_mass_GL=simscapeParameter(blockParams,'c_mass_GL');
    c_vol_EG=simscapeParameter(blockParams,'c_vol_EG');
    c_vol_PG=simscapeParameter(blockParams,'c_vol_PG');
    beta_L_atm_EG=simscapeParameter(blockParams,'beta_L_atm_EG');
    beta_L_atm_PG=simscapeParameter(blockParams,'beta_L_atm_PG');
    beta_L_atm_GL=simscapeParameter(blockParams,'beta_L_atm_GL');
    p_min_EG=simscapeParameter(blockParams,'p_min_EG');
    p_min_PG=simscapeParameter(blockParams,'p_min_PG');
    p_min_GL=simscapeParameter(blockParams,'p_min_GL');
    p_atm=simscapeParameter(blockParams,'p_atm');
    p_max_EG=1e3*p_atm;
    p_max_PG=1e3*p_atm;
    p_max_GL=1e3*p_atm;



    checkParameters(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,beta_L_atm_EG,p_min_EG,p_max_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,beta_L_atm_PG,p_min_PG,p_max_PG,c_vol_PG,c_mass_PG,...
    beta_L_atm_GL,p_min_GL,p_max_GL,c_mass_GL,...
    p_atm);



    [T_TLU_val,p_TLU_val,pT_validity_TLU_val,...
    rho_TLU_val,~,beta_TLU_val,~,~,~,...
    nu_TLU_val,~,~,T_min_val,T_max_val,...
    p_min_val,p_max_val,~]=fluids_functions.getProperties(...
    value(fluid_list,'1'),value(concentration_param_EG,'1'),...
    value(concentration_param_PG,'1'),value(c_mass_SW,'1'),...
    value(c_mass_EG,'1'),value(c_mass_PG,'1'),value(c_mass_GL,'1'),...
    value(c_vol_EG,'1'),value(c_vol_PG,'1'),...
    value(beta_L_atm_EG,'Pa'),value(beta_L_atm_PG,'Pa'),...
    value(beta_L_atm_GL,'Pa'),value(p_min_EG,'Pa'),...
    value(p_min_PG,'Pa'),value(p_min_GL,'Pa'),value(p_max_EG,'Pa'),...
    value(p_max_PG,'Pa'),value(p_max_GL,'Pa'),value(p_atm,'Pa'));


    T_TLU=simscape.Value(T_TLU_val,'K');
    p_TLU=simscape.Value(p_TLU_val,'MPa');
    pT_validity_TLU=simscape.Value(pT_validity_TLU_val,'1');
    rho_TLU=simscape.Value(rho_TLU_val,'kg/m^3');
    beta_TLU=simscape.Value(beta_TLU_val,'GPa');
    nu_TLU=simscape.Value(nu_TLU_val,'mm^2/s');
    T_min=simscape.Value(T_min_val,'K');
    T_max=simscape.Value(T_max_val,'K');
    p_min=simscape.Value(p_min_val,'MPa');
    p_max=simscape.Value(p_max_val,'MPa');


    [T_TLU_val,p_TLU_val,p_TLU_unit,fluidProps]=fluidPropertiesUnitsValues(...
    fluid_list,T_TLU,p_TLU,pT_validity_TLU,rho_TLU,beta_TLU,...
    nu_TLU,beta_L_atm_EG,beta_L_atm_PG,beta_L_atm_GL,p_max_EG,p_max_PG,p_max_GL);


    fluid_name=fluidNameString(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,c_vol_PG,c_mass_PG,...
    c_mass_GL);


    createFigure;


    hPopup=uicontrol('Style','popupmenu','String',fluidProps(:,1),...
    'Units','normalized','Position',[0.2,0.95,0.431,0.05],...
    'Value',1,'Callback',@(hObject,eventData)plotProperties,...
    'FontWeight','bold');


    plotProperties;


    uiObj=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
    'Units','normalized','Position',[0.76,0.95,0.2,0.05],...
    'backgroundColor',[1,1,1],...
    'Callback',@(hObject,eventData,hBlock)pushbuttonCallback);

    hFigure=uiObj.Parent;

    function createFigure

        if nVarargs==2
            if~isgraphics(hFigure,'figure')
                hFigure=figure('Name',get_param(hBlock,'Name'));
            end
        else
            hFigure=figure("Tag","Isothermal Liquid Properties (IL) - Plot Fluid Properties");
        end

        hFigure.Units='normalized';

        clf(hFigure)
        set(hFigure,'Name',get_param(hBlock,'Name'),'Toolbar','figure')


        fluidBounds={
        ['T_min = ',num2str(value(T_min,'K'),'%0.2f'),' K'];
        ['T_max = ',num2str(value(T_max,'K'),'%0.2f'),' K'];
        ['p_min = ',num2str(value(p_min,'MPa'),'%0.2e'),' MPa'];
        };


        hp=uipanel('Parent',hFigure);
        hp.Units='normalized';
        set(hp,'OuterPosition',[0.0,0.0,1.0,0.1]);
        hbp1=uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.0,0.6,0.6,0.4],'Style','text','String',fluidBounds{1},'FontSize',...
        10,'FontWeight','bold','HorizontalAlignment','left');

        hbp2=uicontrol('Parent',hp,'Units','normalized','OuterPosition',...
        [0.0,0.12,0.6,0.4],'Style','text','String',fluidBounds{2},'FontSize',...
        10,'FontWeight','bold','HorizontalAlignment','left');

        hbp3=uicontrol('Parent',hp,'Units','normalized','Position',...
        [0.6,0.6,0.6,0.4],'Style','text','String',fluidBounds{3},'FontSize',...
        10,'FontWeight','bold','HorizontalAlignment','left');


        setappdata(hFigure,"blockPath",getfullname(hBlock))
    end

    function plotProperties


        idx=get(hPopup,'Value');


        hAxes=gca;
        [az,el]=view(hAxes);
        fluidPropTable=fluidProps{idx,2};

        surf(hAxes,p_TLU_val,T_TLU_val,fluidPropTable,'LineStyle',...
        '-','EdgeColor',[0.8,0.8,0.8],'LineWidth',0.5)

        hold on
        set(hAxes,'XScale','log')
        view(hAxes,az,el)
        xlabel(['Pressure',' (',p_TLU_unit,')'],'FontWeight','bold')
        ylabel(['Temperature',' (K)'],'FontWeight','bold')
        zlabel(fluidProps{idx,1},'FontWeight','bold','Units','normalized','Position',[-0.12,0.5])



        title_name(1)="\color{black}"+fluid_name{1};
        title_name(2)="\color[rgb]{0 0.447 0.7410} \fontsize{10} "...
        +" Entrained air = 0";

        title(title_name)

        hold off

        view(hAxes,-154,20)
        hAxes.Units='normalized';
        set(hAxes,'OuterPosition',[0.01,0.13,0.95,0.8]);
    end

    function pushbuttonCallback
        fluids.internal.mask.plotILProperties2D(hBlock,hFigure)
    end

end

function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end

function checkParameters(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,beta_L_atm_EG,p_min_EG,p_max_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,beta_L_atm_PG,p_min_PG,p_max_PG,c_vol_PG,c_mass_PG,...
    beta_L_atm_GL,p_min_GL,p_max_GL,c_mass_GL,...
    p_atm)


    c_mass_SW_str="Dissolved salt mass fraction (salinity)";
    c_mass_EG_str="Ethylene glycol mass fraction";
    c_mass_PG_str="Propylene glycol mass fraction";
    c_mass_GL_str="Glycerol mass fraction";
    c_vol_EG_str="Ethylene glycol volume fraction";
    c_vol_PG_str="Propylene glycol volume fraction";
    beta_L_atm_EG_str="Isothermal bulk modulus";
    beta_L_atm_PG_str="Isothermal bulk modulus";
    beta_L_atm_GL_str="Isothermal bulk modulus";
    p_min_EG_str="Minimum valid pressure";
    p_min_PG_str="Minimum valid pressure";
    p_min_GL_str="Minimum valid pressure";
    p_max_EG_str="Maximum valid pressure";
    p_max_PG_str="Maximum valid pressure";
    p_max_GL_str="Maximum valid pressure";
    p_atm_str="Atmospehric pressure";

    assert(value(p_atm>0,'1'),...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_atm_str))

    if fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw
        assert(value(c_mass_SW>0,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_SW_str))
        assert(value(c_mass_SW<=0.12,'1'),...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_SW_str,"0.12"))

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        assert(value(beta_L_atm_EG>0,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_L_atm_EG_str))
        assert(value(p_min_EG<=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_EG_str,p_atm_str))
        assert(value(p_max_EG>=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_EG_str,p_atm_str))

        if concentration_param_EG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            assert(value(c_vol_EG>0,'1'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_vol_EG_str))
            assert(value(c_vol_EG<=1,'1'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_vol_EG_str,"1"))
        else
            assert(value(c_mass_EG>0,'1'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_EG_str))
            assert(value(c_mass_EG<=0.6,'1'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_EG_str,"0.6"))
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        assert(value(beta_L_atm_PG>0,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_L_atm_PG_str))
        assert(value(p_min_PG<=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_PG_str,p_atm_str))
        assert(value(p_max_PG>=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_PG_str,p_atm_str))

        if concentration_param_PG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            assert(value(c_vol_PG>=0.1,'1'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',c_vol_PG_str,"0.1"))
            assert(value(c_vol_PG<=0.6,'1'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_vol_PG_str,"0.6"))
        else
            assert(value(c_mass_PG>0,'1'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_PG_str))
            assert(value(c_mass_PG<=0.6,'1'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_PG_str,"0.6"))
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        assert(value(c_mass_GL>0,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_GL_str))
        assert(value(c_mass_GL<=0.6,'1'),...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_GL_str,"0.6"))
        assert(value(beta_L_atm_GL>0,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_L_atm_GL_str))
        assert(value(p_min_GL<=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_GL_str,p_atm_str))
        assert(value(p_max_GL>=p_atm,'1'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_GL_str,p_atm_str))
    end

end


function fluid_name=fluidNameString(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,c_vol_PG,c_mass_PG,...
    c_mass_GL)


    map_obj=fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.displayText();

    if fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.water
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.water);
        concen="";

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw);
        concen=strcat(num2str(value(c_mass_SW,'1')*100),' mass%');

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol);
        if concentration_param_EG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            concen=strcat(num2str(value(c_vol_EG,'1')*100),' vol%');
        else
            concen=strcat(num2str(value(c_mass_EG,'1')*100),' mass%');
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol);
        if concentration_param_PG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            concen=strcat(num2str(value(c_vol_PG,'1')*100),' vol%');
        else
            concen=strcat(num2str(value(c_mass_PG,'1')*100),' mass%');
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol);
        concen=strcat(num2str(value(c_mass_GL,'1')*100),' mass%');

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.jet_A
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.jet_A);
        concen="";

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.diesel
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.diesel);
        concen="";
    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.sae5w30
        map_keys=cellstr(fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.sae5w30);
        concen="";
    end

    if(fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.water)||...
        (fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.jet_A)||...
        (fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.diesel)||...
        (fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.sae5w30)
        fluid_name=values(map_obj,map_keys);

    else
        fluid_name=strcat(string(values(map_obj,map_keys)),'  (',concen,')');
    end
end

function[T_TLU_val,p_TLU_val,p_TLU_unit,fluidProps]=fluidPropertiesUnitsValues(...
    fluid_list,T_TLU,p_TLU,pT_validity_TLU,rho_TLU,beta_TLU,nu_TLU,...
    beta_L_atm_EG,beta_L_atm_PG,beta_L_atm_GL,p_max_EG,p_max_PG,p_max_GL)


    if fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        beta_TLU_unit=unit(beta_L_atm_EG);
        p_TLU_unit=unit(p_max_EG);


    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        beta_TLU_unit=unit(beta_L_atm_PG);
        p_TLU_unit=unit(p_max_PG);


    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        beta_TLU_unit=unit(beta_L_atm_GL);
        p_TLU_unit=unit(p_max_GL);

    else
        beta_TLU_unit='GPa';
        p_TLU_unit='MPa';
    end


    T_TLU_val=value(T_TLU,'K');
    p_TLU_val=value(p_TLU,p_TLU_unit);
    rho_TLU_val=value(rho_TLU,'kg/m^3');
    beta_TLU_val=value(beta_TLU,beta_TLU_unit);
    nu_TLU_val=value(nu_TLU,'mm^2/s');


    fluidProps={
    ['Density',' (kg/m^3)'],rho_TLU_val;
    ['Isothermal Bulk Modulus',' (',beta_TLU_unit,')'],beta_TLU_val;
    ['Kinematic Viscosity',' (mm^2/s)'],nu_TLU_val;
    };


    for i=1:length(fluidProps)
        indx=value(pT_validity_TLU,'1')==0;
        fluidProps{i,2}(indx)=nan;
    end
end










