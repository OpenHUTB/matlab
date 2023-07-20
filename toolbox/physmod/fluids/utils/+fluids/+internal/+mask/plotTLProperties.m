function plotTLProperties(varargin)










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
        string(get_param(hBlock,"ComponentPath"))~="fluids.thermal_liquid.utilities.thermal_liquid_properties"


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Thermal Liquid Properties (TL) - Plot Fluid Properties"
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                string(get_param(hBlock,"ComponentPath"))~="fluids.thermal_liquid.utilities.thermal_liquid_properties"
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
    beta_const_EG=simscapeParameter(blockParams,'beta_const_EG');
    beta_const_PG=simscapeParameter(blockParams,'beta_const_PG');
    beta_const_GL=simscapeParameter(blockParams,'beta_const_GL');
    p_min_EG=simscapeParameter(blockParams,'p_min_EG');
    p_min_PG=simscapeParameter(blockParams,'p_min_PG');
    p_min_GL=simscapeParameter(blockParams,'p_min_GL');
    p_max_EG=simscapeParameter(blockParams,'p_max_EG');
    p_max_PG=simscapeParameter(blockParams,'p_max_PG');
    p_max_GL=simscapeParameter(blockParams,'p_max_GL');
    p_atm=simscapeParameter(blockParams,'p_atm');


    checkParameters(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,beta_const_EG,p_min_EG,p_max_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,beta_const_PG,p_min_PG,p_max_PG,c_vol_PG,c_mass_PG,...
    beta_const_GL,p_min_GL,p_max_GL,c_mass_GL,...
    p_atm);



    [T_TLU_val,p_TLU_val,pT_validity_TLU_val,...
    rho_TLU_val,alpha_TLU_val,beta_TLU_val,...
    u_TLU_val,cp_TLU_val,k_TLU_val,nu_TLU_val,...
    ~,~,T_min_val,T_max_val,...
    p_min_val,p_max_val,~]=fluids_functions.getProperties(...
    value(fluid_list,'1'),value(concentration_param_EG,'1'),...
    value(concentration_param_PG,'1'),value(c_mass_SW,'1'),...
    value(c_mass_EG,'1'),value(c_mass_PG,'1'),value(c_mass_GL,'1'),...
    value(c_vol_EG,'1'),value(c_vol_PG,'1'),...
    value(beta_const_EG,'Pa'),value(beta_const_PG,'Pa'),...
    value(beta_const_GL,'Pa'),value(p_min_EG,'Pa'),...
    value(p_min_PG,'Pa'),value(p_min_GL,'Pa'),value(p_max_EG,'Pa'),...
    value(p_max_PG,'Pa'),value(p_max_GL,'Pa'),value(p_atm,'Pa'));


    T_TLU=simscape.Value(T_TLU_val,'K');
    p_TLU=simscape.Value(p_TLU_val,'MPa');
    pT_validity_TLU=simscape.Value(pT_validity_TLU_val,'1');
    rho_TLU=simscape.Value(rho_TLU_val,'kg/m^3');
    alpha_TLU=simscape.Value(alpha_TLU_val,'1/K');
    beta_TLU=simscape.Value(beta_TLU_val,'GPa');
    u_TLU=simscape.Value(u_TLU_val,'kJ/kg');
    cp_TLU=simscape.Value(cp_TLU_val,'kJ/(kg*K)');
    k_TLU=simscape.Value(k_TLU_val,'mW/(m*K)');
    nu_TLU=simscape.Value(nu_TLU_val,'mm^2/s');
    T_min=simscape.Value(T_min_val,'K');
    T_max=simscape.Value(T_max_val,'K');
    p_min=simscape.Value(p_min_val,'MPa');
    p_max=simscape.Value(p_max_val,'MPa');


    [T_TLU_val,p_TLU_val,p_TLU_unit,fluidProps]=fluidPropertiesUnitsValues(...
    fluid_list,T_TLU,p_TLU,pT_validity_TLU,rho_TLU,alpha_TLU,beta_TLU,...
    u_TLU,cp_TLU,k_TLU,nu_TLU,beta_const_EG,...
    beta_const_PG,beta_const_GL,p_max_EG,p_max_PG,p_max_GL);


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
            hFigure=figure("Tag","Thermal Liquid Properties (TL) - Plot Fluid Properties");
        end

        hFigure.Units='normalized';

        clf(hFigure)
        set(hFigure,'Name',get_param(hBlock,'Name'),'Toolbar','figure')


        fluidBounds={
        ['T_min = ',num2str(value(T_min,'K'),'%0.2f'),' K'];
        ['T_max = ',num2str(value(T_max,'K'),'%0.2f'),' K'];
        ['p_min = ',num2str(value(p_min,'MPa'),'%0.2e'),' MPa'];
        ['p_max = ',num2str(value(p_max,'MPa'),'%0.2e'),' MPa'];
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

        hbp4=uicontrol('Parent',hp,'Units','normalized','Position',...
        [0.6,0.12,0.6,0.4],'Style','text','String',fluidBounds{4},'FontSize',...
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
        xlabel(['Pressure',' (',char(p_TLU_unit),')'],'FontWeight','bold')
        ylabel(['Temperature',' (K)'],'FontWeight','bold')
        zlabel(fluidProps{idx,1},'FontWeight','bold','Units','normalized','Position',[-0.12,0.5])
        title(fluid_name{1})

        hold off

        view(hAxes,-154,20)
        hAxes.Units='normalized';
        set(hAxes,'OuterPosition',[0.01,0.13,0.95,0.8]);
    end

    function pushbuttonCallback
        fluids.internal.mask.plotTLProperties(hBlock,hFigure)
    end

end

function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end

function checkParameters(fluid_list,...
    c_mass_SW,...
    concentration_param_EG,beta_const_EG,p_min_EG,p_max_EG,c_vol_EG,c_mass_EG,...
    concentration_param_PG,beta_const_PG,p_min_PG,p_max_PG,c_vol_PG,c_mass_PG,...
    beta_const_GL,p_min_GL,p_max_GL,c_mass_GL,...
    p_atm)


    c_mass_SW_str="Dissolved salt mass fraction (salinity)";
    c_mass_EG_str="Ethylene glycol mass fraction";
    c_mass_PG_str="Propylene glycol mass fraction";
    c_mass_GL_str="Glycerol mass fraction";
    c_vol_EG_str="Ethylene glycol volume fraction";
    c_vol_PG_str="Propylene glycol volume fraction";
    beta_const_EG_str="Isothermal bulk modulus";
    beta_const_PG_str="Isothermal bulk modulus";
    beta_const_GL_str="Isothermal bulk modulus";
    p_min_EG_str="Minimum valid pressure";
    p_min_PG_str="Minimum valid pressure";
    p_min_GL_str="Minimum valid pressure";
    p_max_EG_str="Maximum valid pressure";
    p_max_PG_str="Maximum valid pressure";
    p_max_GL_str="Maximum valid pressure";
    p_atm_str="Atmospehric pressure";

    assert(p_atm>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_atm_str))

    if fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw
        assert(c_mass_SW>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_SW_str))
        assert(c_mass_SW<=0.12,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_SW_str,"0.12"))

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        assert(beta_const_EG>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_EG_str))
        assert(p_min_EG<=p_atm,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_EG_str,p_atm_str))
        assert(p_max_EG>=p_atm,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_EG_str,p_atm_str))

        if concentration_param_EG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            assert(c_vol_EG>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_vol_EG_str))
            assert(c_vol_EG<=1,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_vol_EG_str,"1"))
        else
            assert(c_mass_EG>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_EG_str))
            assert(c_mass_EG<=0.6,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_EG_str,"0.6"))
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        assert(beta_const_PG>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_PG_str))
        assert(p_min_PG<=p_atm,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_PG_str,p_atm_str))
        assert(p_max_PG>=p_atm,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_PG_str,p_atm_str))

        if concentration_param_PG==fluids.thermal_liquid.utilities.enum.thermal_liquid_concentration.volume_fraction
            assert(c_vol_PG>=0.1,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',c_vol_PG_str,"0.1"))
            assert(c_vol_PG<=0.6,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_vol_PG_str,"0.6"))
        else
            assert(c_mass_PG>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_PG_str))
            assert(c_mass_PG<=0.6,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_PG_str,"0.6"))
        end

    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        assert(c_mass_GL>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',c_mass_GL_str))
        assert(c_mass_GL<=0.6,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',c_mass_GL_str,"0.6"))
        assert(beta_const_GL>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_GL_str))
        assert(p_min_GL<=p_atm,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_GL_str,p_atm_str))
        assert(p_max_GL>=p_atm,...
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
    fluid_list,T_TLU,p_TLU,pT_validity_TLU,rho_TLU,alpha_TLU,beta_TLU,...
    u_TLU,cp_TLU,k_TLU,nu_TLU,beta_const_EG,...
    beta_const_PG,beta_const_GL,p_max_EG,p_max_PG,p_max_GL)


    if fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        beta_TLU_unit=unit(beta_const_EG);
        p_TLU_unit=unit(p_max_EG);


    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        beta_TLU_unit=unit(beta_const_PG);
        p_TLU_unit=unit(p_max_PG);


    elseif fluid_list==fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        beta_TLU_unit=unit(beta_const_GL);
        p_TLU_unit=unit(p_max_GL);

    else
        beta_TLU_unit=simscape.Unit('GPa');
        p_TLU_unit=simscape.Unit('MPa');
    end


    T_TLU_val=value(T_TLU,'K');
    p_TLU_val=value(p_TLU,p_TLU_unit);
    rho_TLU_val=value(rho_TLU,'kg/m^3');
    beta_TLU_val=value(beta_TLU,beta_TLU_unit);
    alpha_TLU_val=value(alpha_TLU,'1/K');
    u_TLU_val=value(u_TLU,'kJ/kg');
    cp_TLU_val=value(cp_TLU,'kJ/(kg*K)');
    nu_TLU_val=value(nu_TLU,'mm^2/s');
    k_TLU_val=value(k_TLU,'mW/(m*K)');


    fluidProps={
    ['Density',' (kg/m^3)'],rho_TLU_val;
    ['Isothermal Bulk Modulus',' (',char(beta_TLU_unit),')'],beta_TLU_val;
    ['Isobaric thermal expansion coefficient',' (1/K)'],alpha_TLU_val;
    ['Specific internal energy',' (kJ/kg)'],u_TLU_val;
    ['Specific Heat at Constant Pressure',' (kJ/(kg*K))'],cp_TLU_val;
    ['Kinematic Viscosity',' (mm^2/s)'],nu_TLU_val;
    ['Thermal Conductivity',' (mW/(m*K))'],k_TLU_val;
    };


    for i=1:length(fluidProps)
        indx=value(pT_validity_TLU,'1')==0;
        fluidProps{i,2}(indx)=nan;
    end
end