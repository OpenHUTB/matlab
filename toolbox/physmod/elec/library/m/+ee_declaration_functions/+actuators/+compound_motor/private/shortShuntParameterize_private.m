function[Ra_sol,Rs_sol,Rp_sol,Lsa_sol,Lpa_sol,D_sol]=shortShuntParameterize_private(V_rated,w_rated,w_noload,i_stall,i_rated,i_noload,t_rated,ratioRpRs)








    coder.allowpcode('plain');



    Ra_sol=(ratioRpRs*(t_rated*w_noload^2*w_rated-V_rated*i_noload*w_rated^2+V_rated*i_rated*w_noload^2-V_rated*i_stall*w_noload^2+V_rated*i_stall*w_rated^2)*(V_rated*i_rated^2*w_noload^2-V_rated*i_noload^2*w_rated^2+V_rated*i_stall^2*w_noload^2-V_rated*i_stall^2*w_rated^2+2*V_rated*i_noload*i_stall*w_rated^2-2*V_rated*i_rated*i_stall*w_noload^2-V_rated*i_noload^2*ratioRpRs*w_rated^2+V_rated*i_rated^2*ratioRpRs*w_noload^2+V_rated*i_noload*i_stall*ratioRpRs*w_rated^2-V_rated*i_rated*i_stall*ratioRpRs*w_noload^2+i_stall*ratioRpRs*t_rated*w_noload^2*w_rated))/((ratioRpRs+1)^2*(i_noload*w_rated+i_rated*w_noload-i_stall*w_noload-i_stall*w_rated)*(i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated)*(-V_rated*i_noload^2*w_rated^2+V_rated*i_stall*i_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-V_rated*i_stall*i_rated*w_noload^2+i_stall*t_rated*w_noload^2*w_rated));

    Rs_sol=(V_rated*(t_rated*w_noload^2*w_rated-V_rated*i_noload*w_rated^2+V_rated*i_rated*w_noload^2-V_rated*i_stall*w_noload^2+V_rated*i_stall*w_rated^2))/((ratioRpRs+1)*(-V_rated*i_noload^2*w_rated^2+V_rated*i_stall*i_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-V_rated*i_stall*i_rated*w_noload^2+i_stall*t_rated*w_noload^2*w_rated));

    Rp_sol=ratioRpRs*Rs_sol;

    Lsa_sol=(ratioRpRs*(t_rated*w_noload^2*w_rated-V_rated*i_noload*w_rated^2+V_rated*i_rated*w_noload^2-V_rated*i_stall*w_noload^2+V_rated*i_stall*w_rated^2)*(V_rated*i_noload^3*w_rated^3+V_rated*i_rated^3*w_noload^3+i_stall^2*t_rated*w_noload^2*w_rated^2-V_rated*i_noload*i_rated^2*w_noload^3-V_rated*i_noload*i_stall^2*w_noload^3-V_rated*i_noload^2*i_rated*w_rated^3+V_rated*i_noload*i_stall^2*w_rated^3+V_rated*i_rated*i_stall^2*w_noload^3-2*V_rated*i_noload^2*i_stall*w_rated^3-2*V_rated*i_rated^2*i_stall*w_noload^3-V_rated*i_rated*i_stall^2*w_rated^3+V_rated*i_noload^3*ratioRpRs*w_rated^3+V_rated*i_rated^3*ratioRpRs*w_noload^3-i_stall^2*t_rated*w_noload^3*w_rated+V_rated*i_noload*i_stall^2*ratioRpRs*w_rated^3+V_rated*i_rated*i_stall^2*ratioRpRs*w_noload^3-2*V_rated*i_noload^2*i_stall*ratioRpRs*w_rated^3-2*V_rated*i_rated^2*i_stall*ratioRpRs*w_noload^3+i_noload*i_rated*t_rated*w_noload^2*w_rated^2-i_noload*i_stall*t_rated*w_noload^2*w_rated^2-i_rated*i_stall*t_rated*w_noload^2*w_rated^2-i_stall^2*ratioRpRs*t_rated*w_noload^3*w_rated+i_stall^2*ratioRpRs*t_rated*w_noload^2*w_rated^2+2*V_rated*i_noload*i_rated*i_stall*w_noload^3+2*V_rated*i_noload*i_rated*i_stall*w_rated^3-i_noload*i_rated*t_rated*w_noload^3*w_rated+i_noload*i_stall*t_rated*w_noload^3*w_rated+i_rated*i_stall*t_rated*w_noload^3*w_rated+i_rated*i_stall*ratioRpRs*t_rated*w_noload^3*w_rated-V_rated*i_noload*i_rated^2*ratioRpRs*w_noload^2*w_rated-V_rated*i_noload^2*i_rated*ratioRpRs*w_noload*w_rated^2-V_rated*i_noload*i_stall^2*ratioRpRs*w_noload*w_rated^2+V_rated*i_noload^2*i_stall*ratioRpRs*w_noload*w_rated^2-V_rated*i_rated*i_stall^2*ratioRpRs*w_noload^2*w_rated+V_rated*i_rated^2*i_stall*ratioRpRs*w_noload^2*w_rated-i_noload*i_stall*ratioRpRs*t_rated*w_noload^2*w_rated^2+V_rated*i_noload*i_rated*i_stall*ratioRpRs*w_noload*w_rated^2+V_rated*i_noload*i_rated*i_stall*ratioRpRs*w_noload^2*w_rated))/(w_noload*w_rated*(i_noload-i_rated)*(ratioRpRs+1)^2*(i_noload*w_rated+i_rated*w_noload-i_stall*w_noload-i_stall*w_rated)*(i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated)*(-V_rated*i_noload^2*w_rated^2+V_rated*i_stall*i_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-V_rated*i_stall*i_rated*w_noload^2+i_stall*t_rated*w_noload^2*w_rated));

    Lpa_sol=-(ratioRpRs^2*(i_noload*i_rated*w_noload-i_noload*i_stall*w_noload-i_noload*i_rated*w_rated+i_rated*i_stall*w_rated)*(t_rated*w_noload^2*w_rated-V_rated*i_noload*w_rated^2+V_rated*i_rated*w_noload^2-V_rated*i_stall*w_noload^2+V_rated*i_stall*w_rated^2)^2)/(w_noload*w_rated*(i_noload-i_rated)*(ratioRpRs+1)^2*(i_noload*w_rated+i_rated*w_noload-i_stall*w_noload-i_stall*w_rated)*(i_noload*w_rated-i_rated*w_noload+i_stall*w_noload-i_stall*w_rated)*(-V_rated*i_noload^2*w_rated^2+V_rated*i_stall*i_noload*w_rated^2+V_rated*i_rated^2*w_noload^2-V_rated*i_stall*i_rated*w_noload^2+i_stall*t_rated*w_noload^2*w_rated));

    D_sol=((i_noload-i_stall)*(V_rated*i_rated^2-V_rated*i_noload*i_rated+V_rated*i_noload*i_stall-V_rated*i_rated*i_stall-i_noload*t_rated*w_rated+i_stall*t_rated*w_rated))/(i_noload^2*w_rated^2-2*i_noload*i_stall*w_rated^2-i_rated^2*w_noload^2+2*i_rated*i_stall*w_noload^2-i_stall^2*w_noload^2+i_stall^2*w_rated^2);



    if Ra_sol<0||Rs_sol<0||D_sol<0
        pm_error('physmod:ee:library:MotorParameterizationFailed');
    end


end
