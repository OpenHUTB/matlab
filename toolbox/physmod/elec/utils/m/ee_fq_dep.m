function[F1,F2,F3,F4]=ee_fq_dep(VJ_t,FC_a,MG_a)









    if(FC_a>0)
        F1=VJ_t*(1-(1-FC_a)^(1-MG_a))/(1-MG_a);
        F2=(1-FC_a)^(1+MG_a);
        F3=1-FC_a*(1+MG_a);
        F4=FC_a*VJ_t;
    elseif(FC_a==0)
        F1={0,'V'};
        F2=1;
        F3=1;
        F4={0,'V'};
    else
        pm_error('physmod:simscape:compiler:patterns:checks:GreaterThanZero',...
        getString(message('physmod:ee:library:comments:utils:ee_fq_dep:error_TheDepletionCapacitorCoefficientFC')));
    end



