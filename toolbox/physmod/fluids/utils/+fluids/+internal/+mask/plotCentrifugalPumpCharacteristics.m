function plotCentrifugalPumpCharacteristics(varargin)










    narginchk(1,2)


    hBlock=varargin{1};
    if nargin==1
        hFigure=[];
    else
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        (string(get_param(hBlock,"ComponentPath"))~="fluids.isothermal_liquid.pumps_motors.centrifugal_pump"&&...
        string(get_param(hBlock,"ComponentPath"))~="fluids.thermal_liquid.pumps_motors.centrifugal_pump")


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Centrifugal Pump (IL) or Centrifugal Pump (TL) - Plot Pump Characteristics"
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                (string(get_param(hBlock,"ComponentPath"))~="fluids.isothermal_liquid.pumps_motors.centrifugal_pump"&&...
                string(get_param(hBlock,"ComponentPath"))~="fluids.thermal_liquid.pumps_motors.centrifugal_pump")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    [ssc,str]=extractParameters(hBlock);
    ssc=checkParameters(ssc,str);


    prepareFigure(hBlock,hFigure);


    plotPumpCurves(ssc)

end




function[ssc,str]=extractParameters(hBlock)


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,"UniformOutput",false),...
    blockParams.Row);



    str=cell2struct(blockParams.Prompt,blockParams.Row);


    if string(get_param(hBlock,"ComponentPath"))=="fluids.thermal_liquid.pumps_motors.centrifugal_pump"
        ssc.capacity_ref_1D_TLU=ssc.flow_rate_1D_TLU;
        str.capacity_ref_1D_TLU=str.flow_rate_1D_TLU;

        ssc.head_ref_1D_TLU=ssc.head_1D_TLU;
        str.head_ref_1D_TLU=str.head_1D_TLU;

        ssc.power_ref_1D_TLU=ssc.power_1D_TLU;
        str.power_ref_1D_TLU=str.power_1D_TLU;

        ssc.capacity_2D_TLU=ssc.flow_rate_2D_TLU;
        str.capacity_2D_TLU=str.flow_rate_2D_TLU;
    end

end




