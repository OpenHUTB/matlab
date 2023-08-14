function plotTXVQuadrantDiagram(varargin)










    narginchk(1,3)


    hBlock=varargin{1};
    if nargin>=2
        hFigure=varargin{2};
    else
        hFigure=[];
    end
    if nargin>=3
        props=varargin{3};
    else
        props.hPropBlock=-1;
        props.propBlockPath="";
        props.foundationPropPath="foundation.two_phase_fluid.utilities.two_phase_fluid_properties";
        props.fluidsPropPath="fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties";
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        (string(get_param(hBlock,"ComponentPath"))~="fluids.two_phase_fluid.valves_orifices.flow_control_valves.thermostatic_expansion_valve")


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            (string(hFigure.Tag)=="Thermostatic Expansion valve (2P) - Plot 4-Quadrant Diagram")
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                (string(get_param(hBlock,"ComponentPath"))~="fluids.two_phase_fluid.valves_orifices.flow_control_valves.thermostatic_expansion_valve")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    props=validatePropBlock(props,hBlock);


    if props.hPropBlock==-1
        props=selectFluidsDialog(hBlock,props);
    end


    props=getFluidProperties(props);


    [ssc,str,T_unit_orig]=extractParameters(hBlock);
    ssc=checkParameters(ssc,str,props);


    prepareFigure(hBlock,hFigure,props);


    plotQuadrantDiagram(ssc,props,T_unit_orig)

end




function props=validatePropBlock(props,hBlock)


    if props.hPropBlock==-1
        props.propBlockPath="";
        return
    end

    try %#ok<TRYNC>

        if strcmp(get_param(props.hPropBlock,"Commented"),"off")&&...
            (strcmp(get_param(props.hPropBlock,"ComponentPath"),props.fluidsPropPath)||...
            strcmp(get_param(props.hPropBlock,"ComponentPath"),props.foundationPropPath))

            props.propBlockPath=getPropBlockPath(props.hPropBlock);
            return
        end
    end


    modelName=string(get_param(bdroot(hBlock),"Name"));
    hPropBlockCheck=getSimulinkBlockHandle(modelName+"/"+props.propBlockPath,true);


    if(hPropBlockCheck~=-1)&&strcmp(get_param(hPropBlockCheck,"Commented"),"off")&&...
        (strcmp(get_param(hPropBlockCheck,"ComponentPath"),props.fluidsPropPath)||...
        strcmp(get_param(hPropBlockCheck,"ComponentPath"),props.foundationPropPath))

        props.hPropBlock=hPropBlockCheck;
        return
    end


    props.hPropBlock=-1;
    props.propBlockPath="";

end




function propBlockPath=getPropBlockPath(hBlock,hPropBlock)


    modelName=string(get_param(bdroot(hBlock),"Name"));
    tmpPropBlockPath=string(getfullname(hPropBlock));
    propBlockPath=regexprep(extractAfter(tmpPropBlockPath,modelName+"/"),"\s+"," ");

end




function props=selectFluidsDialog(hBlock,props)


    propBlockSearchList=find_system(bdroot(hBlock),...
    "LookUnderMasks","all","MatchFilter",@Simulink.match.allVariants,"RegExp","on",...
    "ComponentPath",props.fluidsPropPath+"|"+props.foundationPropPath);

    if isempty(propBlockSearchList)

        props.hPropBlock=-1;
        props.propBlockPath="";
        return
    end


    hPropList=get_param(propBlockSearchList,"Handle");
    if iscell(hPropList)
        hPropList=cell2mat(hPropList);
    end


    propBlockPathList=getPropBlockPath(hBlock,hPropList);

    if numel(hPropList)==1

        props.hPropBlock=hPropList;
        props.propBlockPath=propBlockPathList;
        return
    end


    idx=listdlg("ListString",propBlockPathList,...
    "Name","Select Fluid Properties",...
    "PromptString",...
"Select a Two-Phase Fluid Properties (2P) or Two-Phase Fluid Predefined Properties (2P)"...
    +newline+"block in the model",...
    "ListSize",[500,200],"SelectionMode","single");

    if isempty(idx)

        props.hPropBlock=-1;
        props.propBlockPath="";
    else

        props.hPropBlock=hPropList(idx);
        props.propBlockPath=propBlockPathList(idx);
    end

end




