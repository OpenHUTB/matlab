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
        string(get_param(hBlock,"ComponentPath"))~="foundation.two_phase_fluid.utilities.two_phase_fluid_properties"


        if exist("hFigure","var")
            if isgraphics(hFigure,"figure")&&...
                string(hFigure.Tag)=="Two-Phase Fluid Properties (2P) - Plot Fluid Properties"
                blockPath=getappdata(hFigure,"blockPath");
                hBlock=getSimulinkBlockHandle(blockPath);


                if~is_simulink_handle(hBlock)||...
                    string(get_param(hBlock,"ComponentPath"))~="foundation.two_phase_fluid.utilities.two_phase_fluid_properties"
                    error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
                end
            else
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        end
    end


    [ssc,str]=extractParameters(hBlock);
    checkParameters(ssc,str)



    if logical(ssc.critical_region==foundation.enum.critical_region.clip)&&logical(ssc.p_TLU_max>ssc.p_crit)
        [k_liq_clip_val,k_vap_clip_val]=simscape.library.two_phase_fluid.clipCriticalRegion(...
        value(ssc.p_TLU,'MPa'),value(ssc.p_crit,'MPa'),value(ssc.p_crit_fraction,'1'),...
        value(ssc.k_liq,'W/(m*K)'),value(ssc.k_vap,'W/(m*K)'));
        ssc.k_liq=simscape.Value(k_liq_clip_val,'W/(m*K)');
        ssc.k_vap=simscape.Value(k_vap_clip_val,'W/(m*K)');

        [Pr_liq_clip_val,Pr_vap_clip_val]=simscape.library.two_phase_fluid.clipCriticalRegion(...
        value(ssc.p_TLU,'MPa'),value(ssc.p_crit,'MPa'),value(ssc.p_crit_fraction,'1'),...
        value(ssc.Pr_liq,'1'),value(ssc.Pr_vap,'1'));
        ssc.Pr_liq=simscape.Value(Pr_liq_clip_val,'1');
        ssc.Pr_vap=simscape.Value(Pr_vap_clip_val,'1');
    end


    [fluidProps,satProps,supProps]=getFluidProperties(ssc);


    if nargin==3
        plotFluidProperties(plotType,fluidProps,satProps,supProps,hBlock,hFigure)
    else
        plotFluidProperties(plotType,fluidProps,satProps,supProps,hBlock)
    end

end




function[ssc,str]=extractParameters(hBlock)


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,'UniformOutput',false),...
    blockParams.Row);


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


    msgfun=@(s)string(message("physmod:simscape:library:comments:two_phase_fluid:utilities:two_phase_fluid_properties:"+s));
    str=cell2struct(...
    cellfun(msgfun,fieldnames(ssc),'UniformOutput',false),...
    fieldnames(ssc));

end




