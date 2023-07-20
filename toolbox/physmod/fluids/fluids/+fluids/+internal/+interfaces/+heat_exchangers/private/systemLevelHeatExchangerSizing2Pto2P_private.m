








function[geometry_2P1,geometry_2P2,Q_seg_calc,...
    h_nodes_2P1,T_nodes_2P1,u_nodes_2P1,...
    wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,rho_avg_2P1,...
    h_nodes_2P2,T_nodes_2P2,u_nodes_2P2,...
    wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2,rho_avg_2P2,exitflag]...
    =systemLevelHeatExchangerSizing2Pto2P_private(flow_arrangement,Q_nom,...
    mdot_2P1,p_2P1,h_in_2P1,...
    u_TLU_2P1,v_TLU_2P1,T_TLU_2P1,nu_TLU_2P1,k_TLU_2P1,Pr_TLU_2P1,...
    idx_liq_2P1,idx_vap_2P1,a_liq_2P1,a_vap_2P1,a_mix_2P1,b_2P1,c_2P1,...
    D_ref_2P1,S_ref_2P1,Nu_lam_2P1,delta_h_thres_2P1,...
    mdot_2P2,p_2P2,h_in_2P2,...
    u_TLU_2P2,v_TLU_2P2,T_TLU_2P2,nu_TLU_2P2,k_TLU_2P2,Pr_TLU_2P2,...
    idx_liq_2P2,idx_vap_2P2,a_liq_2P2,a_vap_2P2,a_mix_2P2,b_2P2,c_2P2,...
    D_ref_2P2,S_ref_2P2,Nu_lam_2P2,delta_h_thres_2P2)

