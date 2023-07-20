function plot2PProperties(varargin)










    narginchk(2,3)


    plotType=varargin{1};
    hBlock=varargin{2};

    if nargin==3
        hFigure=varargin{3};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties"


        if exist("hFigure","var")
            if isgraphics(hFigure,"figure")&&...
                string(hFigure.Tag)=="Two-Phase Fluid Properties (2P) - Plot Fluid Properties"
                blockPath=getappdata(hFigure,"blockPath");
                hBlock=getSimulinkBlockHandle(blockPath);


                if~is_simulink_handle(hBlock)||...
                    string(get_param(hBlock,"ComponentPath"))~="fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties"
                    error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
                end
            else
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        end
    end


    ssc=extractParameters(hBlock);





    p_crit_fraction=0.12;
    if logical(ssc.p_TLU_max>ssc.p_crit)
        [k_liq_clip_val,k_vap_clip_val]=simscape.library.two_phase_fluid.clipCriticalRegion(...
        value(ssc.p_TLU,'MPa'),value(ssc.p_crit,'MPa'),p_crit_fraction,...
        value(ssc.k_liq,'W/(m*K)'),value(ssc.k_vap,'W/(m*K)'));
        ssc.k_liq=simscape.Value(k_liq_clip_val,'W/(m*K)');
        ssc.k_vap=simscape.Value(k_vap_clip_val,'W/(m*K)');

        [Pr_liq_clip_val,Pr_vap_clip_val]=simscape.library.two_phase_fluid.clipCriticalRegion(...
        value(ssc.p_TLU,'MPa'),value(ssc.p_crit,'MPa'),p_crit_fraction,...
        value(ssc.Pr_liq,'1'),value(ssc.Pr_vap,'1'));
        ssc.Pr_liq=simscape.Value(Pr_liq_clip_val,'1');
        ssc.Pr_vap=simscape.Value(Pr_vap_clip_val,'1');
    end


    [fluidProps,satProps,supProps,panelData]=getFluidProperties(ssc);


    fluidNameMap=fluids.two_phase_fluid.utilities.enum.Fluid.displayText;
    [~,fluidCellStr]=enumeration('fluids.two_phase_fluid.utilities.enum.Fluid');
    fluidName=fluidNameMap(fluidCellStr{ssc.fluid});


    if nargin==3
        plotFluidProperties(fluidName,plotType,fluidProps,satProps,supProps,panelData,hBlock,hFigure)
    else
        plotFluidProperties(fluidName,plotType,fluidProps,satProps,supProps,panelData,hBlock)
    end

end




