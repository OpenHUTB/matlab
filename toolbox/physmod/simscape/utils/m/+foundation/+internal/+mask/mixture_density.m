function rho_mix=mixture_density(rho_L_ref,beta_L_ref,Kbp,alpha,p,...
    p_ref,p_crit,rho_g_ref,polytropic_index,...
    air_dissolution_model,bulk_modulus_model)







    if air_dissolution_model==simscape.enum.onoff.on
        theta=fluids_functions.blend(1,0,p_ref,p_crit,p);
    else
        theta=1;
    end

    if alpha==0
        p_ratio=1;
    else
        if air_dissolution_model==simscape.enum.onoff.off
            p_ratio=alpha./(1-alpha).*(p_ref./p).^(1/polytropic_index);
        else
            p_ratio=alpha./(1-alpha).*(p_ref./p).^(1/polytropic_index).*theta;
        end
    end

    if bulk_modulus_model==foundation.enum.bulk_modulus_model.const,...
        exp_term=exp((p-p_ref)./beta_L_ref);
    else
        exp_term=(1+Kbp.*(p-p_ref)./beta_L_ref).^(1/Kbp);
    end


    if alpha==0
        rho_mix=rho_L_ref.*exp_term;
    else
        rho_mix=(rho_L_ref+alpha./(1-alpha).*rho_g_ref)./(p_ratio+1./exp_term);
    end

end