function props=getFluidProperties(props)

    blk=props.hPropBlock;


    if blk==-1||string(get_param(blk,"ComponentPath"))==props.foundationPropPath
        if blk==-1


            load_system("fl_lib")
            blk=getSimulinkBlockHandle("fl_lib/Two-Phase Fluid/Utilities/Two-Phase Fluid Properties (2P)",true);
            props.fluidName="Default water";
        else
            props.fluidName="Custom fluid";
        end


        paramList=["u_min","u_max","unorm_liq","unorm_vap","p_TLU",...
        "v_liq","v_vap","T_liq","T_vap","u_sat_liq","u_sat_vap","p_crit"];
        n=length(paramList);


        Simulink.Block.eval(blk)
        maskWS=get_param(blk,"MaskWSVariables");
        [~,~,idx]=intersect([paramList,paramList+"_unit"],{maskWS.Name},"stable");
        maskWSValues={maskWS(idx).Value};


        props.u_min=getSimscapeValue(maskWSValues{1},maskWSValues{1+n});
        props.u_max=getSimscapeValue(maskWSValues{2},maskWSValues{2+n});
        props.unorm_liq=getSimscapeValue(maskWSValues{3},maskWSValues{3+n});
        props.unorm_vap=getSimscapeValue(maskWSValues{4},maskWSValues{4+n});
        props.p_TLU=getSimscapeValue(maskWSValues{5},maskWSValues{5+n});
        props.v_liq=getSimscapeValue(maskWSValues{6},maskWSValues{6+n});
        props.v_vap=getSimscapeValue(maskWSValues{7},maskWSValues{7+n});
        props.T_liq=getSimscapeValue(maskWSValues{8},maskWSValues{8+n});
        props.T_vap=getSimscapeValue(maskWSValues{9},maskWSValues{9+n});
        props.u_sat_liq=getSimscapeValue(maskWSValues{10},maskWSValues{10+n});
        props.u_sat_vap=getSimscapeValue(maskWSValues{11},maskWSValues{11+n});
        props.p_crit=getSimscapeValue(maskWSValues{12},maskWSValues{12+n});
    else

        fluidEnum=eval(get_param(blk,"fluid"));


        fluidNameMap=fluids.two_phase_fluid.utilities.enum.Fluid.displayText;
        [~,fluidCellStr]=enumeration("fluids.two_phase_fluid.utilities.enum.Fluid");
        props.fluidName=fluidNameMap(fluidCellStr{fluidEnum});


        [u_min_val,u_max_val,unorm_liq_val,unorm_vap_val,p_TLU_val,...
        v_liq_val,v_vap_val,~,~,T_liq_val,T_vap_val,...
        ~,~,~,~,~,~,...
        u_sat_liq_val,u_sat_vap_val,p_crit_val]=...
        fluids.internal.two_phase_fluid.utilities.TwoPhaseFluidPredefinedProperties.extractTables(fluidEnum);
        props.u_min=simscape.Value(u_min_val,"kJ/kg");
        props.u_max=simscape.Value(u_max_val,"kJ/kg");
        props.unorm_liq=simscape.Value(unorm_liq_val,"1");
        props.unorm_vap=simscape.Value(unorm_vap_val,"1");
        props.p_TLU=simscape.Value(p_TLU_val,"MPa");
        props.v_liq=simscape.Value(v_liq_val,"m^3/kg");
        props.v_vap=simscape.Value(v_vap_val,"m^3/kg");
        props.T_liq=simscape.Value(T_liq_val,"K");
        props.T_vap=simscape.Value(T_vap_val,"K");
        props.u_sat_liq=simscape.Value(u_sat_liq_val,"kJ/kg");
        props.u_sat_vap=simscape.Value(u_sat_vap_val,"kJ/kg");
        props.p_crit=simscape.Value(p_crit_val,"MPa");
    end


    props.T_liq=convert(props.T_liq,"K");
    props.T_vap=convert(props.T_vap,"K");


    props.p_min=props.p_TLU(1);
    props.T_sat_liq=props.T_liq(end,:);
    props.T_sat_vap=props.T_vap(1,:);

end




function ssc=getSimscapeValue(maskWSValue,maskWSUnit)

    if isa(maskWSValue,"Simulink.Parameter")

        value=maskWSValue.Value;
    else
        value=maskWSValue;
    end

    if isempty(value)

        throw(MException(message("physmod:fluids:diagrams:UnrecognizedVariables")))
    end

    if isempty(maskWSUnit)

        unit="1";
    else
        unit=maskWSUnit;
    end


    ssc=simscape.Value(value,unit);

end




