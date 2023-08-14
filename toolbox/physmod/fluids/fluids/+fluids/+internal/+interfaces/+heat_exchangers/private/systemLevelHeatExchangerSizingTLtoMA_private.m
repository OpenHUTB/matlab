







function[geometry_TL,geometry_MA,Q_seg_calc,T_nodes_TL,rho_avg_TL,...
    T_nodes_MA,x_w_nodes_MA,x_g_nodes_MA,v_avg_MA,exitflag]...
    =systemLevelHeatExchangerSizingTLtoMA_private(flow_arrangement,Q_nom,...
    mdot_TL,p_TL,h_in_TL,...
    T_TLU_TL,rho_TLU_TL,u_TLU_TL,mu_TLU_TL,k_TLU_TL,Pr_TLU_TL,...
    a_TL,b_TL,c_TL,D_ref_TL,S_ref_TL,Nu_lam_TL,...
    mdot_MA,p_MA,T_in_MA,x_w_in_MA,x_g_in_MA,...
    R_a_MA,R_w_MA,R_g_MA,T_TLU_MA,log_p_ws_TLU_MA,h_w_vap_TLU_MA,...
    h_a_TLU_MA,h_w_TLU_MA,h_g_TLU_MA,cp_a_coeff_MA,cp_w_coeff_MA,cp_g_coeff_MA,...
    mu_a_TLU_MA,mu_w_TLU_MA,mu_g_TLU_MA,k_a_TLU_MA,k_w_TLU_MA,k_g_TLU_MA,...
    Pr_a_TLU_MA,Pr_w_TLU_MA,Pr_g_TLU_MA,RH_ws_MA,x_ag_min_MA,...
    a_MA,b_MA,c_MA,D_ref_MA,S_ref_MA,Nu_lam_MA)

