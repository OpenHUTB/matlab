function out=update_hydraulic_fluid(hBlock)




    SelFluid=get_param(hBlock,'SelFluid');

    warnings.messages={};






    if~any(strcmp(SelFluid,{'21','22','24'}))

        block_WS=get_param(hBlock,'MaskWSVariables');
        param_index=strcmp({block_WS.Name},'SysTemp');
        SysTemp=block_WS(param_index).Value;
        if isempty(SysTemp)
            SysTemp=20;
            warnings.messages{end+1,1}=...
            '20 degC used to evaluate Density, Isothermal bulk modulus, and Kinematic viscosity. Adjustment of these parameters may be required.';
        end


        info=sh_stockfluidproperties;
        ids=fieldnames(info);
        idx=str2double(SelFluid);

        [viscosity_kin,density,bulk]=info.(ids{idx}).prop(SysTemp);
    end

    if any(strcmp(SelFluid,{'21','22','23','24'}))






        il_block_use='Predefined';
        il_source='SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)';

        switch SelFluid
        case '21'
            fluid_list='7';
        case '22'
            fluid_list='6';
        case '23'
            fluid_list='3';
        case '24'
            fluid_list='1';
        end




        param_list={'sysTemp','T';
        'viscDerFactor','derate_coeff';
        'TrapAir','air_fraction'};

        collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
        collected_params(1).unit='degC';

        il_param_list=param_list(:,2);

        warnings.messages{end+1,1}='Predefined fluid has been reparameterized. Behavior change not expected at most temperatures.';
    else

        il_block_use='Foundation';
        il_source='fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)';

        warnings.messages{end+1,1}=['Selected predefined fluid is not available in the Isothermal Liquid library. '...
        ,'Equivalent properties assigned to an Isothermal Liquid Properties (IL) block. Behavior change not expected.'];

        TrapAir=get_param(hBlock,'TrapAir');
        ViscDerFactor=get_param(hBlock,'ViscDerFactor');



        collected_params(1).base=num2str(density);
        collected_params(1).unit='kg/m^3';

        collected_params(2).base=['(',num2str(viscosity_kin*10^6),')*(',ViscDerFactor,')'];
        collected_params(2).unit='cSt';

        collected_params(3).base=num2str(bulk,'%10.5e');
        collected_params(3).unit='Pa';

        collected_params(4).base=TrapAir;
        collected_params(4).unit='1';
        for i=1:4
            collected_params(i).conf='compiletime';
        end

        il_param_list={'rho_L_atm';'nu_atm';'beta_L_atm';'air_fraction'};


    end


    HtoIL_set_block_files(hBlock,il_source)

    if strcmp(il_block_use,'Predefined')

        set_param(hBlock,'fluid_list',fluid_list);

        if strcmp(fluid_list,'3')

            set_param(hBlock,'c_vol_EG','0.4');
            set_param(hBlock,'beta_L_atm_EG',num2str(bulk));
            set_param(hBlock,'beta_L_atm_EG_unit','Pa');





        end

    end


    HtoIL_apply_params(hBlock,il_param_list,collected_params);

    if isempty(warnings.messages)
        out=struct;
    else
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end
end

