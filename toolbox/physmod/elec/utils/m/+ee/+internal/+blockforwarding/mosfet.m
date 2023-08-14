function out=mosfet(in)










    out=in;




    if~isempty(in.getValue('parameterization'))
        parameterization=strrep(in.getValue('parameterization'),'ee.enum.parameterization','ee.enum.mosfet.parameterization');
        out=out.setValue('parameterization',parameterization);
    end









    if~isempty(in.getValue('C_param'))
        C_param=in.getValue('C_param');
        if(C_param==ee.enum.mosfet.capacitanceParam.fixedcgs||...
            C_param==ee.enum.mosfet.capacitanceParam.tabluatedcgs)&&...
            ~isempty(in.getValue('charge_linearity_param_vgb'))
            charge_linearity_param_with_vgb=strrep(in.getValue('charge_linearity_param_vgb'),'ee.enum.mosfet.cgbLinearity','ee.enum.mosfet.cgbLinearityWithSeparateCgb');
            out=out.setValue('charge_linearity_param_with_vgb',charge_linearity_param_with_vgb);
        end

        if C_param==ee.enum.mosfet.capacitanceParam.tabluatedcgs&&...
            ~isempty(in.getValue('V_GS_for_cap_data'))
            C_Vgs_vec=in.getValue('V_GS_for_cap_data');
            out=out.setValue('C_Vgs_vec',C_Vgs_vec);
        end
    end

end