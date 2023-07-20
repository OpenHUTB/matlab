classdef(Abstract=true,Sealed=true)TwoPhaseFluidPredefinedProperties









    methods(Static=true,Hidden=true)

        function[u_min,u_max,unorm_liq,unorm_vap,p_TLU,...
            v_liq,v_vap,s_liq,s_vap,T_liq,T_vap,...
            nu_liq,nu_vap,k_liq,k_vap,Pr_liq,Pr_vap,...
            u_sat_liq,u_sat_vap,p_crit]=extractTables(fluid)


            [~,fluidCellStr]=enumeration("fluids.two_phase_fluid.utilities.enum.Fluid");
            fluidStr=string(fluidCellStr(fluid));


            fluidFile=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
            "+fluids","+internal","+two_phase_fluid","+utilities","private",fluidStr+".mat");
            S=load(fluidFile,"fluidTablesObj");
            fluidTables=S.fluidTablesObj.FluidTables;


            u_min=fluidTables.u_min;
            u_max=fluidTables.u_max;
            unorm_liq=fluidTables.liquid.unorm;
            unorm_vap=fluidTables.vapor.unorm;
            p_TLU=fluidTables.p;
            v_liq=fluidTables.liquid.v;
            v_vap=fluidTables.vapor.v;
            s_liq=fluidTables.liquid.s;
            s_vap=fluidTables.vapor.s;
            T_liq=fluidTables.liquid.T;
            T_vap=fluidTables.vapor.T;
            nu_liq=fluidTables.liquid.nu;
            nu_vap=fluidTables.vapor.nu;
            k_liq=fluidTables.liquid.k;
            k_vap=fluidTables.vapor.k;
            Pr_liq=fluidTables.liquid.Pr;
            Pr_vap=fluidTables.vapor.Pr;
            u_sat_liq=fluidTables.liquid.u_sat;
            u_sat_vap=fluidTables.vapor.u_sat;
            p_crit=fluidTables.p_crit;
        end

    end

end