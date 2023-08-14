function[Ra_sol,Rs_sol,Rp_sol,Lsa_sol,Lpa_sol,D_sol]=longShuntParameterize_private(V_rated,w_rated,w_noload,i_stall,i_rated,i_noload,ratioRaRs)










    coder.allowpcode('plain');



    Lsa_max=100*V_rated/(i_rated*w_rated);
    Lsa_min=-100*Lsa_max;




    if sign(residual_eq6(Lsa_max))==sign(residual_eq6(Lsa_min))

        pm_error('physmod:ee:library:MotorParameterizationFailed');




    else
        a=Lsa_min;
        b=Lsa_max;
    end


    num_max_iter=1000;
    tol_Lsa=1e-10;
    tol_res=1e-7;

    iter=1;
    while iter<num_max_iter
        m=(a+b)/2;
        res_m=residual_eq6(m);
        if(b-a)/2<tol_Lsa&&abs(res_m)<tol_res
            Lsa_sol=m;
            break;
        end
        iter=iter+1;

        if sign(res_m)==sign(residual_eq6(b))
            b=m;
        else
            a=m;
        end
    end


    if iter<num_max_iter

        Rtotal_series=-(Lsa_sol*w_noload*w_rated*(i_noload-i_rated))/(i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated);
        Rs_sol=1/(1+ratioRaRs)*Rtotal_series;
        Ra_sol=ratioRaRs/(1+ratioRaRs)*Rtotal_series;
        Rp_sol=(Lsa_sol*V_rated*w_noload*w_rated*(i_noload-i_rated))/(V_rated*i_noload*w_rated-V_rated*i_rated*w_noload+V_rated*i_stall*w_noload-V_rated*i_stall*w_rated+Lsa_sol*i_noload*i_stall*w_noload*w_rated-Lsa_sol*i_rated*i_stall*w_noload*w_rated);
        Lpa_sol=(Lsa_sol*(Lsa_sol*i_noload^2*i_rated*w_noload^2*w_rated-Lsa_sol*i_noload^2*i_rated*w_noload*w_rated^2-Lsa_sol*i_noload^2*i_stall*w_noload^2*w_rated+Lsa_sol*i_noload^2*i_stall*w_noload*w_rated^2+V_rated*i_noload^2*w_rated^2-Lsa_sol*i_noload*i_rated^2*w_noload^2*w_rated+Lsa_sol*i_noload*i_rated^2*w_noload*w_rated^2-2*V_rated*i_noload*i_rated*w_noload*w_rated+Lsa_sol*i_noload*i_stall^2*w_noload^2*w_rated-Lsa_sol*i_noload*i_stall^2*w_noload*w_rated^2+2*V_rated*i_noload*i_stall*w_noload*w_rated-2*V_rated*i_noload*i_stall*w_rated^2+Lsa_sol*i_rated^2*i_stall*w_noload^2*w_rated-Lsa_sol*i_rated^2*i_stall*w_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-Lsa_sol*i_rated*i_stall^2*w_noload^2*w_rated+Lsa_sol*i_rated*i_stall^2*w_noload*w_rated^2-2*V_rated*i_rated*i_stall*w_noload^2+2*V_rated*i_rated*i_stall*w_noload*w_rated+V_rated*i_stall^2*w_noload^2-2*V_rated*i_stall^2*w_noload*w_rated+V_rated*i_stall^2*w_rated^2))/((i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated)*(V_rated*i_noload*w_rated-V_rated*i_rated*w_noload+V_rated*i_stall*w_noload-V_rated*i_stall*w_rated+Lsa_sol*i_noload*i_stall*w_noload*w_rated-Lsa_sol*i_rated*i_stall*w_noload*w_rated));
        D_sol=0;
    else
        pm_error('physmod:ee:library:MotorParameterizationFailed');
    end


    if Rtotal_series<0||Rp_sol<0
        pm_error('physmod:ee:library:MotorParameterizationFailed');
    end



    function res=residual_eq6(Lsa)

        Ra=-(Lsa*w_noload*w_rated*(i_noload-i_rated))/(i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated);
        Rs=0;
        Rp=(Lsa*V_rated*w_noload*w_rated*(i_noload-i_rated))/(V_rated*i_noload*w_rated-V_rated*i_rated*w_noload+V_rated*i_stall*w_noload-V_rated*i_stall*w_rated+Lsa*i_noload*i_stall*w_noload*w_rated-Lsa*i_rated*i_stall*w_noload*w_rated);
        Lpa=(Lsa*(Lsa*i_noload^2*i_rated*w_noload^2*w_rated-Lsa*i_noload^2*i_rated*w_noload*w_rated^2-Lsa*i_noload^2*i_stall*w_noload^2*w_rated+Lsa*i_noload^2*i_stall*w_noload*w_rated^2+V_rated*i_noload^2*w_rated^2-Lsa*i_noload*i_rated^2*w_noload^2*w_rated+Lsa*i_noload*i_rated^2*w_noload*w_rated^2-2*V_rated*i_noload*i_rated*w_noload*w_rated+Lsa*i_noload*i_stall^2*w_noload^2*w_rated-Lsa*i_noload*i_stall^2*w_noload*w_rated^2+2*V_rated*i_noload*i_stall*w_noload*w_rated-2*V_rated*i_noload*i_stall*w_rated^2+Lsa*i_rated^2*i_stall*w_noload^2*w_rated-Lsa*i_rated^2*i_stall*w_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-Lsa*i_rated*i_stall^2*w_noload^2*w_rated+Lsa*i_rated*i_stall^2*w_noload*w_rated^2-2*V_rated*i_rated*i_stall*w_noload^2+2*V_rated*i_rated*i_stall*w_noload*w_rated+V_rated*i_stall^2*w_noload^2-2*V_rated*i_stall^2*w_noload*w_rated+V_rated*i_stall^2*w_rated^2))/((i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated)*(V_rated*i_noload*w_rated-V_rated*i_rated*w_noload+V_rated*i_stall*w_noload-V_rated*i_stall*w_rated+Lsa*i_noload*i_stall*w_noload*w_rated-Lsa*i_rated*i_stall*w_noload*w_rated));
        D=0;

        res=(V_rated^2*(Rp-Lpa*w_noload)*(Lpa*Ra+Lpa*Rs+Lsa*Rp))/(Rp^2*(Ra+Rs+Lsa*w_noload)^2)-D*w_noload;
    end



end