%#codegen
    coder.allowpcode('plain')


    N=3;


    xG_floor=1e-9;


    opt_outer_search={eps,500,'off'};
    opt_outer_solve=optimset('Display','off');
    opt_inner_search={eps,1000,'off'};
    opt_inner_solve=optimset('Display','off');


    [T_in_2P1,props_2P1]=preprocess2P(mdot_2P1,h_in_2P1,p_2P1,...
    u_TLU_2P1,v_TLU_2P1,T_TLU_2P1,nu_TLU_2P1,k_TLU_2P1,Pr_TLU_2P1,...
    idx_liq_2P1,idx_vap_2P1,a_liq_2P1,a_vap_2P1,a_mix_2P1,b_2P1,c_2P1,...
    D_ref_2P1,S_ref_2P1,Nu_lam_2P1,delta_h_thres_2P1);


    [T_in_2P2,props_2P2]=preprocess2P(mdot_2P2,h_in_2P2,p_2P2,...
    u_TLU_2P2,v_TLU_2P2,T_TLU_2P2,nu_TLU_2P2,k_TLU_2P2,Pr_TLU_2P2,...
    idx_liq_2P2,idx_vap_2P2,a_liq_2P2,a_vap_2P2,a_mix_2P2,b_2P2,c_2P2,...
    D_ref_2P2,S_ref_2P2,Nu_lam_2P2,delta_h_thres_2P2);


    [corr_term_2P1,T_seg_2P1,h_out_2P1,T_out_2P1]=correlationTerms2P(...
    -Q_nom,h_in_2P1,T_in_2P1,props_2P1);


    [corr_term_2P2,T_seg_2P2,h_out_2P2,T_out_2P2]...
    =correlationTerms2P(Q_nom,h_in_2P2,T_in_2P2,props_2P2);




    geometry_2P1=10;
    geometry_2P2=10;
    Q_seg_calc=Q_nom*ones(N,N);
    h_nodes_2P1=repmat(linspace(h_in_2P1,h_out_2P1,N+1)',1,N);
    T_nodes_2P1=repmat(linspace(T_in_2P1,T_out_2P1,N+1)',1,N);
    u_nodes_2P1=h_nodes_2P1;
    wgt_liq_seg_2P1=zeros(N,N);
    wgt_vap_seg_2P1=zeros(N,N);
    wgt_mix_seg_2P1=zeros(N,N);
    rho_avg_2P1=1;
    h_nodes_2P2=repmat(linspace(h_in_2P2,h_out_2P2,N+1)',1,N);
    T_nodes_2P2=repmat(linspace(T_in_2P2,T_out_2P2,N+1)',1,N);
    u_nodes_2P2=h_nodes_2P2;
    wgt_liq_seg_2P2=zeros(N,N);
    wgt_vap_seg_2P2=zeros(N,N);
    wgt_mix_seg_2P2=zeros(N,N);
    rho_avg_2P2=1;

    exitflag_inner=ones(N,N);


    if T_in_2P1<=T_in_2P2
        exitflag=-10;
        return
    elseif T_seg_2P1<=T_seg_2P2
        exitflag=-20;
        return
    end


    UA_overall=Q_nom/(T_seg_2P1-T_seg_2P2);



    geometry_2P1_init=2*UA_overall/corr_term_2P1;
    geometry_2P2_init=2*UA_overall/corr_term_2P2;

    if flow_arrangement==1

        if T_out_2P1<T_out_2P2
            exitflag=-13;
            return
        end


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_2P1_init,h_in_2P1,T_in_2P1,props_2P1,...
        geometry_2P2_init,h_in_2P2,T_in_2P2,props_2P2,...
        opt_inner_search,opt_inner_solve);


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


        [~,Q_seg_calc(:,1),h_nodes_2P1_tmp,T_nodes_2P1_tmp,...
        wgt_liq_seg_2P1_tmp,wgt_vap_seg_2P1_tmp,wgt_mix_seg_2P1_tmp,...
        h_nodes_2P2_tmp,T_nodes_2P2_tmp,...
        wgt_liq_seg_2P2_tmp,wgt_vap_seg_2P2_tmp,wgt_mix_seg_2P2_tmp,...
        exitflag_inner(:,1)]=fcn(xG);

        h_nodes_2P1=repmat(h_nodes_2P1_tmp,1,N);
        T_nodes_2P1=repmat(T_nodes_2P1_tmp,1,N);
        wgt_liq_seg_2P1=repmat(wgt_liq_seg_2P1_tmp,1,N);
        wgt_vap_seg_2P1=repmat(wgt_vap_seg_2P1_tmp,1,N);
        wgt_mix_seg_2P1=repmat(wgt_mix_seg_2P1_tmp,1,N);
        h_nodes_2P2=repmat(h_nodes_2P2_tmp,1,N);
        T_nodes_2P2=repmat(T_nodes_2P2_tmp,1,N);
        wgt_liq_seg_2P2=repmat(wgt_liq_seg_2P2_tmp,1,N);
        wgt_vap_seg_2P2=repmat(wgt_vap_seg_2P2_tmp,1,N);
        wgt_mix_seg_2P2=repmat(wgt_mix_seg_2P2_tmp,1,N);

    elseif flow_arrangement==2

        if T_out_2P1<T_in_2P2
            exitflag=-11;
            return
        elseif T_out_2P2>T_in_2P1
            exitflag=-12;
            return
        end


        props_2P2.mdot=-props_2P2.mdot;


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_2P1_init,h_in_2P1,T_in_2P1,props_2P1,...
        geometry_2P2_init,h_out_2P2,T_out_2P2,props_2P2,...
        opt_inner_search,opt_inner_solve);


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


        [~,Q_seg_calc(:,1),h_nodes_2P1_tmp,T_nodes_2P1_tmp,...
        wgt_liq_seg_2P1_tmp,wgt_vap_seg_2P1_tmp,wgt_mix_seg_2P1_tmp,...
        h_nodes_2P2_tmp,T_nodes_2P2_tmp,...
        wgt_liq_seg_2P2_tmp,wgt_vap_seg_2P2_tmp,wgt_mix_seg_2P2_tmp,...
        exitflag_inner(:,1)]=fcn(xG);

        h_nodes_2P1=repmat(h_nodes_2P1_tmp,1,N);
        T_nodes_2P1=repmat(T_nodes_2P1_tmp,1,N);
        wgt_liq_seg_2P1=repmat(wgt_liq_seg_2P1_tmp,1,N);
        wgt_vap_seg_2P1=repmat(wgt_vap_seg_2P1_tmp,1,N);
        wgt_mix_seg_2P1=repmat(wgt_mix_seg_2P1_tmp,1,N);
        h_nodes_2P2=repmat(h_nodes_2P2_tmp,1,N);
        T_nodes_2P2=repmat(T_nodes_2P2_tmp,1,N);
        wgt_liq_seg_2P2=repmat(wgt_liq_seg_2P2_tmp,1,N);
        wgt_vap_seg_2P2=repmat(wgt_vap_seg_2P2_tmp,1,N);
        wgt_mix_seg_2P2=repmat(wgt_mix_seg_2P2_tmp,1,N);


        h_nodes_2P2=flip(h_nodes_2P2,1);
        T_nodes_2P2=flip(T_nodes_2P2,1);
        wgt_liq_seg_2P2=flip(wgt_liq_seg_2P2,1);
        wgt_vap_seg_2P2=flip(wgt_vap_seg_2P2,1);
        wgt_mix_seg_2P2=flip(wgt_mix_seg_2P2,1);

    else


        if T_out_2P1<T_in_2P2
            exitflag=-11;
            return
        elseif T_out_2P2>T_in_2P1
            exitflag=-12;
            return
        end


        props_2P1.mdot=props_2P1.mdot/N;
        props_2P1.DS_ratio=props_2P1.DS_ratio*N;
        props_2P2.mdot=props_2P2.mdot/N;
        props_2P2.DS_ratio=props_2P2.DS_ratio*N;


        heatTransferGrid([],N)

        fcn=@(xG)heatTransferGrid(xG,N,Q_nom,...
        geometry_2P1_init,h_in_2P1,T_in_2P1,props_2P1,...
        geometry_2P2_init,h_in_2P2,T_in_2P2,props_2P2,...
        opt_inner_search,opt_inner_solve);


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


        [~,Q_seg_calc,h_nodes_2P1,T_nodes_2P1,wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,...
        h_nodes_2P2,T_nodes_2P2,wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2,...
        exitflag_inner]=fcn(xG);
    end

    if any(exitflag_inner<0)
        exitflag=-logspace(N^2-1,0,N^2)*abs(exitflag_inner(:));
        return
    end


    geometry_2P1=xG*geometry_2P1_init;
    geometry_2P2=xG*geometry_2P2_init;


    [rho_avg_2P1,u_nodes_2P1]=postprocess2P(h_nodes_2P1,...
    wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,props_2P1);


    [rho_avg_2P2,u_nodes_2P2]=postprocess2P(h_nodes_2P2,...
    wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2,props_2P2);

end





function[residual,Q_seg_calc,h_2P1,T_2P1,wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,...
    h_2P2,T_2P2,wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2,exitflag]...
    =heatTransferColinear(xG,N,Q_nom,...
    geometry_2P1_init,h_in_2P1,T_in_2P1,props_2P1,...
    geometry_2P2_init,h_in_2P2,T_in_2P2,props_2P2,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_2P1_prev1 h_2P1_prev2...
    T_2P1_prev1 T_2P1_prev2...
    wgt_liq_seg_2P1_prev1 wgt_liq_seg_2P1_prev2...
    wgt_vap_seg_2P1_prev1 wgt_vap_seg_2P1_prev2...
    wgt_mix_seg_2P1_prev1 wgt_mix_seg_2P1_prev2...
    h_2P2_prev1 h_2P2_prev2...
    T_2P2_prev1 T_2P2_prev2...
    wgt_liq_seg_2P2_prev1 wgt_liq_seg_2P2_prev2...
    wgt_vap_seg_2P2_prev1 wgt_vap_seg_2P2_prev2...
    wgt_mix_seg_2P2_prev1 wgt_mix_seg_2P2_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,1);Q_seg_calc_prev2=NaN(N,1);
        h_2P1_prev1=NaN(N+1,1);h_2P1_prev2=NaN(N+1,1);
        T_2P1_prev1=NaN(N+1,1);T_2P1_prev2=NaN(N+1,1);
        wgt_liq_seg_2P1_prev1=NaN(N,1);wgt_liq_seg_2P1_prev2=NaN(N,1);
        wgt_vap_seg_2P1_prev1=NaN(N,1);wgt_vap_seg_2P1_prev2=NaN(N,1);
        wgt_mix_seg_2P1_prev1=NaN(N,1);wgt_mix_seg_2P1_prev2=NaN(N,1);
        h_2P2_prev1=NaN(N+1,1);h_2P2_prev2=NaN(N+1,1);
        T_2P2_prev1=NaN(N+1,1);T_2P2_prev2=NaN(N+1,1);
        wgt_liq_seg_2P2_prev1=NaN(N,1);wgt_liq_seg_2P2_prev2=NaN(N,1);
        wgt_vap_seg_2P2_prev1=NaN(N,1);wgt_vap_seg_2P2_prev2=NaN(N,1);
        wgt_mix_seg_2P2_prev1=NaN(N,1);wgt_mix_seg_2P2_prev2=NaN(N,1);
        exitflag_prev1=NaN(N,1);exitflag_prev2=NaN(N,1);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_2P1=h_2P1_prev1;
        T_2P1=T_2P1_prev1;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev1;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev1;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev1;
        h_2P2=h_2P2_prev1;
        T_2P2=T_2P2_prev1;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev1;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev1;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_2P1=h_2P1_prev2;
        T_2P1=T_2P1_prev2;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev2;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev2;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev2;
        h_2P2=h_2P2_prev2;
        T_2P2=T_2P2_prev2;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev2;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev2;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev2;
        exitflag=exitflag_prev2;
        return
    end


    geometry_2P1=xG*geometry_2P1_init;
    geometry_2P2=xG*geometry_2P2_init;


    xQ=ones(N,1);

    Q_seg_calc=zeros(N,1);
    wgt_liq_seg_2P1=zeros(N,1);
    wgt_vap_seg_2P1=zeros(N,1);
    wgt_mix_seg_2P1=zeros(N,1);
    wgt_liq_seg_2P2=zeros(N,1);
    wgt_vap_seg_2P2=zeros(N,1);
    wgt_mix_seg_2P2=zeros(N,1);
    exitflag=ones(N,1);

    h_2P1=h_in_2P1*ones(N+1,1);
    T_2P1=T_in_2P1*ones(N+1,1);

    h_2P2=h_in_2P2*ones(N+1,1);
    T_2P2=T_in_2P2*ones(N+1,1);

    residual=NaN;

    for i=1:N

        segmentHeatTransfer()

        fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/N,...
        geometry_2P1/N,h_2P1(i),T_2P1(i),props_2P1,...
        geometry_2P2/N,h_2P2(i),T_2P2(i),props_2P2);


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


        [~,Q_seg_calc(i),h_2P1(i+1),T_2P1(i+1),...
        wgt_liq_seg_2P1(i),wgt_vap_seg_2P1(i),wgt_mix_seg_2P1(i),h_2P2(i+1),T_2P2(i+1),...
        wgt_liq_seg_2P2(i),wgt_vap_seg_2P2(i),wgt_mix_seg_2P2(i)]=fcn(xQ(i));
    end


    residual=sum(Q_seg_calc)/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_2P1_prev2=h_2P1_prev1;
    T_2P1_prev2=T_2P1_prev1;
    wgt_liq_seg_2P1_prev2=wgt_liq_seg_2P1_prev1;
    wgt_vap_seg_2P1_prev2=wgt_vap_seg_2P1_prev1;
    wgt_mix_seg_2P1_prev2=wgt_mix_seg_2P1_prev1;
    h_2P2_prev2=h_2P2_prev1;
    T_2P2_prev2=T_2P2_prev1;
    wgt_liq_seg_2P2_prev2=wgt_liq_seg_2P2_prev1;
    wgt_vap_seg_2P2_prev2=wgt_vap_seg_2P2_prev1;
    wgt_mix_seg_2P2_prev2=wgt_mix_seg_2P2_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_2P1_prev1=h_2P1;
    T_2P1_prev1=T_2P1;
    wgt_liq_seg_2P1_prev1=wgt_liq_seg_2P1;
    wgt_vap_seg_2P1_prev1=wgt_vap_seg_2P1;
    wgt_mix_seg_2P1_prev1=wgt_mix_seg_2P1;
    h_2P2_prev1=h_2P2;
    T_2P2_prev1=T_2P2;
    wgt_liq_seg_2P2_prev1=wgt_liq_seg_2P2;
    wgt_vap_seg_2P2_prev1=wgt_vap_seg_2P2;
    wgt_mix_seg_2P2_prev1=wgt_mix_seg_2P2;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,h_2P1,T_2P1,wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,...
    h_2P2,T_2P2,wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2,exitflag]...
    =heatTransferGrid(xG,N,Q_nom,...
    geometry_2P1_init,h_in_2P1,T_in_2P1,props_2P1,...
    geometry_2P2_init,h_in_2P2,T_in_2P2,props_2P2,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_2P1_prev1 h_2P1_prev2...
    T_2P1_prev1 T_2P1_prev2...
    wgt_liq_seg_2P1_prev1 wgt_liq_seg_2P1_prev2...
    wgt_vap_seg_2P1_prev1 wgt_vap_seg_2P1_prev2...
    wgt_mix_seg_2P1_prev1 wgt_mix_seg_2P1_prev2...
    h_2P2_prev1 h_2P2_prev2...
    T_2P2_prev1 T_2P2_prev2...
    wgt_liq_seg_2P2_prev1 wgt_liq_seg_2P2_prev2...
    wgt_vap_seg_2P2_prev1 wgt_vap_seg_2P2_prev2...
    wgt_mix_seg_2P2_prev1 wgt_mix_seg_2P2_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,N);Q_seg_calc_prev2=NaN(N,N);
        h_2P1_prev1=NaN(N+1,N);h_2P1_prev2=NaN(N+1,N);
        T_2P1_prev1=NaN(N+1,N);T_2P1_prev2=NaN(N+1,N);
        wgt_liq_seg_2P1_prev1=NaN(N,N);wgt_liq_seg_2P1_prev2=NaN(N,N);
        wgt_vap_seg_2P1_prev1=NaN(N,N);wgt_vap_seg_2P1_prev2=NaN(N,N);
        wgt_mix_seg_2P1_prev1=NaN(N,N);wgt_mix_seg_2P1_prev2=NaN(N,N);
        h_2P2_prev1=NaN(N+1,N);h_2P2_prev2=NaN(N+1,N);
        T_2P2_prev1=NaN(N+1,N);T_2P2_prev2=NaN(N+1,N);
        wgt_liq_seg_2P2_prev1=NaN(N,N);wgt_liq_seg_2P2_prev2=NaN(N,N);
        wgt_vap_seg_2P2_prev1=NaN(N,N);wgt_vap_seg_2P2_prev2=NaN(N,N);
        wgt_mix_seg_2P2_prev1=NaN(N,N);wgt_mix_seg_2P2_prev2=NaN(N,N);
        exitflag_prev1=NaN(N,N);exitflag_prev2=NaN(N,N);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_2P1=h_2P1_prev1;
        T_2P1=T_2P1_prev1;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev1;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev1;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev1;
        h_2P2=h_2P2_prev1;
        T_2P2=T_2P2_prev1;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev1;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev1;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_2P1=h_2P1_prev2;
        T_2P1=T_2P1_prev2;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev2;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev2;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev2;
        h_2P2=h_2P2_prev2;
        T_2P2=T_2P2_prev2;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev2;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev2;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev2;
        exitflag=exitflag_prev2;
        return
    end


    geometry_2P1=xG*geometry_2P1_init;
    geometry_2P2=xG*geometry_2P2_init;

    NN=N^2;



    xQ=ones(N,N);

    Q_seg_calc=zeros(N,N);
    wgt_liq_seg_2P1=zeros(N,N);
    wgt_vap_seg_2P1=zeros(N,N);
    wgt_mix_seg_2P1=zeros(N,N);
    wgt_liq_seg_2P2=zeros(N,N);
    wgt_vap_seg_2P2=zeros(N,N);
    wgt_mix_seg_2P2=zeros(N,N);
    exitflag=ones(N,N);

    h_2P1=h_in_2P1*ones(N+1,N);
    T_2P1=T_in_2P1*ones(N+1,N);

    h_2P2=h_in_2P2*ones(N+1,N);
    T_2P2=T_in_2P2*ones(N+1,N);

    residual=NaN;

    for j=1:N
        for i=1:N

            segmentHeatTransfer()

            fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/NN,...
            geometry_2P1/NN,h_2P1(i,j),T_2P1(i,j),props_2P1,...
            geometry_2P2/NN,h_2P2(j,i),T_2P2(j,i),props_2P2);


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


            [residual,Q_seg_calc(i,j),h_2P1(i+1,j),T_2P1(i+1,j),...
            wgt_liq_seg_2P1(i,j),wgt_vap_seg_2P1(i,j),wgt_mix_seg_2P1(i,j),h_2P2(j+1,i),T_2P2(j+1,i),...
            wgt_liq_seg_2P2(j,i),wgt_vap_seg_2P2(j,i),wgt_mix_seg_2P2(j,i)]=fcn(xQ(i,j));
        end
    end


    residual=sum(Q_seg_calc,'all')/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_2P1_prev2=h_2P1_prev1;
    T_2P1_prev2=T_2P1_prev1;
    wgt_liq_seg_2P1_prev2=wgt_liq_seg_2P1_prev1;
    wgt_vap_seg_2P1_prev2=wgt_vap_seg_2P1_prev1;
    wgt_mix_seg_2P1_prev2=wgt_mix_seg_2P1_prev1;
    h_2P2_prev2=h_2P2_prev1;
    T_2P2_prev2=T_2P2_prev1;
    wgt_liq_seg_2P2_prev2=wgt_liq_seg_2P2_prev1;
    wgt_vap_seg_2P2_prev2=wgt_vap_seg_2P2_prev1;
    wgt_mix_seg_2P2_prev2=wgt_mix_seg_2P2_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_2P1_prev1=h_2P1;
    T_2P1_prev1=T_2P1;
    wgt_liq_seg_2P1_prev1=wgt_liq_seg_2P1;
    wgt_vap_seg_2P1_prev1=wgt_vap_seg_2P1;
    wgt_mix_seg_2P1_prev1=wgt_mix_seg_2P1;
    h_2P2_prev1=h_2P2;
    T_2P2_prev1=T_2P2;
    wgt_liq_seg_2P2_prev1=wgt_liq_seg_2P2;
    wgt_vap_seg_2P2_prev1=wgt_vap_seg_2P2;
    wgt_mix_seg_2P2_prev1=wgt_mix_seg_2P2;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,h_out_2P1,T_out_2P1,...
    wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1,h_out_2P2,T_out_2P2,...
    wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2]=segmentHeatTransfer(xQ,Q_nom,...
    geometry_seg_2P1,h_in_2P1,T_in_2P1,props_2P1,...
    geometry_seg_2P2,h_in_2P2,T_in_2P2,props_2P2)


    persistent...
    xQ_prev1 xQ_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_out_2P1_prev1 h_out_2P1_prev2...
    T_out_2P1_prev1 T_out_2P1_prev2...
    wgt_liq_seg_2P1_prev1 wgt_liq_seg_2P1_prev2...
    wgt_vap_seg_2P1_prev1 wgt_vap_seg_2P1_prev2...
    wgt_mix_seg_2P1_prev1 wgt_mix_seg_2P1_prev2...
    h_out_2P2_prev1 h_out_2P2_prev2...
    T_out_2P2_prev1 T_out_2P2_prev2...
    wgt_liq_seg_2P2_prev1 wgt_liq_seg_2P2_prev2...
    wgt_vap_seg_2P2_prev1 wgt_vap_seg_2P2_prev2...
    wgt_mix_seg_2P2_prev1 wgt_mix_seg_2P2_prev2
    if isempty(xQ_prev1)
        xQ_prev1=NaN;xQ_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN;Q_seg_calc_prev2=NaN;
        h_out_2P1_prev1=NaN;h_out_2P1_prev2=NaN;
        T_out_2P1_prev1=NaN;T_out_2P1_prev2=NaN;
        wgt_liq_seg_2P1_prev1=NaN;wgt_liq_seg_2P1_prev2=NaN;
        wgt_vap_seg_2P1_prev1=NaN;wgt_vap_seg_2P1_prev2=NaN;
        wgt_mix_seg_2P1_prev1=NaN;wgt_mix_seg_2P1_prev2=NaN;
        h_out_2P2_prev1=NaN;h_out_2P2_prev2=NaN;
        T_out_2P2_prev1=NaN;T_out_2P2_prev2=NaN;
        wgt_liq_seg_2P2_prev1=NaN;wgt_liq_seg_2P2_prev2=NaN;
        wgt_vap_seg_2P2_prev1=NaN;wgt_vap_seg_2P2_prev2=NaN;
        wgt_mix_seg_2P2_prev1=NaN;wgt_mix_seg_2P2_prev2=NaN;
    end
    if nargin==0
        xQ_prev1=NaN;xQ_prev2=NaN;
        return
    end


    if isfinite(xQ)&&isfinite(xQ_prev1)&&(xQ==xQ_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_out_2P1=h_out_2P1_prev1;
        T_out_2P1=T_out_2P1_prev1;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev1;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev1;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev1;
        h_out_2P2=h_out_2P2_prev1;
        T_out_2P2=T_out_2P2_prev1;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev1;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev1;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev1;
        return
    elseif isfinite(xQ)&&isfinite(xQ_prev2)&&(xQ==xQ_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_out_2P1=h_out_2P1_prev2;
        T_out_2P1=T_out_2P1_prev2;
        wgt_liq_seg_2P1=wgt_liq_seg_2P1_prev2;
        wgt_vap_seg_2P1=wgt_vap_seg_2P1_prev2;
        wgt_mix_seg_2P1=wgt_mix_seg_2P1_prev2;
        h_out_2P2=h_out_2P2_prev2;
        T_out_2P2=T_out_2P2_prev2;
        wgt_liq_seg_2P2=wgt_liq_seg_2P2_prev2;
        wgt_vap_seg_2P2=wgt_vap_seg_2P2_prev2;
        wgt_mix_seg_2P2=wgt_mix_seg_2P2_prev2;
        return
    end


    Q_seg_2P1=-xQ*Q_nom;

    Q_seg_2P2=xQ*Q_nom;


    [corr_term_2P1,T_seg_2P1,h_out_2P1,T_out_2P1,wgt_liq_seg_2P1,wgt_vap_seg_2P1,wgt_mix_seg_2P1]...
    =correlationTerms2P(Q_seg_2P1,h_in_2P1,T_in_2P1,props_2P1);


    UA_seg_2P1=corr_term_2P1*geometry_seg_2P1;


    [corr_term_2P2,T_seg_2P2,h_out_2P2,T_out_2P2,wgt_liq_seg_2P2,wgt_vap_seg_2P2,wgt_mix_seg_2P2]...
    =correlationTerms2P(Q_seg_2P2,h_in_2P2,T_in_2P2,props_2P2);


    UA_seg_2P2=corr_term_2P2*geometry_seg_2P2;


    UA_seg_overall=1/(1/UA_seg_2P1+1/UA_seg_2P2);


    Q_seg_calc=UA_seg_overall*(T_seg_2P1-T_seg_2P2);


    residual=Q_seg_calc/Q_nom-xQ;


    xQ_prev2=xQ_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_out_2P1_prev2=h_out_2P1_prev1;
    T_out_2P1_prev2=T_out_2P1_prev1;
    wgt_liq_seg_2P1_prev2=wgt_liq_seg_2P1_prev1;
    wgt_vap_seg_2P1_prev2=wgt_vap_seg_2P1_prev1;
    wgt_mix_seg_2P1_prev2=wgt_mix_seg_2P1_prev1;
    h_out_2P2_prev2=h_out_2P2_prev1;
    T_out_2P2_prev2=T_out_2P2_prev1;
    wgt_liq_seg_2P2_prev2=wgt_liq_seg_2P2_prev1;
    wgt_vap_seg_2P2_prev2=wgt_vap_seg_2P2_prev1;
    wgt_mix_seg_2P2_prev2=wgt_mix_seg_2P2_prev1;

    xQ_prev1=xQ;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_out_2P1_prev1=h_out_2P1;
    T_out_2P1_prev1=T_out_2P1;
    wgt_liq_seg_2P1_prev1=wgt_liq_seg_2P1;
    wgt_vap_seg_2P1_prev1=wgt_vap_seg_2P1;
    wgt_mix_seg_2P1_prev1=wgt_mix_seg_2P1;
    h_out_2P2_prev1=h_out_2P2;
    T_out_2P2_prev1=T_out_2P2;
    wgt_liq_seg_2P2_prev1=wgt_liq_seg_2P2;
    wgt_vap_seg_2P2_prev1=wgt_vap_seg_2P2;
    wgt_mix_seg_2P2_prev1=wgt_mix_seg_2P2;

end