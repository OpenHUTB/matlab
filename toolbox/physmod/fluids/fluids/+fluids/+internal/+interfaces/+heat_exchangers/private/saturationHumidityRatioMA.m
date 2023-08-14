



function HR_s=saturationHumidityRatioMA(T,props)

%#codegen
    coder.allowpcode('plain')

    x_ag_min_MA=props.x_ag_min;


    T_limited=min(props.T_TLU(end),max(props.T_TLU(1),T));
    p_ws_ratio=exp(log(props.p)...
    -interp1(props.T_TLU,props.log_p_ws_TLU,T_limited,'linear','extrap'));


    if p_ws_ratio>=props.RH_ws
        x_ws=props.R_ag/(props.R_ag+props.R_w*(p_ws_ratio/props.RH_ws-1));
    else
        x_ws=1;
    end



    if 1-x_ws>=x_ag_min_MA
        x_ags_smooth=1-x_ws;
    else
        x_ags_smooth=x_ag_min_MA*exp((1-x_ws-x_ag_min_MA)/x_ag_min_MA);
    end


    HR_s=(1-x_ags_smooth)/x_ags_smooth;

end