%#codegen
    coder.allowpcode('plain')


    N=3;


    xG_floor=1e-9;


    opt_outer_search={eps,500,'off'};
    opt_outer_solve=optimset('Display','off');
    opt_inner_search={eps,1000,'off'};
    opt_inner_solve=optimset('Display','off');


    [T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL]=preprocessTL(mdot_TL,p_TL,h_in_TL,...
    T_TLU_TL,rho_TLU_TL,u_TLU_TL,mu_TLU_TL,k_TLU_TL,Pr_TLU_TL,...
    a_TL,b_TL,c_TL,D_ref_TL,S_ref_TL,Nu_lam_TL);


    [hbar_in_MA,~,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA]...
    =preprocessMA(mdot_MA,p_MA,T_in_MA,x_w_in_MA,x_g_in_MA,...
    R_a_MA,R_w_MA,R_g_MA,T_TLU_MA,log_p_ws_TLU_MA,h_w_vap_TLU_MA,...
    h_a_TLU_MA,h_w_TLU_MA,h_g_TLU_MA,cp_a_coeff_MA,cp_w_coeff_MA,cp_g_coeff_MA,...
    mu_a_TLU_MA,mu_w_TLU_MA,mu_g_TLU_MA,k_a_TLU_MA,k_w_TLU_MA,k_g_TLU_MA,...
    Pr_a_TLU_MA,Pr_w_TLU_MA,Pr_g_TLU_MA,RH_ws_MA,x_ag_min_MA,...
    a_MA,b_MA,c_MA,D_ref_MA,S_ref_MA,Nu_lam_MA);


    [corr_term_TL,T_seg_TL,~,T_out_TL]=correlationTermsTL(...
    -Q_nom,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL);


    [corr_term_MA,~,~,T_out_MA,hbar_out_MA,cpbar_out_MA,...
    mu_out_MA,k_out_MA,Pr_out_MA]=correlationTermsDryMA(...
    Q_nom,hbar_in_MA,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA);


    T_seg_MA=(T_in_MA+T_out_MA)/2;




    geometry_TL=10;
    geometry_MA=10;
    Q_seg_calc=Q_nom*ones(N,N);
    T_nodes_TL=repmat(linspace(T_in_TL,T_out_TL,N+1)',1,N);
    rho_avg_TL=1;
    T_nodes_MA=repmat(linspace(T_in_MA,T_out_MA,N+1)',1,N);
    x_w_nodes_MA=x_w_in_MA*ones(N+1,N);
    x_g_nodes_MA=x_g_in_MA*ones(N+1,N);
    v_avg_MA=1;

    exitflag_inner=ones(N,N);


    if T_in_TL<=T_in_MA
        exitflag=-10;
        return
    elseif T_seg_TL<=T_seg_MA
        exitflag=-20;
        return
    end


    UA_overall=Q_nom/(T_seg_TL-T_seg_MA);



    geometry_TL_init=2*UA_overall/corr_term_TL;
    geometry_MA_init=2*UA_overall/corr_term_MA;

    if flow_arrangement==1

        if T_out_TL<T_out_MA
            exitflag=-13;
            return
        end


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_TL_init,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
        geometry_MA_init,hbar_in_MA,cpbar_in_MA,...
        mu_in_MA,k_in_MA,Pr_in_MA,props_MA,opt_inner_search,opt_inner_solve);


        [xG_int,~,exitflag]=intervalSearch(fcn,...
        1,0.2,0.1,5,0.02,[],xG_floor,inf,opt_outer_search{:});

        if exitflag==2

            xG=xG_int(1);
        elseif exitflag==1

            [xG,~,exitflag]=fzero(fcn,xG_int,opt_outer_solve);
            if exitflag<0
                return
            end
        else
            return
        end


        [~,Q_seg_calc(:,1),T_nodes_TL_tmp,hbar_nodes_MA_tmp,exitflag_inner(:,1)]=fcn(xG);

        T_nodes_TL=repmat(T_nodes_TL_tmp,1,N);
        hbar_nodes_MA=repmat(hbar_nodes_MA_tmp,1,N);

    elseif flow_arrangement==2

        if T_out_TL<T_in_MA
            exitflag=-11;
            return
        elseif T_out_MA>T_in_TL
            exitflag=-12;
            return
        end


        props_MA.mdot_in=-props_MA.mdot_in;
        props_MA.mdot_ag=-props_MA.mdot_ag;


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_TL_init,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
        geometry_MA_init,hbar_out_MA,cpbar_out_MA,...
        mu_out_MA,k_out_MA,Pr_out_MA,props_MA,opt_inner_search,opt_inner_solve);


        [xG_int,~,exitflag]=intervalSearch(fcn,...
        1,0.2,0.1,5,0.02,[],xG_floor,inf,opt_outer_search{:});

        if exitflag==2

            xG=xG_int(1);
        elseif exitflag==1

            [xG,~,exitflag]=fzero(fcn,xG_int,opt_outer_solve);
            if exitflag<0
                return
            end
        else
            return
        end


        [~,Q_seg_calc(:,1),T_nodes_TL_tmp,hbar_nodes_MA_tmp,exitflag_inner(:,1)]=fcn(xG);

        T_nodes_TL=repmat(T_nodes_TL_tmp,1,N);
        hbar_nodes_MA=repmat(hbar_nodes_MA_tmp,1,N);


        hbar_nodes_MA=flip(hbar_nodes_MA,1);

    else


        if T_out_TL<T_in_MA
            exitflag=-11;
            return
        elseif T_out_MA>T_in_TL
            exitflag=-12;
            return
        end


        props_TL.mdot=props_TL.mdot/N;
        props_TL.DS_ratio=props_TL.DS_ratio*N;
        props_MA.mdot_in=props_MA.mdot_in/N;
        props_MA.mdot_ag=props_MA.mdot_ag/N;
        props_MA.DS_ratio=props_MA.DS_ratio*N;


        heatTransferGrid([],N)

        fcn=@(xG)heatTransferGrid(xG,N,Q_nom,...
        geometry_TL_init,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
        geometry_MA_init,hbar_in_MA,cpbar_in_MA,...
        mu_in_MA,k_in_MA,Pr_in_MA,props_MA,opt_inner_search,opt_inner_solve);


        [xG_int,~,exitflag]=intervalSearch(fcn,...
        1,0.2,0.1,5,0.02,[],xG_floor,inf,opt_outer_search{:});

        if exitflag==2

            xG=xG_int(1);
        elseif exitflag==1

            [xG,~,exitflag]=fzero(fcn,xG_int,opt_outer_solve);
            if exitflag<0
                return
            end
        else
            return
        end


        [~,Q_seg_calc,T_nodes_TL,hbar_nodes_MA,exitflag_inner]=fcn(xG);
    end

    if any(exitflag_inner<0)
        exitflag=-logspace(N^2-1,0,N^2)*abs(exitflag_inner(:));
        return
    end


    geometry_TL=xG*geometry_TL_init;
    geometry_MA=xG*geometry_MA_init;


    rho_avg_TL=postprocessTL(T_nodes_TL,props_TL);


    [v_avg_MA,T_nodes_MA]=postprocessMA(...
    hbar_nodes_MA,props_MA.HR_in*ones(N+1,N),props_MA);

