function message_cell=HtoIL_add_tabulated_orifice_warnings(...
    message_cell,mdl_type_val,interp_method_val,extrap_method_val,...
    pressure_tab,area_tab,vol_flow_tab,increase_decrease_str,...
    del_S_TLU_friendly_name,area_TLU_friendly_name,p_diff_TLU_friendly_name,vol_flow_TLU_friendly_name)










    if interp_method_val==2
        if mdl_type_val==2
            message_cell{end+1,1}=['Interpolation method changed to Linear. '...
            ,'Additional elements in ',del_S_TLU_friendly_name,' and ',area_TLU_friendly_name,' may be required.'];
        elseif mdl_type_val==3
            message_cell{end+1,1}=['Interpolation method changed to Linear. '...
            ,'Additional elements in ',del_S_TLU_friendly_name,', ',p_diff_TLU_friendly_name,', and ',vol_flow_TLU_friendly_name,' may be required.'];
        end
    end


    if mdl_type_val==2&&extrap_method_val~=2
        message_cell{end+1,1}=['Extrapolation method changed to Nearest. '...
        ,'Extension of ',del_S_TLU_friendly_name,' and ',area_TLU_friendly_name,' may be required.'];
    end


    if mdl_type_val==3
        if extrap_method_val==2
            message_cell{end+1,1}=['Extrapolation method of ',p_diff_TLU_friendly_name,' changed to Linear. '...
            ,'Extension of ',p_diff_TLU_friendly_name,' and ',vol_flow_TLU_friendly_name,' may be required.'];
        else
            message_cell{end+1,1}=['Extrapolation method of ',del_S_TLU_friendly_name,' changed to Nearest. '...
            ,'Extension of ',del_S_TLU_friendly_name,' and ',vol_flow_TLU_friendly_name,' may be required.'];
        end

        pressure_tab_first=HtoIL_get_vector_element(pressure_tab,'first');
        pressure_tab_first_value=str2num(pressure_tab_first.base);
        if isempty(pressure_tab_first_value)||pressure_tab_first_value>=0

            message_cell{end+1,1}=['If all values of ',p_diff_TLU_friendly_name,' are greater than 0, '...
            ,'then the block internally extends ',p_diff_TLU_friendly_name,' and ',vol_flow_TLU_friendly_name,' to contain negative values. '...
            ,'Adjustment of these parameters may be required.'];
        end
    end


    if mdl_type_val==2
        area_tab_value=str2num(area_tab.base);
        if~isempty(area_tab_value)
            known_monotonic=all(diff(area_tab_value)>=0)||all(diff(area_tab_value)<=0);
        else
            known_monotonic=0;
        end
        if~known_monotonic
            message_cell{end+1,1}=['In the Isothermal Liquid library, ',area_TLU_friendly_name,' must contain monotonically ',increase_decrease_str,' values. '...
            ,'Adjustment of ',del_S_TLU_friendly_name,' and ',area_TLU_friendly_name,' may be required.'];
        end
    elseif mdl_type_val==3
        vol_flow_tab_value=str2num(vol_flow_tab.base);
        if~isempty(vol_flow_tab_value)
            known_monotonic=all(all(diff(vol_flow_tab_value,1,2)>0))&&all(all(diff(vol_flow_tab_value,1,1)>=0)|all(diff(vol_flow_tab_value,1,1)<=0));
        else
            known_monotonic=0;
        end
        if~known_monotonic
            message_cell{end+1,1}=['In the Isothermal Liquid library, ',vol_flow_TLU_friendly_name,' must contain monotonically ',increase_decrease_str,' columns '...
            ,'and strictly monotonically increasing rows. '...
            ,'Adjustment of ',del_S_TLU_friendly_name,', ',p_diff_TLU_friendly_name,', and ',vol_flow_TLU_friendly_name,' may be required.'];
        end
    end

end