function checkParameters(ssc,str)

    assertPattern(length(ssc.unorm_liq)>=3,"LengthGreaterThanOrEqual",str.unorm_liq,"3")
    assertPattern(length(ssc.unorm_vap)>=3,"LengthGreaterThanOrEqual",str.unorm_vap,"3")
    assertPattern(length(ssc.p_TLU)>=3,"LengthGreaterThanOrEqual",str.unorm_vap,"3")
    assertPattern(all(size(ssc.v_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.v_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.v_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.v_vap,str.unorm_vap,str.p_TLU)
    assertPattern(all(size(ssc.s_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.s_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.s_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.s_vap,str.unorm_vap,str.p_TLU)
    assertPattern(all(size(ssc.T_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.T_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.T_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.T_vap,str.unorm_vap,str.p_TLU)
    assertPattern(all(size(ssc.nu_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.nu_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.nu_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.nu_vap,str.unorm_vap,str.p_TLU)
    assertPattern(all(size(ssc.k_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.k_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.k_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.k_vap,str.unorm_vap,str.p_TLU)
    assertPattern(all(size(ssc.Pr_liq)==[length(ssc.unorm_liq),length(ssc.p_TLU)]),"Size2DEqual",str.Pr_liq,str.unorm_liq,str.p_TLU)
    assertPattern(all(size(ssc.Pr_vap)==[length(ssc.unorm_vap),length(ssc.p_TLU)]),"Size2DEqual",str.Pr_vap,str.unorm_vap,str.p_TLU)
    assertPattern(length(ssc.u_sat_liq)==length(ssc.p_TLU),"LengthEqualLength",str.u_sat_liq,str.p_TLU)
    assertPattern(length(ssc.u_sat_vap)==length(ssc.p_TLU),"LengthEqualLength",str.u_sat_vap,str.p_TLU)
    assertPattern(all(diff(ssc.unorm_liq)>0),"StrictlyAscendingVec",str.unorm_liq)
    assertPattern(all(diff(ssc.unorm_vap)>0),"StrictlyAscendingVec",str.unorm_vap)
    assertPattern(all(diff(ssc.p_TLU)>0),"StrictlyAscendingVec",str.p_TLU)
    assertPattern(ssc.unorm_liq_min==-1,"Equal",str.unorm_liq_min,"-1")
    assertPattern(ssc.unorm_liq_max==0,"EqualZero",str.unorm_liq_max)
    assertPattern(ssc.unorm_vap_min==1,"Equal",str.unorm_vap_min,"1")
    assertPattern(ssc.unorm_vap_max==2,"Equal",str.unorm_vap_max,"2")
    assertPattern(all(ssc.p_TLU(:)>0),"ArrayGreaterThanZero",str.p_TLU)
    assertPattern(all(ssc.v_liq(:)>0),"ArrayGreaterThanZero",str.v_liq)
    assertPattern(all(ssc.v_vap(:)>0),"ArrayGreaterThanZero",str.v_vap)
    assertPattern(all(ssc.T_liq(:)>0),"ArrayGreaterThanZero",str.T_liq)
    assertPattern(all(ssc.T_vap(:)>0),"ArrayGreaterThanZero",str.T_vap)
    assertPattern(all(ssc.nu_liq(:)>0),"ArrayGreaterThanZero",str.nu_liq)
    assertPattern(all(ssc.nu_vap(:)>0),"ArrayGreaterThanZero",str.nu_vap)
    assertPattern(all(ssc.k_liq(:)>0),"ArrayGreaterThanZero",str.k_liq)
    assertPattern(all(ssc.k_vap(:)>0),"ArrayGreaterThanZero",str.k_vap)
    assertPattern(all(ssc.Pr_liq(:)>0),"ArrayGreaterThanZero",str.Pr_liq)
    assertPattern(all(ssc.Pr_vap(:)>0),"ArrayGreaterThanZero",str.Pr_vap)
    assertPattern(all(ssc.u_sat_liq(:)>ssc.u_min),"ArrayGreaterThan",str.u_sat_liq,str.u_min)
    assertPattern(all(ssc.u_sat_vap(:)<ssc.u_max),"ArrayLessThan",str.u_sat_vap,str.u_max)
    assertPattern(all(ssc.u_sat_vap_sub(:)>ssc.u_sat_liq_sub(:)),"ArrayGreaterThanArray",str.u_sat_vap_sub,str.u_sat_liq_sub)
    if logical(ssc.n_sub<ssc.n)
        assertPattern(all(ssc.v_sat_liq_sup(:)==ssc.v_sat_vap_sup(:)),"ArrayEqualArray",str.v_sat_liq_sup,str.v_sat_vap_sup)
        assertPattern(all(ssc.s_sat_liq_sup(:)==ssc.s_sat_vap_sup(:)),"ArrayEqualArray",str.s_sat_liq_sup,str.s_sat_vap_sup)
        assertPattern(all(ssc.T_sat_liq_sup(:)==ssc.T_sat_vap_sup(:)),"ArrayEqualArray",str.T_sat_liq_sup,str.T_sat_vap_sup)
        assertPattern(all(ssc.nu_sat_liq_sup(:)==ssc.nu_sat_vap_sup(:)),"ArrayEqualArray",str.nu_sat_liq_sup,str.nu_sat_vap_sup)
        assertPattern(all(ssc.k_sat_liq_sup(:)==ssc.k_sat_vap_sup(:)),"ArrayEqualArray",str.k_sat_liq_sup,str.k_sat_vap_sup)
        assertPattern(all(ssc.Pr_sat_liq_sup(:)==ssc.Pr_sat_vap_sup(:)),"ArrayEqualArray",str.Pr_sat_liq_sup,str.Pr_sat_vap_sup)
        assertPattern(all(ssc.u_sat_liq_sup(:)==ssc.u_sat_vap_sup(:)),"ArrayEqualArray",str.u_sat_liq_sup,str.u_sat_vap_sup)
    end
    assertPattern(ssc.p_TLU_min<ssc.p_crit,"LessThan",str.p_TLU_min,str.p_crit)
    if logical(ssc.critical_region==foundation.enum.critical_region.clip)
        assertPattern(ssc.p_crit_fraction>0,'GreaterThanZero',str.p_crit_fraction)
    end








end




function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function[fluidProps,satProps,supProps]=getFluidProperties(ssc)


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

end




function chosenUnit=chooseUnit(liq,vap,default)

    if unit(liq)==unit(vap)
        chosenUnit=unit(liq);
    else
        chosenUnit=simscape.Unit(default);
    end

end





function plotFluidProperties(varargin)


    narginchk(5,6)


    plotType=varargin{1};
    fluidProps=varargin{2};
    satProps=varargin{3};
    supProps=varargin{4};
    hBlock=varargin{5};


    if nargin==6&&isgraphics(varargin{6},'figure')&&...
        strcmp(varargin{6}.Tag,'Two-Phase Fluid Properties (2P) - Plot Fluid Properties')

        hFigure=varargin{6};
        hFigure.Name=get_param(hBlock,'Name');


        hPopup=getappdata(hFigure,'hPopup');
        hPopup.Callback=@plotProperties;


        hButton=getappdata(hFigure,'hButton');
        hButton.Callback=@(hObject,eventData)foundation.internal.mask.plot2PProperties(plotType,hBlock,hFigure);


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
        'Callback',@(hObject,eventData)foundation.internal.mask.plot2PProperties(plotType,hBlock,hFigure));

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


        addHeight=15;
        hFigure.Position=hFigure.Position+[0,-addHeight,0,addHeight];
        hPopup.Position=hPopup.Position+[0,addHeight,0,0];
        hButton.Position=hButton.Position+[0,addHeight,0,0];
        hRadio.Position=hRadio.Position+[0,addHeight,0,0];
        hAxes.Units='normalized';
        hPopup.Units='normalized';
        hButton.Units='normalized';
        hRadio.Units='normalized';


        hFigure.SizeChangedFcn=@(hObject,eventData)maintainSize();
    end


plotProperties



    function maintainSize()

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
    end

end