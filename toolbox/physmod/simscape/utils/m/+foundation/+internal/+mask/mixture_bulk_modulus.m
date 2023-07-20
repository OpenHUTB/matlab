function beta_mix=mixture_bulk_modulus(beta_L_ref,Kbp,alpha,p,...
    p_ref,p_crit,polytropic_index,...
    air_dissolution_model,bulk_modulus_model)






    if air_dissolution_model==simscape.enum.onoff.on

        theta=fluids_functions.blend(1,0,p_ref,p_crit,p);


        dtheta_dp=6.*(p-p_ref).*(p-p_crit)./(p_crit-p_ref)^3;
        dtheta_dp(p<=p_ref)=0;
        dtheta_dp(p>=p_crit)=0;

    else
        theta=1;
        dtheta_dp=0;
    end


    if alpha==0
        p_ratio=1;
        p_denom=1;
        exp_term=1;

    else
        if air_dissolution_model==simscape.enum.onoff.off
            p_ratio=alpha./(1-alpha).*(p_ref./p).^(1/polytropic_index);
            p_denom=beta_L_ref.*p_ratio./p/polytropic_index;

        else
            p_denom=beta_L_ref*alpha./(1-alpha).*(p_ref./p).^(1/polytropic_index).*...
            (theta./p/polytropic_index-dtheta_dp);
            p_ratio=alpha./(1-alpha).*(p_ref./p).^(1/polytropic_index).*theta;
        end

        if bulk_modulus_model==foundation.enum.bulk_modulus_model.const
            exp_term=exp(-(p-p_ref)./beta_L_ref);
        else
            exp_term=1./(1+Kbp.*(p-p_ref)./beta_L_ref).^(1/Kbp);
        end
    end


    if alpha==0
        if bulk_modulus_model==foundation.enum.bulk_modulus_model.const
            beta_mix=beta_L_ref.*ones(size(p));
        else
            beta_mix=beta_L_ref+Kbp.*(p-p_ref);
        end
    else
        if bulk_modulus_model==foundation.enum.bulk_modulus_model.const
            beta_mix=beta_L_ref.*(exp_term+p_ratio)./(exp_term+p_denom);
        else
            beta_mix=beta_L_ref.*(exp_term+p_ratio)./(exp_term./(1+Kbp.*(p-p_ref)./beta_L_ref)+p_denom);
        end
    end

end