end





function[residual,Q_seg_calc,T_TL,hbar_MA,exitflag]=heatTransferColinear(...
    xG,N,Q_nom,...
    geometry_TL_init,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
    geometry_MA_init,hbar_in_MA,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    T_TL_prev1 T_TL_prev2...
    hbar_MA_prev1 hbar_MA_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,1);Q_seg_calc_prev2=NaN(N,1);
        T_TL_prev1=NaN(N+1,1);T_TL_prev2=NaN(N+1,1);
        hbar_MA_prev1=NaN(N+1,1);hbar_MA_prev2=NaN(N+1,1);
        exitflag_prev1=NaN(N,1);exitflag_prev2=NaN(N,1);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        T_TL=T_TL_prev1;
        hbar_MA=hbar_MA_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        T_TL=T_TL_prev2;
        hbar_MA=hbar_MA_prev2;
        exitflag=exitflag_prev2;
        return
    end


    geometry_TL=xG*geometry_TL_init;
    geometry_MA=xG*geometry_MA_init;


    xQ=ones(N,1);

    Q_seg_calc=zeros(N,1);
    exitflag=ones(N,1);

    h_TL=h_in_TL*ones(N+1,1);
    T_TL=T_in_TL*ones(N+1,1);
    mu_TL=mu_in_TL*ones(N+1,1);
    k_TL=k_in_TL*ones(N+1,1);
    Pr_TL=Pr_in_TL*ones(N+1,1);

    hbar_MA=hbar_in_MA*ones(N+1,1);
    cpbar_MA=cpbar_in_MA*ones(N+1,1);
    mu_MA=mu_in_MA*ones(N+1,1);
    k_MA=k_in_MA*ones(N+1,1);
    Pr_MA=Pr_in_MA*ones(N+1,1);

    residual=NaN;

    for i=1:N

        segmentHeatTransfer()

        fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/N,...
        geometry_TL/N,h_TL(i),T_TL(i),mu_TL(i),k_TL(i),Pr_TL(i),props_TL,...
        geometry_MA/N,hbar_MA(i),cpbar_MA(i),mu_MA(i),k_MA(i),Pr_MA(i),props_MA);


        [xQ_int,~,exitflag(i)]=intervalSearch(fcn,...
        0,0.1,0.1,5,0.01,3,-inf,inf,opt_inner_search{:});

        if exitflag(i)==2

            xQ(i)=xQ_int(1);
        elseif exitflag(i)==1

            [xQ(i),~,exitflag(i)]=fzero(fcn,xQ_int,opt_inner_solve);
            if exitflag(i)<0
                return
            end
        else
            return
        end


        [~,Q_seg_calc(i),h_TL(i+1),T_TL(i+1),mu_TL(i+1),k_TL(i+1),Pr_TL(i+1),...
        hbar_MA(i+1),cpbar_MA(i+1),mu_MA(i+1),k_MA(i+1),Pr_MA(i+1)]=fcn(xQ(i));
    end


    residual=sum(Q_seg_calc)/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    T_TL_prev2=T_TL_prev1;
    hbar_MA_prev2=hbar_MA_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    T_TL_prev1=T_TL;
    hbar_MA_prev1=hbar_MA;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,T_TL,hbar_MA,exitflag]=heatTransferGrid(...
    xG,N,Q_nom,...
    geometry_TL_init,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
    geometry_MA_init,hbar_in_MA,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    T_TL_prev1 T_TL_prev2...
    hbar_MA_prev1 hbar_MA_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,N);Q_seg_calc_prev2=NaN(N,N);
        T_TL_prev1=NaN(N+1,N);T_TL_prev2=NaN(N+1,N);
        hbar_MA_prev1=NaN(N+1,N);hbar_MA_prev2=NaN(N+1,N);
        exitflag_prev1=NaN(N,N);exitflag_prev2=NaN(N,N);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        T_TL=T_TL_prev1;
        hbar_MA=hbar_MA_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        T_TL=T_TL_prev2;
        hbar_MA=hbar_MA_prev2;
        exitflag=exitflag_prev2;
        return
    end

    NN=N^2;


    geometry_TL=xG*geometry_TL_init;
    geometry_MA=xG*geometry_MA_init;



    xQ=ones(N,N);

    Q_seg_calc=zeros(N,N);
    exitflag=ones(N,N);

    h_TL=h_in_TL*ones(N+1,N);
    T_TL=T_in_TL*ones(N+1,N);
    mu_TL=mu_in_TL*ones(N+1,N);
    k_TL=k_in_TL*ones(N+1,N);
    Pr_TL=Pr_in_TL*ones(N+1,N);

    hbar_MA=hbar_in_MA*ones(N+1,N);
    cpbar_MA=cpbar_in_MA*ones(N+1,N);
    mu_MA=mu_in_MA*ones(N+1,N);
    k_MA=k_in_MA*ones(N+1,N);
    Pr_MA=Pr_in_MA*ones(N+1,N);

    residual=NaN;

    for j=1:N
        for i=1:N

            segmentHeatTransfer()

            fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/NN,...
            geometry_TL/NN,h_TL(i,j),T_TL(i,j),mu_TL(i,j),k_TL(i,j),Pr_TL(i,j),props_TL,...
            geometry_MA/NN,hbar_MA(j,i),cpbar_MA(j,i),mu_MA(j,i),k_MA(j,i),Pr_MA(j,i),props_MA);


            [xQ_int,~,exitflag(i,j)]=intervalSearch(fcn,...
            0,0.1,0.1,5,0.01,6,-inf,inf,opt_inner_search{:});

            if exitflag(i,j)==2

                xQ(i,j)=xQ_int(1);
            elseif exitflag(i,j)==1

                [xQ(i,j),~,exitflag(i,j)]=fzero(fcn,xQ_int,opt_inner_solve);
                if exitflag(i,j)<0
                    return
                end
            else
                return
            end


            [~,Q_seg_calc(i,j),h_TL(i+1,j),T_TL(i+1,j),mu_TL(i+1,j),k_TL(i+1,j),Pr_TL(i+1,j),...
            hbar_MA(j+1,i),cpbar_MA(j+1,i),mu_MA(j+1,i),k_MA(j+1,i),Pr_MA(j+1,i)]...
            =fcn(xQ(i,j));
        end
    end


    residual=sum(Q_seg_calc,'all')/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    T_TL_prev2=T_TL_prev1;
    hbar_MA_prev2=hbar_MA_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    T_TL_prev1=T_TL;
    hbar_MA_prev1=hbar_MA;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,h_out_TL,T_out_TL,mu_out_TL,k_out_TL,Pr_out_TL,...
    hbar_out_MA,cpbar_out_MA,mu_out_MA,k_out_MA,Pr_out_MA]=segmentHeatTransfer(xQ,Q_nom,...
    geometry_seg_TL,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL,...
    geometry_seg_MA,hbar_in_MA,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA)


    persistent...
    xQ_prev1 xQ_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_out_TL_prev1 h_out_TL_prev2...
    T_out_TL_prev1 T_out_TL_prev2...
    mu_out_TL_prev1 mu_out_TL_prev2...
    k_out_TL_prev1 k_out_TL_prev2...
    Pr_out_TL_prev1 Pr_out_TL_prev2...
    hbar_out_MA_prev1 hbar_out_MA_prev2...
    cpbar_out_MA_prev1 cpbar_out_MA_prev2...
    mu_out_MA_prev1 mu_out_MA_prev2...
    k_out_MA_prev1 k_out_MA_prev2...
    Pr_out_MA_prev1 Pr_out_MA_prev2
    if isempty(xQ_prev1)
        xQ_prev1=NaN;xQ_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN;Q_seg_calc_prev2=NaN;
        h_out_TL_prev1=NaN;h_out_TL_prev2=NaN;
        T_out_TL_prev1=NaN;T_out_TL_prev2=NaN;
        mu_out_TL_prev1=NaN;mu_out_TL_prev2=NaN;
        k_out_TL_prev1=NaN;k_out_TL_prev2=NaN;
        Pr_out_TL_prev1=NaN;Pr_out_TL_prev2=NaN;
        hbar_out_MA_prev1=NaN;hbar_out_MA_prev2=NaN;
        cpbar_out_MA_prev1=NaN;cpbar_out_MA_prev2=NaN;
        mu_out_MA_prev1=NaN;mu_out_MA_prev2=NaN;
        k_out_MA_prev1=NaN;k_out_MA_prev2=NaN;
        Pr_out_MA_prev1=NaN;Pr_out_MA_prev2=NaN;
    end
    if nargin==0
        xQ_prev1=NaN;xQ_prev2=NaN;
        return
    end


    if isfinite(xQ)&&isfinite(xQ_prev1)&&(xQ==xQ_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_out_TL=h_out_TL_prev1;
        T_out_TL=T_out_TL_prev1;
        mu_out_TL=mu_out_TL_prev1;
        k_out_TL=k_out_TL_prev1;
        Pr_out_TL=Pr_out_TL_prev1;
        hbar_out_MA=hbar_out_MA_prev1;
        cpbar_out_MA=cpbar_out_MA_prev1;
        mu_out_MA=mu_out_MA_prev1;
        k_out_MA=k_out_MA_prev1;
        Pr_out_MA=Pr_out_MA_prev1;
        return
    elseif isfinite(xQ)&&isfinite(xQ_prev2)&&(xQ==xQ_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_out_TL=h_out_TL_prev2;
        T_out_TL=T_out_TL_prev2;
        mu_out_TL=mu_out_TL_prev2;
        k_out_TL=k_out_TL_prev2;
        Pr_out_TL=Pr_out_TL_prev2;
        hbar_out_MA=hbar_out_MA_prev2;
        cpbar_out_MA=cpbar_out_MA_prev2;
        mu_out_MA=mu_out_MA_prev2;
        k_out_MA=k_out_MA_prev2;
        Pr_out_MA=Pr_out_MA_prev2;
        return
    end


    Q_seg_TL=-xQ*Q_nom;

    Q_seg_MA=xQ*Q_nom;


    [corr_term_TL,T_seg_TL,h_out_TL,T_out_TL,...
    mu_out_TL,k_out_TL,Pr_out_TL]=correlationTermsTL(...
    Q_seg_TL,h_in_TL,T_in_TL,mu_in_TL,k_in_TL,Pr_in_TL,props_TL);


    UA_seg_TL=corr_term_TL*geometry_seg_TL;


    T_wall=T_seg_TL+Q_seg_TL/UA_seg_TL;


    [corr_term_MA,hbar_seg_MA,cpbar_seg_MA,~,hbar_out_MA,cpbar_out_MA,...
    mu_out_MA,k_out_MA,Pr_out_MA]=correlationTermsDryMA(Q_seg_MA,...
    hbar_in_MA,cpbar_in_MA,mu_in_MA,k_in_MA,Pr_in_MA,props_MA);


    hbar_wall=interp1(props_MA.T_TLU,props_MA.hbar_in_TLU,T_wall,'linear','extrap');


    UA_seg_MA=corr_term_MA*geometry_seg_MA;


    Q_seg_MA_calc=UA_seg_MA*(hbar_wall-hbar_seg_MA)/cpbar_seg_MA;


    Q_seg_calc=Q_seg_MA_calc;


    residual=Q_seg_calc/Q_nom-xQ;


    xQ_prev2=xQ_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_out_TL_prev2=h_out_TL_prev1;
    T_out_TL_prev2=T_out_TL_prev1;
    mu_out_TL_prev2=mu_out_TL_prev1;
    k_out_TL_prev2=k_out_TL_prev1;
    Pr_out_TL_prev2=Pr_out_TL_prev1;
    hbar_out_MA_prev2=hbar_out_MA_prev1;
    cpbar_out_MA_prev2=cpbar_out_MA_prev1;
    mu_out_MA_prev2=mu_out_MA_prev1;
    k_out_MA_prev2=k_out_MA_prev1;
    Pr_out_MA_prev2=Pr_out_MA_prev1;

    xQ_prev1=xQ;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_out_TL_prev1=h_out_TL;
    T_out_TL_prev1=T_out_TL;
    mu_out_TL_prev1=mu_out_TL;
    k_out_TL_prev1=k_out_TL;
    Pr_out_TL_prev1=Pr_out_TL;
    hbar_out_MA_prev1=hbar_out_MA;
    cpbar_out_MA_prev1=cpbar_out_MA;
    mu_out_MA_prev1=mu_out_MA;
    k_out_MA_prev1=k_out_MA;
    Pr_out_MA_prev1=Pr_out_MA;

end