function[ssc,str,T_unit_orig]=extractParameters(hBlock)


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,"UniformOutput",false),...
    blockParams.Row);



    str=cell2struct(blockParams.Prompt,blockParams.Row);


    if ssc.valve_parameterization==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveParameterization.Nominal
        T_unit_orig=string(unit(ssc.T_evap_nominal));
    else
        T_unit_orig=string(unit(ssc.T_evap_out_TLU1));
    end


    ssc.T_cond_nominal=convert(ssc.T_cond_nominal,"K");
    ssc.T_evap_nominal=convert(ssc.T_evap_nominal,"K");
    ssc.delta_T_sub=convert(ssc.delta_T_sub,"deltaK","linear");
    ssc.delta_T_nominal=convert(ssc.delta_T_nominal,"deltaK","linear");
    ssc.delta_T_static=convert(ssc.delta_T_static,"deltaK","linear");
    ssc.T_mop=convert(ssc.T_mop,"K");
    ssc.T_evap_out_TLU1=convert(ssc.T_evap_out_TLU1,"K");
    ssc.T_evap_out_ref=convert(ssc.T_evap_out_ref,"K");
    ssc.delta_T_sub_ref=convert(ssc.delta_T_sub_ref,"deltaK","linear");

end




function ssc=checkParameters(ssc,str,props)

    if ssc.valve_parameterization==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveParameterization.Nominal

        assertPattern(ssc.delta_T_static>=0,"GreaterThanOrEqualZero",str.delta_T_static)
        assertPattern(ssc.delta_T_nominal>ssc.delta_T_static,"GreaterThan",str.delta_T_nominal,str.delta_T_static)
        assertPattern(ssc.delta_T_sub>=0,"GreaterThanOrEqualZero",str.delta_T_sub)
        assertPattern(ssc.mdot_leak_fraction>0,"GreaterThanZero",str.mdot_leak_fraction)
        assertPattern(ssc.mdot_leak_fraction<1,"LessThan",str.mdot_leak_fraction,"1")



        if ssc.capacity_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveCapacitySpec.HeatTransfer

            assertPattern(ssc.Q_nominal>0,"GreaterThanZero",str.Q_nominal)
            assertPattern(ssc.Q_max>ssc.Q_nominal,"GreaterThan",str.Q_max,str.Q_nominal)

        else

            assertPattern(ssc.mdot_nominal>0,"GreaterThanZero",str.mdot_nominal)
            assertPattern(ssc.mdot_max>ssc.mdot_nominal,"GreaterThan",str.mdot_max,str.mdot_nominal)
        end

        if ssc.pressure_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValvePressureSpec.Pressure


            ssc.p_cond=ssc.p_cond_nominal;
            str.p_cond="Nominal condenser outlet pressure";
            ssc.p_evap=ssc.p_evap_nominal;
            str.p_evap="Nominal evaporator outlet pressure";

            ssc.T_cond=sscInterp1(props.p_TLU,props.T_sat_liq,ssc.p_cond_nominal,"nearest");
            str.T_cond="Nominal condensing (saturation) temperature";
            ssc.T_evap=sscInterp1(props.p_TLU,props.T_sat_vap,ssc.p_evap_nominal,"nearest");
            str.T_evap="Nominal evaporating (saturation) temperature";

            assertPattern(ssc.p_evap_nominal>=props.p_min,"GreaterThanOrEqual",str.p_evap_nominal,"Minimum valid pressure")
            assertPattern(ssc.p_cond_nominal>ssc.p_evap_nominal,"GreaterThan",str.p_cond_nominal,str.p_evap_nominal)
            assertPattern(ssc.p_cond_nominal<props.p_crit,"LessThan",str.p_cond_nominal,"Critical pressure")

        else


            ssc.p_cond=sscInterp1(props.T_sat_liq,props.p_TLU,ssc.T_cond_nominal,"nearest");
            str.p_cond="Nominal condenser outlet pressure";
            ssc.p_evap=sscInterp1(props.T_sat_vap,props.p_TLU,ssc.T_evap_nominal,"nearest");
            str.p_evap="Nominal evaporator outlet pressure";

            ssc.T_cond=ssc.T_cond_nominal;
            str.T_cond="Nominal condensing (saturation) temperature";
            ssc.T_evap=ssc.T_evap_nominal;
            str.T_evap="Nominal evaporating (saturation) temperature";


            ssc.T_sat_liq_max=sscInterp1(props.p_TLU,props.T_sat_liq,props.p_crit,"nearest");
            str.T_sat_liq_max="Critical temperature";
            ssc.T_sat_liq_min=props.T_sat_liq(1);
            str.T_sat_liq_min="Minimum saturated liquid temperature";

            ssc.T_sat_vap_max=sscInterp1(props.p_TLU,props.T_sat_vap,props.p_crit,"nearest");
            str.T_sat_vap_max="Critical temperature";
            ssc.T_sat_vap_min=props.T_sat_vap(1);
            str.T_sat_vap_min="Minimum saturated vapor temperature";

            assertPattern(ssc.T_evap_nominal>=ssc.T_sat_vap_min,"GreaterThanOrEqual",str.T_evap_nominal,str.T_sat_vap_min)
            assertPattern(ssc.T_evap_nominal<ssc.T_sat_vap_max,"LessThan",str.T_evap_nominal,str.T_sat_vap_max)
            assertPattern(ssc.T_cond_nominal>=ssc.T_sat_liq_min,"GreaterThanOrEqual",str.T_cond_nominal,str.T_sat_liq_min)
            assertPattern(ssc.T_cond_nominal<ssc.T_sat_liq_max,"LessThan",str.T_cond_nominal,str.T_sat_liq_max)
            assertPattern(ssc.T_cond_nominal>ssc.T_evap,"GreaterThan",str.T_cond_nominal,str.T_evap)

        end

        if ssc.mop==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveMOP.Pressure


            ssc.p_evap_mop=ssc.p_mop;
            ssc.T_evap_mop=sscInterp1(props.p_TLU,props.T_sat_vap,ssc.p_mop,"nearest");

            assertPattern(ssc.p_mop>ssc.p_evap,"GreaterThan",str.p_mop,str.p_evap)

        elseif ssc.mop==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveMOP.Temperature


            ssc.p_evap_mop=sscInterp1(props.T_sat_vap,props.p_TLU,ssc.T_mop,"nearest");
            ssc.T_evap_mop=ssc.T_mop;

            assertPattern(ssc.T_mop>ssc.T_evap,"GreaterThan",str.T_mop,str.T_evap)
        end

    else


        assertPattern(numel(ssc.T_evap_out_TLU1)>=2,"LengthGreaterThanOrEqual",str.T_evap_out_TLU1,"2")
        assertPattern(numel(ssc.T_evap_out_TLU1)==numel(ssc.p_bulb_TLU1),"LengthEqualLength",str.T_evap_out_TLU1,str.p_bulb_TLU1)
        assertPattern(numel(ssc.lift_TLU2)>=2,"LengthGreaterThanOrEqual",str.lift_TLU2,"2")
        assertPattern(numel(ssc.lift_TLU2)==numel(ssc.p_evap_TLU2),"LengthEqualLength",str.lift_TLU2,str.p_evap_TLU2)
        assertPattern(numel(ssc.lift_TLU3)>=2,"LengthGreaterThanOrEqual",str.lift_TLU3,"2")
        assertPattern(numel(ssc.lift_TLU3)==numel(ssc.mdot_TLU3),"LengthEqualLength",str.lift_TLU3,str.mdot_TLU3)

        assertPattern(all(diff(ssc.T_evap_out_TLU1)>0),"StrictlyAscendingVec",str.T_evap_out_TLU1)
        assertPattern(all(diff(ssc.p_bulb_TLU1)>0),"StrictlyAscendingVec",str.p_bulb_TLU1)
        assertPattern(all(diff(ssc.lift_TLU2)>0),"StrictlyAscendingVec",str.lift_TLU2)
        assertPattern(all(diff(ssc.p_evap_TLU2)<0),"StrictlyDescendingVec",str.p_evap_TLU2)
        assertPattern(all(diff(ssc.lift_TLU3)>0),"StrictlyAscendingVec",str.lift_TLU3)
        assertPattern(all(diff(ssc.mdot_TLU3)>0),"StrictlyAscendingVec",str.mdot_TLU3)

        assertPattern(all(ssc.T_evap_out_TLU1(:)>0),"ArrayGreaterThanZero",str.T_evap_out_TLU1)
        assertPattern(all(ssc.p_bulb_TLU1(:)>0),"ArrayGreaterThanZero",str.p_bulb_TLU1)
        assertPattern(all(ssc.p_evap_TLU2(:)>0),"ArrayGreaterThanZero",str.p_evap_TLU2)
        assertPattern(all(ssc.mdot_TLU3(:)>0),"ArrayGreaterThanZero",str.mdot_TLU3)
        assertPattern(ssc.p_evap_ref>=props.p_min,"GreaterThanOrEqual",str.p_evap_ref,"Minimum valid pressure")
        assertPattern(ssc.p_cond_ref>ssc.p_evap_ref,"GreaterThan",str.p_cond_ref,str.p_evap_ref)
        assertPattern(ssc.p_cond_ref<props.p_crit,"LessThan",str.p_cond_ref,"Critical pressure")
        assertPattern(ssc.T_evap_out_ref>0,"GreaterThanZero",str.T_evap_out_ref)
        assertPattern(ssc.delta_T_sub_ref>=0,"GreaterThanOrEqualZero",str.delta_T_sub_ref)
    end


    assertPattern(ssc.B_lam>0,"GreaterThanZero",str.B_lam)
    assertPattern(ssc.B_lam<1,"LessThan",str.B_lam,"1")


