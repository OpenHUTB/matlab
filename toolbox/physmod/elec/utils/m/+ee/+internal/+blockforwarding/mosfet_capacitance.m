function out=mosfet_capacitance(in)





















    out=in;


    if~isempty(in.getValue('C_param'))
        C_param=in.getValue('C_param');


        if strcmp(C_param,'ee.enum.mosfet.capacitanceParam.tabluatedcgs')&&...
            ~isempty(in.getValue('V_GS_for_cap_data'))
            C_Vgs_vec=in.getValue('V_GS_for_cap_data');

            if strcmp(in.getValue('ComponentPath'),'ee.semiconductors.n_mosfet')...
                ||strcmp(in.getValue('ComponentPath'),'ee.semiconductors.n_mosfet_thermal')

                out=out.setValue('C_Vgs_vec',C_Vgs_vec);
            else

                out=out.setValue('C_Vsg_vec',C_Vgs_vec);
            end
        end

        if strcmp(in.getValue('paramTerminal'),'ee.enum.mosfet.numberOfTerminals.four')
            if(strcmp(C_param,'ee.enum.mosfet.capacitanceParam.fixedcgs')||...
                strcmp(C_param,'ee.enum.mosfet.capacitanceParam.tabluatedcgs'))&&...
                ~isempty(in.getValue('charge_linearity_param_vgb'))
                charge_linearity_param_with_vgb=strrep(in.getValue('charge_linearity_param_vgb'),'ee.enum.mosfet.cgbLinearity','ee.enum.mosfet.cgbLinearityWithSeparateCgb');
                out=out.setValue('charge_linearity_param_with_vgb',charge_linearity_param_with_vgb);
            end
        end
    end
end