function ssc=extractParameters(hBlock)


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,'UniformOutput',false),...
    blockParams.Row);


    [u_min_val,u_max_val,unorm_liq_val,unorm_vap_val,p_TLU_val,...
    v_liq_val,v_vap_val,s_liq_val,s_vap_val,T_liq_val,T_vap_val,...
    nu_liq_val,nu_vap_val,k_liq_val,k_vap_val,Pr_liq_val,Pr_vap_val,...
    u_sat_liq_val,u_sat_vap_val,p_crit_val]=...
    fluids.internal.two_phase_fluid.utilities.TwoPhaseFluidPredefinedProperties.extractTables(value(ssc.fluid,'1'));
    ssc.u_min=simscape.Value(u_min_val,'kJ/kg');
    ssc.u_max=simscape.Value(u_max_val,'kJ/kg');
    ssc.unorm_liq=simscape.Value(unorm_liq_val,'1');
    ssc.unorm_vap=simscape.Value(unorm_vap_val,'1');
    ssc.p_TLU=simscape.Value(p_TLU_val,'MPa');
    ssc.v_liq=simscape.Value(v_liq_val,'m^3/kg');
    ssc.v_vap=simscape.Value(v_vap_val,'m^3/kg');
    ssc.s_liq=simscape.Value(s_liq_val,'kJ/kg/K');
    ssc.s_vap=simscape.Value(s_vap_val,'kJ/kg/K');
    ssc.T_liq=simscape.Value(T_liq_val,'K');
    ssc.T_vap=simscape.Value(T_vap_val,'K');
    ssc.nu_liq=simscape.Value(nu_liq_val,'mm^2/s');
    ssc.nu_vap=simscape.Value(nu_vap_val,'mm^2/s');
    ssc.k_liq=simscape.Value(k_liq_val,'W/(m*K)');
    ssc.k_vap=simscape.Value(k_vap_val,'W/(m*K)');
    ssc.Pr_liq=simscape.Value(Pr_liq_val,'1');
    ssc.Pr_vap=simscape.Value(Pr_vap_val,'1');
    ssc.u_sat_liq=simscape.Value(u_sat_liq_val,'kJ/kg');
    ssc.u_sat_vap=simscape.Value(u_sat_vap_val,'kJ/kg');
    ssc.p_crit=simscape.Value(p_crit_val,'MPa');


    ssc.unorm_liq_min=min(ssc.unorm_liq);
    ssc.unorm_liq_max=max(ssc.unorm_liq);
    ssc.unorm_vap_min=min(ssc.unorm_vap);
    ssc.unorm_vap_max=max(ssc.unorm_vap);
    ssc.p_TLU_min=min(ssc.p_TLU);
    ssc.p_TLU_max=max(ssc.p_TLU);

    ssc.m_liq=length(ssc.unorm_liq);
    ssc.m_vap=length(ssc.unorm_vap);
    ssc.n=length(ssc.p_TLU);
    ssc.n_sub=sum(double(ssc.p_TLU<ssc.p_crit));
    m_liq=ssc.m_liq;
    n=ssc.n;
    n_sub=ssc.n_sub;

    ssc.u_sat_liq_sub=ssc.u_sat_liq(1:n_sub);
    ssc.u_sat_vap_sub=ssc.u_sat_vap(1:n_sub);

    ssc.v_sat_liq_sup=ssc.v_liq(m_liq,n_sub+1:n);
    ssc.v_sat_vap_sup=ssc.v_vap(1,n_sub+1:n);
    ssc.s_sat_liq_sup=ssc.s_liq(m_liq,n_sub+1:n);
    ssc.s_sat_vap_sup=ssc.s_vap(1,n_sub+1:n);
    ssc.T_sat_liq_sup=ssc.T_liq(m_liq,n_sub+1:n);
    ssc.T_sat_vap_sup=ssc.T_vap(1,n_sub+1:n);
    ssc.nu_sat_liq_sup=ssc.nu_liq(m_liq,n_sub+1:n);
    ssc.nu_sat_vap_sup=ssc.nu_vap(1,n_sub+1:n);
    ssc.k_sat_liq_sup=ssc.k_liq(m_liq,n_sub+1:n);
    ssc.k_sat_vap_sup=ssc.k_vap(1,n_sub+1:n);
    ssc.Pr_sat_liq_sup=ssc.Pr_liq(m_liq,n_sub+1:n);
    ssc.Pr_sat_vap_sup=ssc.Pr_vap(1,n_sub+1:n);
    ssc.u_sat_liq_sup=ssc.u_sat_liq(n_sub+1:n);
    ssc.u_sat_vap_sup=ssc.u_sat_vap(n_sub+1:n);

end