end




function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function prepareFigure(hBlock,hFigure,props)

    if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
        string(hFigure.Tag)=="Thermostatic Expansion valve (2P) - Plot 4-Quadrant Diagram"

        figure(hFigure)

        hButton=getappdata(hFigure,"hButton");
    else


        hFigure=figure("Tag","Thermostatic Expansion valve (2P) - Plot 4-Quadrant Diagram");


        hButton=uicontrol(hFigure,"Style","pushbutton","backgroundColor",[1,1,1],...
        "Units","normalized","Position",[0.02,0.95,0.2,0.05],...
        "String","Reload Data","FontWeight","bold","FontSize",8);
        hButton.Units="pixels";

        setappdata(hFigure,"hButton",hButton)
    end


    setappdata(hFigure,"blockPath",getfullname(hBlock))


    hButton.Callback=@(hObject,eventData)fluids.internal.mask.plotTXVQuadrantDiagram(hBlock,hFigure,props);


    hFigure.Name=get_param(hBlock,"Name");


    tiledlayout(hFigure,2,2,"TileSpacing","tight","Padding","compact");
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




function plotQuadrantDiagram(ssc,props,T_unit_orig)

    function residual=solveQmax(delta_T_max)

        ssc.delta_T_max=simscape.Value(delta_T_max,"deltaK");


        ssc.p_bulb_max=sscInterp1(ssc.T_sat_bulb_TLU,ssc.p_bulb_TLU,ssc.T_evap+ssc.delta_T_max,"nearest");

        ssc.delta_p_max=ssc.p_bulb_max-ssc.p_evap;

        ssc.effective_area_max=ssc.beta*(ssc.delta_p_max-ssc.delta_p_static)+ssc.effective_area_min;

        ssc.mdot_max_used=ssc.effective_area_max*sqrt(2)*ssc.sqrt_rho_p_diff_nominal;


        ssc.unorm_evap_out_max=sscInterp1(ssc.T_evap_out_TLU,props.unorm_vap,ssc.T_evap+ssc.delta_T_max,"nearest");

        ssc.u_evap_out_max=(ssc.unorm_evap_out_max-2)*(props.u_max-ssc.u_sat_vap_evap)+props.u_max;

        ssc.v_evap_out_max=sscInterp2(props.unorm_vap,props.p_TLU,props.v_vap,ssc.unorm_evap_out_max,ssc.p_evap,"nearest");

        ssc.h_evap_out_max=ssc.u_evap_out_max+ssc.p_evap*ssc.v_evap_out_max;

        ssc.delta_h_max=ssc.h_evap_out_max-ssc.h_cond_out;

        residual=value(ssc.Q_max-ssc.mdot_max_used*ssc.delta_h_max,unit(ssc.Q_max));
    end


    N=100;

    if ssc.valve_parameterization==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveParameterization.Nominal


        ssc.T_cond_out_TLU=sscInterp2(props.unorm_liq,props.p_TLU,props.T_liq,props.unorm_liq,ssc.p_cond,"nearest");

        ssc.unorm_cond_out=sscInterp1(ssc.T_cond_out_TLU,props.unorm_liq,ssc.T_cond-ssc.delta_T_sub,"nearest");

        ssc.u_sat_liq_cond=sscInterp1(props.p_TLU,props.u_sat_liq,ssc.p_cond,"nearest");
        ssc.u_cond_out=(ssc.unorm_cond_out+1)*(ssc.u_sat_liq_cond-props.u_min)+props.u_min;

        ssc.v_cond_out=sscInterp2(props.unorm_liq,props.p_TLU,props.v_liq,ssc.unorm_cond_out,ssc.p_cond,"nearest");

        ssc.h_cond_out=ssc.u_cond_out+ssc.p_cond*ssc.v_cond_out;


        ssc.v_evap_in_TLU=sscInterp2([props.unorm_liq(:);props.unorm_vap(:)],props.p_TLU,[props.v_liq;props.v_vap],[props.unorm_liq(:);props.unorm_vap(:)],ssc.p_evap,"nearest");

        ssc.u_sat_liq_evap=sscInterp1(props.p_TLU,props.u_sat_liq,ssc.p_evap,"nearest");
        ssc.u_sat_vap_evap=sscInterp1(props.p_TLU,props.u_sat_vap,ssc.p_evap,"nearest");

        ssc.h_evap_in_TLU=ssc.p_evap*ssc.v_evap_in_TLU(:)+[
        (props.unorm_liq(:)+1)*(ssc.u_sat_liq_evap-props.u_min)+props.u_min;
        (props.unorm_vap(:)-2)*(props.u_max-ssc.u_sat_vap_evap)+props.u_max];

        ssc.h_evap_in=ssc.h_cond_out;

        ssc.v_evap_in=sscInterp1(ssc.h_evap_in_TLU,ssc.v_evap_in_TLU,ssc.h_evap_in,"nearest");


        ssc.p_avg_nominal=(ssc.p_cond+ssc.p_evap)/2;
        ssc.p_diff_lam_nominal=ssc.p_avg_nominal*(1-ssc.B_lam);


        ssc.p_diff_nominal=ssc.p_cond-ssc.p_evap;
        ssc.v_avg_nominal=(ssc.v_cond_out+ssc.v_evap_in)/2;
        ssc.sqrt_rho_p_diff_nominal=ssc.p_diff_nominal/((ssc.p_diff_nominal*ssc.v_cond_out)^2+(ssc.p_diff_lam_nominal*ssc.v_avg_nominal)^2)^0.25;

        if ssc.capacity_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveCapacitySpec.HeatTransfer

            ssc.T_evap_out_TLU=sscInterp2(props.unorm_vap,props.p_TLU,props.T_vap,props.unorm_vap,ssc.p_evap,"nearest");

            ssc.unorm_evap_out=sscInterp1(ssc.T_evap_out_TLU,props.unorm_vap,ssc.T_evap+ssc.delta_T_nominal,"nearest");

            ssc.u_evap_out=(ssc.unorm_evap_out-2)*(props.u_max-ssc.u_sat_vap_evap)+props.u_max;

            ssc.v_evap_out=sscInterp2(props.unorm_vap,props.p_TLU,props.v_vap,ssc.unorm_evap_out,ssc.p_evap,"nearest");

            ssc.h_evap_out=ssc.u_evap_out+ssc.p_evap*ssc.v_evap_out;


            ssc.delta_h_nominal=ssc.h_evap_out-ssc.h_cond_out;

            ssc.mdot_nominal_used=ssc.Q_nominal/ssc.delta_h_nominal;
        else

            ssc.mdot_nominal_used=ssc.mdot_nominal;
        end


        ssc.effective_area_nominal=ssc.mdot_nominal_used/sqrt(2)/ssc.sqrt_rho_p_diff_nominal;

        ssc.effective_area_min=ssc.mdot_leak_fraction*ssc.effective_area_nominal;


        ssc.p_bulb_TLU=props.p_TLU;
        ssc.T_sat_bulb_TLU=props.T_sat_vap;


        ssc.p_bulb_static=sscInterp1(ssc.T_sat_bulb_TLU,ssc.p_bulb_TLU,ssc.T_evap+ssc.delta_T_static,"nearest");

        ssc.p_bulb_nominal=sscInterp1(ssc.T_sat_bulb_TLU,ssc.p_bulb_TLU,ssc.T_evap+ssc.delta_T_nominal,"nearest");

        ssc.delta_p_static=ssc.p_bulb_static-ssc.p_evap;

        ssc.delta_p_nominal=ssc.p_bulb_nominal-ssc.p_evap;

        ssc.beta=(ssc.effective_area_nominal-ssc.effective_area_min)/(ssc.delta_p_nominal-ssc.delta_p_static);

        if ssc.capacity_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveCapacitySpec.HeatTransfer
            delta_T_max=fzero(@solveQmax,value(ssc.delta_T_nominal,"deltaK","linear"));
            solveQmax(delta_T_max);
        else

            ssc.effective_area_max=ssc.mdot_max/sqrt(2)/ssc.sqrt_rho_p_diff_nominal;

            ssc.delta_p_max=(ssc.effective_area_max-ssc.effective_area_min)/ssc.beta+ssc.delta_p_static;

            ssc.p_bulb_max=ssc.delta_p_max+ssc.p_evap;

            ssc.delta_T_max=sscInterp1(ssc.p_bulb_TLU,ssc.T_sat_bulb_TLU,ssc.p_bulb_max,"nearest")-ssc.T_evap;
        end


        ssc.Q1_T_evap_out=linspace(ssc.T_evap,ssc.T_evap+ssc.delta_T_max,N);

        ssc.Q1_p_bulb=sscInterp1(ssc.T_sat_bulb_TLU,ssc.p_bulb_TLU,ssc.Q1_T_evap_out,"nearest");

        if ssc.mop~=fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveMOP.Off

            ssc.Q1_p_bulb_mop=ssc.p_evap_mop+ssc.delta_p_static;
            ssc.Q1_T_bulb_mop=sscInterp1(ssc.p_bulb_TLU,ssc.T_sat_bulb_TLU,ssc.Q1_p_bulb_mop,"nearest");



            idx=ssc.Q1_T_evap_out>ssc.Q1_T_bulb_mop;
            ssc.Q1_p_bulb(idx)=ssc.Q1_p_bulb_mop/ssc.Q1_T_bulb_mop*ssc.Q1_T_evap_out(idx);
        end


        ssc.Q2_lift=linspace(ssc.effective_area_min/ssc.effective_area_max,1,N);

        ssc.Q2_effective_area_opening=ssc.Q2_lift*ssc.effective_area_max;

        ssc.Q2_delta_p_diaphram=(ssc.Q2_effective_area_opening-ssc.effective_area_min)/ssc.beta+ssc.delta_p_static;


        ssc.Q2_T_evap_out_ref=ssc.T_evap+ssc.delta_T_static;

        ssc.Q2_p_bulb_ref=sscInterp1(ssc.Q1_T_evap_out,ssc.Q1_p_bulb,ssc.Q2_T_evap_out_ref,"linear");

        ssc.Q2_p_evap=ssc.Q2_p_bulb_ref-ssc.Q2_delta_p_diaphram;


        ssc.Q3_lift=ssc.Q2_lift;

        ssc.Q3_mdot=ssc.Q2_effective_area_opening*sqrt(2)*ssc.sqrt_rho_p_diff_nominal;

        ssc.Q3_p_cond=ssc.p_cond;
        ssc.Q3_p_evap=ssc.p_evap;
        ssc.Q3_delta_T_sub=ssc.delta_T_sub;


        ssc.Q4_T_evap_out=ssc.Q1_T_evap_out;

        ssc.Q4_delta_p_diaphram=ssc.Q1_p_bulb-ssc.p_evap;

        ssc.Q4_effective_area_opening=ssc.beta*(ssc.Q4_delta_p_diaphram-ssc.delta_p_static)+ssc.effective_area_min;

        ssc.Q4_mdot=ssc.Q4_effective_area_opening*sqrt(2)*ssc.sqrt_rho_p_diff_nominal;


        if ssc.pressure_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValvePressureSpec.Pressure
            T_unit="degC";
            p_unit=string(unit(ssc.p_evap_nominal));
        else
            T_unit=T_unit_orig;
            p_unit="MPa";
        end
        lift_unit="1";
        if ssc.capacity_spec==fluids.two_phase_fluid.valves_orifices.flow_control_valves.enum.ThermostaticExpansionValveCapacitySpec.HeatTransfer
            mdot_unit="kg/hr";
        else
            mdot_unit=string(unit(ssc.mdot_nominal));
        end


        lift_label="Opening Fraction";


        linespec="-";

    else


        ssc.Q1_T_evap_out=ssc.T_evap_out_TLU1;

        ssc.Q1_p_bulb=ssc.p_bulb_TLU1;


        ssc.Q2_lift=ssc.lift_TLU2;

        ssc.Q2_p_evap=ssc.p_evap_TLU2;

        ssc.Q2_T_evap_out_ref=ssc.T_evap_out_ref;


        ssc.Q3_lift=ssc.lift_TLU3;

        ssc.Q3_mdot=ssc.mdot_TLU3;

        ssc.Q3_p_cond=ssc.p_cond_ref;
        ssc.Q3_p_evap=ssc.p_evap_ref;
        ssc.Q3_delta_T_sub=ssc.delta_T_sub_ref;


        ssc.Q4_T_evap_out=ssc.T_evap_out_TLU1;

        ssc.Q4_p_bulb_ref=sscInterp1(ssc.T_evap_out_TLU1,ssc.p_bulb_TLU1,ssc.T_evap_out_ref,"linear");

        ssc.Q4_lift=sscInterp1(ssc.p_evap_TLU2,ssc.lift_TLU2,ssc.p_evap_ref-(ssc.p_bulb_TLU1-ssc.Q4_p_bulb_ref),"linear");
        ssc.Q4_valve_lift_min=ssc.lift_TLU3(1);
        ssc.Q4_valve_lift_max=max(ssc.lift_TLU2(end),ssc.lift_TLU3(end));
        ssc.Q4_lift=min(max(ssc.Q4_lift,ssc.Q4_valve_lift_min),ssc.Q4_valve_lift_max);

        ssc.Q4_mdot=sscInterp1(ssc.lift_TLU3,ssc.mdot_TLU3,ssc.Q4_lift,"linear");


        T_unit=T_unit_orig;
        p_unit=string(unit(ssc.p_bulb_TLU1));
        lift_unit=string(unit(ssc.lift_TLU2));
        mdot_unit=string(unit(ssc.mdot_TLU3));


        lift_label="Valve Lift ("+lift_unit+")";


        linespec="x-";
    end


    ssc.Q1_T_sat=linspace(max(ssc.Q1_T_evap_out(1),props.T_sat_vap(1)),...
    min(ssc.Q1_T_evap_out(end),props.T_sat_vap(end)),N);

    ssc.Q1_p_sat=sscInterp1(props.T_sat_vap,props.p_TLU,ssc.Q1_T_sat,"linear");


    hAxis(1)=nexttile(1);
    plot(value(ssc.Q2_lift,lift_unit),value(ssc.Q2_p_evap,p_unit),linespec)
    grid on
    xlabel(lift_label);
    legend("Evaporator pressure at"+newline...
    +value(ssc.Q2_T_evap_out_ref,T_unit)+" "+T_unit+" evaporator"+newline...
    +"outlet temperature","Location","best")


    hAxis(2)=nexttile(2);
    plot(value(ssc.Q1_T_evap_out,T_unit),value(ssc.Q1_p_bulb,p_unit),linespec)
    hold on
    plot(value(ssc.Q1_T_sat,T_unit),value(ssc.Q1_p_sat,p_unit),"--")
    hold off
    grid on
    xlabel("Evaporator Outlet Temperature ("+T_unit+")");
    ylabel("Pressure ("+p_unit+")");
    legend("Bulb pressure",props.fluidName+" saturation pressure","Location","best")


    hAxis(3)=nexttile(3);
    plot(NaN,NaN,"LineStyle","none","Marker","none","Color","none")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.Q3_lift,lift_unit),value(ssc.Q3_mdot,mdot_unit),linespec)
    hold off
    grid on
    legend("High pressure = "+value(ssc.Q3_p_cond,p_unit)+" "+p_unit+newline+...
    "Low pressure = "+value(ssc.Q3_p_evap,p_unit)+" "+p_unit+newline+...
    "Subcooling = "+value(ssc.Q3_delta_T_sub,T_unit,"linear")+" "+T_unit,...
    "Box","off","Location","best")


    hAxis(4)=nexttile(4);
    plot(value(ssc.Q4_T_evap_out,T_unit),value(ssc.Q4_mdot,mdot_unit),"-")
    grid on
    ylabel("Mass Flow Rate ("+mdot_unit+")");


    XLim1=get(hAxis(1),"XLim");
    YLim1=get(hAxis(1),"YLim");
    XLim2=get(hAxis(2),"XLim");
    YLim2=get(hAxis(2),"YLim");
    XLim3=get(hAxis(3),"XLim");
    YLim3=get(hAxis(3),"YLim");
    XLim4=get(hAxis(4),"XLim");
    YLim4=get(hAxis(4),"YLim");

    set(hAxis([1,3]),"XLim",[min(XLim1(1),XLim3(1)),max(XLim1(2),XLim3(2))],"Xdir","reverse","YAxisLocation","right")
    set(hAxis([2,4]),"XLim",[min(XLim2(1),XLim4(1)),max(XLim2(2),XLim4(2))])
    set(hAxis([1,2]),"YLim",[min(YLim1(1),YLim2(1)),max(YLim1(2),YLim2(2))])
    set(hAxis([3,4]),"YLim",[min(YLim3(1),YLim4(1)),max(YLim3(2),YLim4(2))],"Ydir","reverse","XAxisLocation","top")



    ytickangle(hAxis,90)


    title(get(hAxis(1),"Parent"),"4-Quadrant Diagram")

end




function yq=sscInterp1(x,y,xq,extrap_method)

    x_val=value(x);
    xq_val=value(xq,unit(x));

    if strcmp(extrap_method,"nearest")
        xq_val=min(max(xq_val,x_val(1)),x_val(end));
    end

    yq=simscape.Value(interp1(x_val,value(y),xq_val,"linear","extrap"),unit(y));

end




function yq=sscInterp2(x1,x2,y,x1q,x2q,extrap_method)

    x1_val=value(x1);
    x2_val=value(x2);
    x1q_val=value(x1q,unit(x1));
    x2q_val=value(x2q,unit(x2));

    if strcmp(extrap_method,"nearest")
        x1q_val=min(max(x1q_val,x1_val(1)),x1_val(end));
        x2q_val=min(max(x2q_val,x2_val(1)),x2_val(end));
    end

    y_interp=griddedInterpolant({x1_val,x2_val},value(y),"linear");
    yq=simscape.Value(y_interp({x1q_val,x2q_val}),unit(y));

end