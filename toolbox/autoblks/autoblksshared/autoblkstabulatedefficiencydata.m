function[x_w_tmp,x_T_tmp,x_losses_tmp]=autoblkstabulatedefficiencydata(w_tmp,T_tmp,efficiency_mat)




    n_w=numel(w_tmp);
    n_T=numel(T_tmp);
    idx_w=n_w:-1:1;
    idx_T=n_T:-1:1;


    eta_tmp=0.01*efficiency_mat;

    if(w_tmp(1)<0)&&(T_tmp(1)<0)


        x_w_tmp=w_tmp;
        x_T_tmp=T_tmp;
        x_eta_tmp=eta_tmp;

    elseif(w_tmp(1)<0)&&(T_tmp(1)>=0)


        x_w_tmp=w_tmp;
        x_T_tmp=[-T_tmp(idx_T),T_tmp];


        eta_tmp1=eta_tmp(:,idx_T);
        eta_tmp2=eta_tmp1(idx_w,:);
        x_eta_tmp=[eta_tmp2,eta_tmp];

    elseif(w_tmp(1)>=0)&&(T_tmp(1)<0)


        x_T_tmp=T_tmp;
        x_w_tmp=[-w_tmp(idx_w),w_tmp];


        eta_tmp1=eta_tmp(:,idx_T);
        eta_tmp2=eta_tmp1(idx_w,:);
        x_eta_tmp=[eta_tmp2;eta_tmp];

    else


        x_w_tmp=[-w_tmp(idx_w),w_tmp];
        x_T_tmp=[-T_tmp(idx_T),T_tmp];



        eta_tmp1=eta_tmp(:,idx_T);
        eta_tmp2=[eta_tmp1,eta_tmp];

        eta_tmp3=eta_tmp2(idx_w,:);
        x_eta_tmp=[eta_tmp3;eta_tmp2];

    end


    x_losses_tmp=zeros(size(x_eta_tmp));
    mech_power=x_w_tmp'*x_T_tmp;
    idx_13=find(mech_power>0);
    idx_24=find(mech_power<0);
    x_losses_tmp(idx_13)=mech_power(idx_13).*(1./x_eta_tmp(idx_13)-1);
    x_losses_tmp(idx_24)=mech_power(idx_24).*(x_eta_tmp(idx_24)-1);


    idx=find(x_w_tmp==0);
    if length(idx)==2
        x_losses_tmp(idx(1),:)=[];
        x_w_tmp(idx(1))=[];
    end


    idy=find(x_T_tmp==0);
    if length(idy)==2
        x_losses_tmp(:,idy(1))=[];
        x_T_tmp(idy(1))=[];
    end
end