function[ssc,str]=checkParameters(ssc,str)


    if logical(ssc.pump_parameterization==1)


        ssc.capacity_ref_max_max=ssc.head_ref_max*ssc.capacity_ref_nominal...
        /(ssc.head_ref_max-ssc.head_ref_nominal);
        str.capacity_ref_max_max="(Maximum head at zero capacity) * (Nominal capacity) / ((Maximum head at zero capacity) - (Nominal head))";

        assertPattern(ssc.capacity_ref_nominal>0,"GreaterThanZero",str.capacity_ref_nominal)
        assertPattern(ssc.head_ref_nominal>0,"GreaterThanZero",str.head_ref_nominal)
        assertPattern(ssc.power_ref_nominal>0,"GreaterThanZero",str.power_ref_nominal)
        assertPattern(ssc.head_ref_max>ssc.head_ref_nominal,"GreaterThan",str.head_ref_max,str.head_ref_nominal)
        assertPattern(ssc.capacity_ref_max>ssc.capacity_ref_nominal,"GreaterThan",str.capacity_ref_max,str.capacity_ref_nominal)
        assertPattern(ssc.capacity_ref_max<=ssc.capacity_ref_max_max,"LessThanOrEqual",str.capacity_ref_max,str.capacity_ref_max_max)
        assertPattern(ssc.omega_ref_analytic>0,"GreaterThanZero",str.omega_ref_analytic)

    elseif logical(ssc.pump_parameterization==2)


        assertPattern(length(ssc.capacity_ref_1D_TLU)>=2,"LengthGreaterThanOrEqual",str.capacity_ref_1D_TLU,"2")
        assertPattern(length(ssc.head_ref_1D_TLU)==length(ssc.capacity_ref_1D_TLU),"LengthEqualLength",str.head_ref_1D_TLU,str.capacity_ref_1D_TLU)
        assertPattern(length(ssc.power_ref_1D_TLU)==length(ssc.capacity_ref_1D_TLU),"LengthEqualLength",str.power_ref_1D_TLU,str.capacity_ref_1D_TLU)

        assertPattern(all(diff(ssc.capacity_ref_1D_TLU)>0),"StrictlyAscendingVec",str.capacity_ref_1D_TLU)


        ssc.capacity_ref_1D_TLU_last=ssc.capacity_ref_1D_TLU(end);
        str.capacity_ref_1D_TLU_last="last element of Reference capacity vector";
        ssc.head_ref_1D_TLU_zero=simscape.Value(...
        interp1(value(ssc.capacity_ref_1D_TLU,"m^3/s"),value(ssc.head_ref_1D_TLU,"m"),0,"linear","extrap"),...
        "m^2");
        str.head_ref_1D_TLU_zero="Reference head vector interpolated at zero flow";
        ssc.power_ref_1D_TLU_zero=simscape.Value(...
        interp1(value(ssc.capacity_ref_1D_TLU,"m^3/s"),value(ssc.power_ref_1D_TLU,"W"),0,"linear","extrap"),...
        "W");
        str.power_ref_1D_TLU_zero="Reference brake power vector interpolated at zero flow";



        assertPattern(ssc.capacity_ref_1D_TLU_last>0,"GreaterThanZero",str.capacity_ref_1D_TLU_last)
        assertPattern(ssc.head_ref_1D_TLU_zero>0,"GreaterThanZero",str.head_ref_1D_TLU_zero)
        assertPattern(ssc.power_ref_1D_TLU_zero>0,"GreaterThanZero",str.power_ref_1D_TLU_zero)
        assert(logical(all((ssc.power_ref_1D_TLU(:)>0)>=(ssc.head_ref_1D_TLU(:)>0))),...
        message("physmod:fluids:library:CorrespondingElementsAlsoPositive",str.power_ref_1D_TLU,str.head_ref_1D_TLU))
        assertPattern(ssc.omega_ref_1D>0,"GreaterThanZero",str.omega_ref_1D)
        assertPattern(ssc.rho_ref_1D>0,"GreaterThanZero",str.rho_ref_1D)

    else


        assertPattern(length(ssc.capacity_2D_TLU)>=2,"LengthGreaterThanOrEqual",str.capacity_2D_TLU,"2")
        assertPattern(length(ssc.omega_2D_TLU)>=2,"LengthGreaterThanOrEqual",str.omega_2D_TLU,"2")
        assertPattern(all(size(ssc.head_2D_TLU)==[length(ssc.capacity_2D_TLU),length(ssc.omega_2D_TLU)]),"Size2DEqual",str.head_2D_TLU,str.capacity_2D_TLU,str.omega_2D_TLU)
        assertPattern(all(size(ssc.power_2D_TLU)==[length(ssc.capacity_2D_TLU),length(ssc.omega_2D_TLU)]),"Size2DEqual",str.power_2D_TLU,str.capacity_2D_TLU,str.omega_2D_TLU)

        assertPattern(all(diff(ssc.capacity_2D_TLU)>0),"StrictlyAscendingVec",str.capacity_2D_TLU)
        assertPattern(all(diff(ssc.omega_2D_TLU)>0),"StrictlyAscendingVec",str.omega_2D_TLU)

        assert(logical(all(isnan(ssc.head_2D_TLU(:))==isnan(ssc.power_2D_TLU(:)))),...
        message("physmod:fluids:library:NaNSamePositions",str.power_2D_TLU,str.head_2D_TLU))


        ssc.capacity_2D_TLU_last=ssc.capacity_2D_TLU(end);
        str.capacity_2D_TLU_last="last element of Capacity vector, q,";



        assertPattern(ssc.capacity_2D_TLU_last>0,"GreaterThanZero",str.capacity_2D_TLU_last)
        assertPattern(all(ssc.omega_2D_TLU(:)>0),"ArrayGreaterThanZero",str.omega_2D_TLU)
        assert(logical(all((ssc.power_2D_TLU(:)>0)>=(ssc.head_2D_TLU(:)>0))),...
        message("physmod:fluids:library:CorrespondingElementsAlsoPositive",str.power_2D_TLU,str.head_2D_TLU))
        assertPattern(ssc.rho_ref_2D>0,"GreaterThanZero",str.rho_ref_2D)


        ssc.torque_2D_TLU=ssc.power_2D_TLU./repmat(ssc.omega_2D_TLU(:)',size(ssc.power_2D_TLU,1),1);



        [omega_2D_TLU_ext_val,...
        capacity_2D_TLU_ext_val,...
        head_2D_TLU_ext_val,...
        torque_2D_TLU_ext_val,...
        head_2D_TLU_zero_val,...
        torque_2D_TLU_zero_val,...
        exitflag]...
        =fluids.internal.turbomachinery.extendCharacteristicCurves(...
        value(ssc.omega_2D_TLU,'rad/s'),...
        value(ssc.capacity_2D_TLU,'m^3/s'),...
        value(ssc.head_2D_TLU','m'),...
        value(ssc.torque_2D_TLU','N*m'));

        ssc.omega_2D_TLU_ext=simscape.Value(omega_2D_TLU_ext_val,'rad/s');
        ssc.capacity_2D_TLU_ext=simscape.Value(capacity_2D_TLU_ext_val,'m^3/s');
        ssc.head_2D_TLU_ext=simscape.Value(head_2D_TLU_ext_val','m');
        ssc.torque_2D_TLU_ext=simscape.Value(torque_2D_TLU_ext_val','N*m');


        ssc.head_2D_TLU_zero=simscape.Value(head_2D_TLU_zero_val,'Pa');
        str.head_2D_TLU_zero="Head table, H(q,w), interpolated at zero flow";
        ssc.power_2D_TLU_zero=simscape.Value(torque_2D_TLU_zero_val(:),'N*m').*ssc.omega_2D_TLU(:);
        str.power_2D_TLU_zero="Brake power table, Wb(q,w), interpolated at zero flow";


        assertPattern(all(ssc.head_2D_TLU_zero(:)>0),"ArrayGreaterThanZero",str.head_2D_TLU_zero)
        assertPattern(all(ssc.power_2D_TLU_zero(:)>0),"ArrayGreaterThanZero",str.power_2D_TLU_zero)

        assertPattern(all(diff(ssc.head_2D_TLU_zero)>0),"StrictlyAscendingVec",str.head_2D_TLU_zero)
        assertPattern(all(diff(ssc.power_2D_TLU_zero)>0),"StrictlyAscendingVec",str.power_2D_TLU_zero)

        if exitflag==-1
            assert(false,message('physmod:fluids:library:NonNaNInEachRow',str.head_2D_TLU))
        elseif exitflag==-2
            assert(false,message('physmod:fluids:library:NaNConsecutiveEndOfRow',str.head_2D_TLU))
        elseif exitflag==-3
            assert(false,message('physmod:fluids:library:DecreasingNumberOfNaN',str.head_2D_TLU))
        end
    end

    assertPattern(ssc.diameter_ratio>0,"GreaterThanZero",str.diameter_ratio)

end




function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function prepareFigure(hBlock,hFigure)

    if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
        string(hFigure.Tag)=="Centrifugal Pump (IL) or Centrifugal Pump (TL) - Plot Pump Characteristics"

        figure(hFigure)

        hButton=getappdata(hFigure,"hButton");
    else


        hFigure=figure("Tag","Centrifugal Pump (IL) or Centrifugal Pump (TL) - Plot Pump Characteristics");


        hButton=uicontrol(hFigure,"Style","pushbutton","backgroundColor",[1,1,1],...
        "Units","normalized","Position",[0.02,0.95,0.2,0.05],...
        "String","Reload Data","FontWeight","bold","FontSize",8);
        hButton.Units="pixels";

        setappdata(hFigure,"hButton",hButton)
    end


    setappdata(hFigure,"blockPath",getfullname(hBlock))


    hButton.Callback=@(hObject,eventData)fluids.internal.mask.plotCentrifugalPumpCharacteristics(hBlock,hFigure);


    hFigure.Name=get_param(hBlock,"Name");


    tiledlayout(hFigure,2,2,"TileSpacing","compact")
    nexttile;
    nexttile;
    nexttile;
    nexttile;


    leftMargin=hButton.Position(1);
    topMargin=hFigure.Position(4)-hButton.Position(2);

    hFigure.SizeChangedFcn=@(hObject,eventData)maintainSize(hObject,hButton,leftMargin,topMargin);

end




function maintainSize(hFigure,hButton,leftMargin,topMargin)

    hButton.Position(1)=leftMargin;
    hButton.Position(2)=hFigure.Position(4)-topMargin;

end




function plotPumpCurves(ssc)


    frac_ext=0.1;

    ssc.g=simscape.Value(9.81,"m/s^2");

    if logical(ssc.pump_parameterization==1)



        ssc.eta_rho_g_nominal=ssc.capacity_ref_nominal*ssc.head_ref_nominal/ssc.power_ref_nominal;



        c0=ssc.head_ref_max;
        c1=simscape.Value(0,"m/(m^3/s)");
        c2=(ssc.head_ref_nominal-ssc.head_ref_max)/ssc.capacity_ref_nominal^2;

        c3=ssc.capacity_ref_max*(2*ssc.head_ref_max*(ssc.capacity_ref_max-ssc.capacity_ref_nominal)-ssc.head_ref_nominal*ssc.capacity_ref_max)...
        /(ssc.capacity_ref_max-ssc.capacity_ref_nominal)^2;
        c4=2*(ssc.head_ref_max*ssc.capacity_ref_nominal^2-(ssc.head_ref_max-ssc.head_ref_nominal)*ssc.capacity_ref_max^2)...
        /ssc.capacity_ref_nominal/(ssc.capacity_ref_max-ssc.capacity_ref_nominal)^2;
        c5=((2*ssc.head_ref_max-ssc.head_ref_nominal)*(ssc.capacity_ref_max-ssc.capacity_ref_nominal)-ssc.head_ref_nominal*ssc.capacity_ref_max)...
        /ssc.capacity_ref_nominal/(ssc.capacity_ref_max-ssc.capacity_ref_nominal)^2;


        d0=ssc.capacity_ref_nominal^2*ssc.head_ref_max/ssc.eta_rho_g_nominal;
        d1=(ssc.head_ref_max-ssc.head_ref_nominal)/ssc.eta_rho_g_nominal;
        d2=(2*ssc.head_ref_max*(ssc.capacity_ref_max-ssc.capacity_ref_nominal)-ssc.head_ref_nominal*ssc.capacity_ref_max)*ssc.capacity_ref_nominal/(ssc.eta_rho_g_nominal*ssc.capacity_ref_nominal);
        d3=(ssc.head_ref_nominal*ssc.capacity_ref_max-(2*ssc.head_ref_max-ssc.head_ref_nominal)*(ssc.capacity_ref_max-ssc.capacity_ref_nominal))/(ssc.eta_rho_g_nominal*ssc.capacity_ref_nominal);
        d4=ssc.capacity_ref_max-2*ssc.capacity_ref_nominal;


        ssc.flow_rate_ref=linspace(-frac_ext*ssc.capacity_ref_max,(1+frac_ext)*ssc.capacity_ref_max,1000);




        ssc.head_ref=...
        logical(ssc.flow_rate_ref<0).*...
        (c0*ones(size(ssc.flow_rate_ref)))+...
        logical(ssc.flow_rate_ref>=0&ssc.flow_rate_ref<=ssc.capacity_ref_nominal).*...
        (c0+c1*ssc.flow_rate_ref+c2*ssc.flow_rate_ref.^2)+...
        logical(ssc.flow_rate_ref>ssc.capacity_ref_nominal&ssc.flow_rate_ref<=ssc.capacity_ref_max).*...
        (c3+c4*ssc.flow_rate_ref+c5*ssc.flow_rate_ref.^2)+...
        logical(ssc.flow_rate_ref>ssc.capacity_ref_max).*...
        (c4+2*c5*ssc.capacity_ref_max).*(ssc.flow_rate_ref-ssc.capacity_ref_max);



        ssc.power_ref=...
        logical(ssc.flow_rate_ref<0).*...
        (d0/(2*ssc.capacity_ref_nominal)*ones(size(ssc.flow_rate_ref)))+...
        logical(ssc.flow_rate_ref>=0&ssc.flow_rate_ref<=ssc.capacity_ref_nominal).*...
        (d0-d1*ssc.flow_rate_ref.^2)./(2*ssc.capacity_ref_nominal-ssc.flow_rate_ref)+...
        logical(ssc.flow_rate_ref>ssc.capacity_ref_nominal&ssc.flow_rate_ref<=ssc.capacity_ref_max).*...
        ssc.flow_rate_ref.*(d2+d3*ssc.flow_rate_ref)./(d4+ssc.flow_rate_ref)+...
        logical(ssc.flow_rate_ref>ssc.capacity_ref_max).*...
        (ssc.capacity_ref_max*(d2+d3*ssc.capacity_ref_max)/(d4+ssc.capacity_ref_max)*ones(size(ssc.flow_rate_ref)));


        ssc.torque_ref=ssc.power_ref/ssc.omega_ref_analytic;


        ssc.eta_rho_g_ref=...
        logical(ssc.flow_rate_ref<=ssc.capacity_ref_nominal).*...
        (ssc.eta_rho_g_nominal*ssc.flow_rate_ref.*(2*ssc.capacity_ref_nominal-ssc.flow_rate_ref))/ssc.capacity_ref_nominal^2+...
        logical(ssc.flow_rate_ref>ssc.capacity_ref_nominal).*...
        (ssc.eta_rho_g_nominal*(ssc.capacity_ref_max-ssc.flow_rate_ref).*(ssc.capacity_ref_max-2*ssc.capacity_ref_nominal+ssc.flow_rate_ref))/(ssc.capacity_ref_max-ssc.capacity_ref_nominal)^2;


        ssc.rho_dummy=simscape.Value(1000,"kg/m^3");
        ssc.eta_ref=ssc.eta_rho_g_ref*ssc.rho_dummy*ssc.g;


        ssc.eta_ref((ssc.flow_rate_ref<0)|(ssc.flow_rate_ref>ssc.capacity_ref_max))=NaN;


        ssc.flow_rate_ref_data=[0;ssc.capacity_ref_nominal;ssc.capacity_ref_max];
        ssc.head_ref_data=[ssc.head_ref_max;ssc.head_ref_nominal;0];
        ssc.power_ref_data=[simscape.Value(NaN,"W");ssc.power_ref_nominal;simscape.Value(NaN,"W")];


        q_unit=string(unit(ssc.capacity_ref_nominal));
        head_unit=string(unit(ssc.head_ref_nominal));
        power_unit=string(unit(ssc.power_ref_nominal));
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_ref_analytic));


        legend_str=string(num2str(value(ssc.omega_ref_analytic,omega_unit)))+" "+omega_unit;

    elseif logical(ssc.pump_parameterization==2)


        ssc.torque_ref_1D_TLU=ssc.power_ref_1D_TLU/ssc.omega_ref_1D;


        ssc.flow_rate_ref=[
        min(0,ssc.capacity_ref_1D_TLU(1)-frac_ext*(ssc.capacity_ref_1D_TLU(end)-ssc.capacity_ref_1D_TLU(1)));
        ssc.capacity_ref_1D_TLU(:);
        ssc.capacity_ref_1D_TLU(end)+frac_ext*(ssc.capacity_ref_1D_TLU(end)-ssc.capacity_ref_1D_TLU(1))];


        ssc.head_ref=ssc.head_ref_1D_TLU;

        ssc.head_ref=[
        max(ssc.head_ref_1D_TLU(1),(ssc.head_ref_1D_TLU(2)-ssc.head_ref_1D_TLU(1))/(ssc.capacity_ref_1D_TLU(2)-ssc.capacity_ref_1D_TLU(1))*(ssc.flow_rate_ref(1)-ssc.capacity_ref_1D_TLU(1))+ssc.head_ref_1D_TLU(1));
        ssc.head_ref_1D_TLU(:);
        min(ssc.head_ref_1D_TLU(end),(ssc.head_ref_1D_TLU(end-1)-ssc.head_ref_1D_TLU(end))/(ssc.capacity_ref_1D_TLU(end-1)-ssc.capacity_ref_1D_TLU(end))*(ssc.flow_rate_ref(end)-ssc.capacity_ref_1D_TLU(end))+ssc.head_ref_1D_TLU(end))];


        ssc.torque_ref=[
        ssc.torque_ref_1D_TLU(1);
        ssc.torque_ref_1D_TLU(:);
        ssc.torque_ref_1D_TLU(end)];


        ssc.power_ref=ssc.torque_ref*ssc.omega_ref_1D;


        ssc.eta_ref=ssc.flow_rate_ref.*ssc.head_ref*ssc.rho_ref_1D*ssc.g./ssc.power_ref;


        ssc.eta_ref(...
        (ssc.power_ref<=0)|...
        (ssc.flow_rate_ref<0)|...
        (ssc.flow_rate_ref>ssc.capacity_ref_1D_TLU(end))|...
        (ssc.head_ref<0))=NaN;


        ssc.flow_rate_ref_data=ssc.capacity_ref_1D_TLU(:);
        ssc.head_ref_data=ssc.head_ref_1D_TLU(:);
        ssc.power_ref_data=ssc.power_ref_1D_TLU(:);


        q_unit=string(unit(ssc.capacity_ref_1D_TLU));
        head_unit=string(unit(ssc.head_ref_1D_TLU));
        power_unit=string(unit(ssc.power_ref_1D_TLU));
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_ref_1D));


        legend_str=string(num2str(value(ssc.omega_ref_1D,omega_unit)))+" "+omega_unit;

    else


        ssc.flow_rate_ref=[
        min(0,ssc.capacity_2D_TLU(1)-frac_ext*(ssc.capacity_2D_TLU(end)-ssc.capacity_2D_TLU(1)));
        ssc.capacity_2D_TLU(:);
        ssc.capacity_2D_TLU(end)+frac_ext*(ssc.capacity_2D_TLU(end)-ssc.capacity_2D_TLU(1))];


        ssc.head_ref=[
        (ssc.head_2D_TLU_ext(2,3:end)-ssc.head_2D_TLU_ext(1,3:end))/(ssc.capacity_2D_TLU_ext(2)-ssc.capacity_2D_TLU_ext(1))*(ssc.flow_rate_ref(1)-ssc.capacity_2D_TLU_ext(1))+ssc.head_2D_TLU_ext(1,3:end);
        ssc.head_2D_TLU_ext(2:end-1,3:end);
        (ssc.head_2D_TLU_ext(end-1,3:end)-ssc.head_2D_TLU_ext(end,3:end))/(ssc.capacity_2D_TLU_ext(end-1)-ssc.capacity_2D_TLU_ext(end))*(ssc.flow_rate_ref(end)-ssc.capacity_2D_TLU_ext(end))+ssc.head_2D_TLU_ext(end,3:end)];


        ssc.torque_ref=[
        (ssc.torque_2D_TLU_ext(2,3:end)-ssc.torque_2D_TLU_ext(1,3:end))/(ssc.capacity_2D_TLU_ext(2)-ssc.capacity_2D_TLU_ext(1))*(ssc.flow_rate_ref(1)-ssc.capacity_2D_TLU_ext(1))+ssc.torque_2D_TLU_ext(1,3:end);
        ssc.torque_2D_TLU_ext(2:end-1,3:end);
        (ssc.torque_2D_TLU_ext(end-1,3:end)-ssc.torque_2D_TLU_ext(end,3:end))/(ssc.capacity_2D_TLU_ext(end-1)-ssc.capacity_2D_TLU_ext(end))*(ssc.flow_rate_ref(end)-ssc.capacity_2D_TLU_ext(end))+ssc.torque_2D_TLU_ext(end,3:end)];

        m=size(ssc.head_ref,1);
        n=size(ssc.head_ref,2);


        ssc.power_ref=ssc.torque_ref.*repmat(ssc.omega_2D_TLU(:)',m,1);


        ssc.eta_ref=repmat(ssc.flow_rate_ref(:),1,n).*ssc.head_ref*ssc.rho_ref_2D*ssc.g./ssc.power_ref;


        ssc.flow_rate_ref_data=ssc.capacity_2D_TLU(:);
        ssc.head_ref_data=ssc.head_2D_TLU;
        ssc.power_ref_data=ssc.power_2D_TLU;


        q_unit=string(unit(ssc.capacity_2D_TLU));
        head_unit=string(unit(ssc.head_2D_TLU));
        power_unit=string(unit(ssc.power_2D_TLU));
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_2D_TLU));


        legend_str=string(num2str(value(ssc.omega_2D_TLU(:),omega_unit)))+" "+omega_unit;
    end


    ssc.flow_rate=ssc.flow_rate_ref*ssc.diameter_ratio^3;
    ssc.flow_rate_data=ssc.flow_rate_ref_data*ssc.diameter_ratio^3;


    ssc.head=ssc.head_ref*ssc.diameter_ratio^2;
    ssc.head_data=ssc.head_ref_data*ssc.diameter_ratio^2;


    ssc.power=ssc.power_ref*ssc.diameter_ratio^5;
    ssc.power_data=ssc.power_ref_data*ssc.diameter_ratio^5;


    ssc.torque=ssc.torque_ref*ssc.diameter_ratio^5;


    ssc.eta=ssc.eta_ref;


    hAxis(1)=nexttile(1);
    plot(value(ssc.flow_rate,q_unit),value(ssc.head,head_unit),"-")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.flow_rate_data,q_unit),value(ssc.head_data,head_unit),"x")
    hold off
    grid on
    ylabel("Head ("+head_unit+")")


    hAxis(2)=nexttile(2);
    plot(value(ssc.flow_rate,q_unit),value(ssc.eta,"1"),"-")
    grid on
    set(gca,"YAxisLocation","right");
    ylabel("Efficiency")


    hAxis(3)=nexttile(3);
    plot(value(ssc.flow_rate,q_unit),value(ssc.power,power_unit),"-")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.flow_rate_data,q_unit),value(ssc.power_data,power_unit),"x")
    hold off
    grid on
    ylabel("Mechanical Power ("+power_unit+")")
    xlabel("Capacity ("+q_unit+")")


    hAxis(4)=nexttile(4);
    plot(value(ssc.flow_rate,q_unit),value(ssc.torque,torque_unit),"-")
    grid on
    set(gca,"YAxisLocation","right");
    ylabel("Shaft Torque ("+torque_unit+")")
    xlabel("Capacity ("+q_unit+")")

    linkaxes(hAxis,"x")

    if logical(ssc.pump_parameterization==1)

        nexttile(2)
        set(gca,"YTick",max(value(ssc.eta,"1")),"YTickLabel","max")
    end


    nexttile(2)
    legend(legend_str,"Location","best")

end