function[fluidProps,satProps,supProps,panelData]=getFluidProperties(ssc)


    ssc.u_liq=(ssc.unorm_liq(:)+1)*(ssc.u_sat_liq(:)'-ssc.u_min(:)')+ssc.u_min(:)';
    ssc.u_vap=(ssc.unorm_vap(:)-2)*(ssc.u_max(:)'-ssc.u_sat_vap(:)')+ssc.u_max(:)';


    ssc.p_liq=repmat(ssc.p_TLU(:)',length(ssc.unorm_liq),1);
    ssc.p_vap=repmat(ssc.p_TLU(:)',length(ssc.unorm_vap),1);
    ssc.h_liq=ssc.u_liq+ssc.p_liq.*ssc.v_liq;
    ssc.h_vap=ssc.u_vap+ssc.p_vap.*ssc.v_vap;


    u_unit=chooseUnit(ssc.u_sat_liq,ssc.u_sat_vap,'kJ/kg');
    h_unit=u_unit;
    p_unit=unit(ssc.p_TLU);
    v_unit=chooseUnit(ssc.v_liq,ssc.v_vap,'m^3/kg');
    s_unit=chooseUnit(ssc.s_liq,ssc.s_vap,'kJ/(kg*K)');
    T_unit=chooseUnit(ssc.T_liq,ssc.T_vap,'K');
    nu_unit=chooseUnit(ssc.nu_liq,ssc.nu_vap,'mm^2/s');
    k_unit=chooseUnit(ssc.k_liq,ssc.k_vap,'W/(m*K)');
    Pr_unit='1';



    fluidProps={
    "Specific Internal Energy ("+string(u_unit)+")",value([ssc.u_liq;ssc.u_vap],u_unit);
    "Specific Enthalpy ("+string(h_unit)+")",value([ssc.h_liq;ssc.h_vap],h_unit);
    "Pressure ("+string(p_unit)+")",value([ssc.p_liq;ssc.p_vap],p_unit);
    "Specific Volume ("+string(v_unit)+")",value([ssc.v_liq;ssc.v_vap],v_unit);
    "Specific Entropy ("+string(s_unit)+")",value([ssc.s_liq;ssc.s_vap],s_unit);
    "Temperature ("+string(T_unit)+")",value([ssc.T_liq;ssc.T_vap],T_unit);
    "Kinematic Viscosity ("+string(nu_unit)+")",value([ssc.nu_liq;ssc.nu_vap],nu_unit);
    "Thermal Conductivity ("+string(k_unit)+")",value([ssc.k_liq;ssc.k_vap],k_unit);
    "Prandtl Number",value([ssc.Pr_liq;ssc.Pr_vap],Pr_unit);
    };


    n_sub=min(ssc.n_sub+1,ssc.n);
    satProps={
    value(ssc.u_sat_liq(1:n_sub),u_unit),value(ssc.u_sat_vap(1:n_sub),u_unit);
    value(ssc.h_liq(end,1:n_sub),h_unit),value(ssc.h_vap(1,1:n_sub),h_unit);
    value(ssc.p_TLU(1:n_sub),p_unit),value(ssc.p_TLU(1:n_sub),p_unit);
    value(ssc.v_liq(end,1:n_sub),v_unit),value(ssc.v_vap(1,1:n_sub),v_unit);
    value(ssc.s_liq(end,1:n_sub),s_unit),value(ssc.s_vap(1,1:n_sub),s_unit);
    value(ssc.T_liq(end,1:n_sub),T_unit),value(ssc.T_vap(1,1:n_sub),T_unit);
    value(ssc.nu_liq(end,1:n_sub),nu_unit),value(ssc.nu_vap(1,1:n_sub),nu_unit);
    value(ssc.k_liq(end,1:n_sub),k_unit),value(ssc.k_vap(1,1:n_sub),k_unit);
    value(ssc.Pr_liq(end,1:n_sub),Pr_unit),value(ssc.Pr_vap(1,1:n_sub),Pr_unit);
    };


    n_sub=ssc.n_sub;
    supProps={
    value(ssc.u_sat_liq_sup,u_unit);
    value(ssc.h_liq(end,n_sub+1:end),h_unit);
    value(ssc.p_TLU(n_sub+1:end),p_unit);
    value(ssc.v_sat_liq_sup,v_unit);
    value(ssc.s_sat_liq_sup,s_unit);
    value(ssc.T_sat_liq_sup,T_unit);
    value(ssc.nu_sat_liq_sup,nu_unit);
    value(ssc.k_sat_liq_sup,k_unit);
    value(ssc.Pr_sat_liq_sup,Pr_unit);
    };


    panelData={
    "Minimum pressure: "+value(ssc.p_TLU(1),p_unit)+" "+string(p_unit);
    "Maximum pressure: "+value(ssc.p_TLU(end),p_unit)+" "+string(p_unit);
    "Critical pressure: "+value(ssc.p_crit,p_unit)+" "+string(p_unit);
    };

end




function chosenUnit=chooseUnit(liq,vap,default)

    if unit(liq)==unit(vap)
        chosenUnit=unit(liq);
    else
        chosenUnit=simscape.Unit(default);
    end

end





function plotFluidProperties(varargin)


    narginchk(7,8)


    fluidName=varargin{1};
    plotType=varargin{2};
    fluidProps=varargin{3};
    satProps=varargin{4};
    supProps=varargin{5};
    panelData=varargin{6};
    hBlock=varargin{7};


    if nargin==8&&isgraphics(varargin{8},'figure')&&...
        strcmp(varargin{8}.Tag,'Two-Phase Fluid Properties (2P) - Plot Fluid Properties')

        hFigure=varargin{8};
        hFigure.Name=get_param(hBlock,'Name');


        hPmin=getappdata(hFigure,'hPmin');
        hPmax=getappdata(hFigure,'hPmax');
        hPcrit=getappdata(hFigure,'hPcrit');
        hPmin.String=panelData{1};
        hPmax.String=panelData{2};
        hPcrit.String=panelData{3};


        hPopup=getappdata(hFigure,'hPopup');
        hPopup.Callback=@plotProperties;


        hButton=getappdata(hFigure,'hButton');
        hButton.Callback=@(hObject,eventData)fluids.internal.mask.plot2PProperties(plotType,hBlock,hFigure);


        hRadio=getappdata(hFigure,'hRadio');
        hRadio.SelectionChangedFcn=@plotProperties;
    else


        hFigure=figure('Name',get_param(hBlock,'Name'),...
        'Toolbar','figure','Units','pixels',...
        'Tag','Two-Phase Fluid Properties (2P) - Plot Fluid Properties');


        hAxes=axes('Units','pixels');


        setappdata(hFigure,"blockPath",getfullname(hBlock));


        hPopup=uicontrol(hFigure,'Style','popupmenu',...
        'Units','normalized','Position',[0.3,0.95,0.4,0.05],...
        'String',fluidProps(4:end,1),'FontWeight','bold','FontSize',8,...
        'Value',3,'Callback',@plotProperties);

        hPopup.Units='pixels';
        heightPopup=hPopup.Position(4);
        setappdata(hFigure,'hPopup',hPopup)


        hButton=uicontrol(hFigure,'Style','pushbutton','backgroundColor',[1,1,1],...
        'Units','normalized','Position',[0.75,0.95,0.2,0.05],...
        'String','Reload Data','FontWeight','bold','FontSize',8,...
        'Callback',@(hObject,eventData)fluids.internal.mask.plot2PProperties(plotType,hBlock,hFigure));

        hButton.Units='pixels';
        heightButton=hButton.Position(4);
        setappdata(hFigure,'hButton',hButton)


        hRadio=uibuttongroup(hFigure,'BorderType','none',...
        'Units','normalized','Position',[0.04,0.9,0.25,0.1],...
        'SelectionChangedFcn',@plotProperties);
        uicontrol(hRadio,'Style','radiobutton',...
        'Units','normalized','Position',[0,0.5,1,0.5],...
        'String','Internal Energy Axis','FontSize',8,'UserData',1)
        uicontrol(hRadio,'Style','radiobutton',...
        'Units','normalized','Position',[0,0,1,0.5],...
        'String','Enthalpy Axis','FontSize',8,'UserData',2)

        hRadio.Units='pixels';
        heightRadio=hRadio.Position(4);
        setappdata(hFigure,'hRadio',hRadio)


        hPanel=uipanel(hFigure,'Units','normalized','Position',[0,0,1,0.1]);
        hPmin=uicontrol(hPanel,'Style','text',...
        'Units','normalized','Position',[0.01,0.5,0.48,0.45],...
        'string',panelData{1},'FontSize',10,'HorizontalAlignment','left');
        hPmax=uicontrol(hPanel,'Style','text',...
        'Units','normalized','Position',[0.01,0,0.48,0.45],...
        'string',panelData{2},'Fontsize',10,'HorizontalAlignment','left');
        hPcrit=uicontrol(hPanel,'Style','text',...
        'Units','normalized','Position',[0.51,0.5,0.48,0.45],...
        'string',panelData{3},'FontSize',10,'HorizontalAlignment','left');

        hPanel.Units='pixels';
        heightPanel=hPanel.Position(4);
        setappdata(hFigure,'hPmin',hPmin)
        setappdata(hFigure,'hPmax',hPmax)
        setappdata(hFigure,'hPcrit',hPcrit)


        addHeight=15+heightPanel;
        hFigure.Position=hFigure.Position+[0,-addHeight,0,addHeight];
        hPopup.Position=hPopup.Position+[0,addHeight,0,0];
        hButton.Position=hButton.Position+[0,addHeight,0,0];
        hRadio.Position=hRadio.Position+[0,addHeight,0,0];
        hAxes.Position=hAxes.Position+[0,heightPanel,0,0];
        hPopup.Units='normalized';
        hButton.Units='normalized';
        hRadio.Units='normalized';
        hAxes.Units='normalized';
        hPanel.Units='normalized';


        hFigure.SizeChangedFcn=@(hObject,eventData)maintainSize();
    end


plotProperties



    function maintainSize()

        hPanel.Units='pixels';
        hPanel.Position(2)=0;
        hPanel.Position(4)=45;
        hPanel.Units='normalized';

        hPopup.Units='pixels';
        yOld=hPopup.Position(2);
        heightOld=hPopup.Position(4);
        hPopup.Position(2)=yOld+heightOld-heightPopup;
        hPopup.Position(4)=heightPopup;
        hPopup.Units='normalized';

        hButton.Units='pixels';
        yOld=hButton.Position(2);
        heightOld=hButton.Position(4);
        hButton.Position(2)=yOld+heightOld-heightButton;
        hButton.Position(4)=heightButton;
        hButton.Units='normalized';

        hRadio.Units='pixels';
        yOld=hRadio.Position(2);
        heightOld=hRadio.Position(4);
        hRadio.Position(2)=yOld+heightOld-heightRadio;
        hRadio.Position(4)=heightRadio;
        hRadio.Units='normalized';
    end



    function plotProperties(~,~)

        iProps=hPopup.Value+3;
        iAxis=hRadio.SelectedObject.UserData;

        if strcmp(plotType,'3D')

            surf(fluidProps{iAxis,2},fluidProps{3,2},fluidProps{iProps,2},...
            'LineStyle','-','EdgeColor',[0.8,0.8,0.8],'LineWidth',0.5)


            hold on
            plot3(satProps{iAxis,1},satProps{3,1},satProps{iProps,1},'k-','LineWidth',2)
            plot3(satProps{iAxis,2},satProps{3,2},satProps{iProps,2},'k-','LineWidth',2)
            plot3(supProps{iAxis},supProps{3},supProps{iProps},'k--','LineWidth',2)
            hold off

            zlabel(fluidProps{iProps,1})
        else

            contour(fluidProps{iAxis,2},fluidProps{3,2},fluidProps{iProps,2},50)


            hold on
            plot(satProps{iAxis,1},satProps{3,1},'k-','LineWidth',1)
            plot(satProps{iAxis,2},satProps{3,2},'k-','LineWidth',1)
            plot(supProps{iAxis},supProps{3},'k--','LineWidth',1)
            hold off
        end


        set(gca,'Yscale','log')
        xlabel(fluidProps{iAxis,1})
        ylabel(fluidProps{3,1})
        title(fluidName)
    end

end