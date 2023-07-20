function[x_w_tmp,x_T_tmp,x_losses_tmp]=autoblkstabulatedlosssdata(w_tmp,T_tmp,L_tmp)



    n_w=numel(w_tmp);
    n_T=numel(T_tmp);
    idx_w=n_w:-1:1;
    idx_T=n_T:-1:1;


    if(w_tmp(1)<0)&&(T_tmp(1)<0)


        x_w_tmp=w_tmp;
        x_T_tmp=T_tmp;
        x_losses_tmp=L_tmp;

    elseif(w_tmp(1)<0)&&(T_tmp(1)>=0)


        x_w_tmp=w_tmp;
        x_T_tmp=[-T_tmp(idx_T),T_tmp];
        L_tmp1=L_tmp(:,idx_T);
        L_tmp2=L_tmp1(idx_w,:);
        x_losses_tmp=[L_tmp2,L_tmp];

    elseif(w_tmp(1)>=0)&&(T_tmp(1)<0)


        x_T_tmp=T_tmp;
        x_w_tmp=[-w_tmp(idx_w),w_tmp];
        L_tmp1=L_tmp(:,idx_T);
        L_tmp2=L_tmp1(idx_w,:);
        x_losses_tmp=[L_tmp2;L_tmp];

    else


        x_w_tmp=[-w_tmp(idx_w),w_tmp];
        x_T_tmp=[-T_tmp(idx_T),T_tmp];

        L_tmp1=L_tmp(:,idx_T);
        L_tmp2=[L_tmp1,L_tmp];

        L_tmp3=L_tmp2(idx_w,:);
        x_losses_tmp=[L_tmp3;L_tmp2];

    end


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

