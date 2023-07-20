









function[geometry_2P,geometry_MA,Q_seg_calc,h_nodes_2P,T_nodes_2P,u_nodes_2P,...
    wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,rho_avg_2P,...
    T_nodes_MA,x_w_nodes_MA,x_g_nodes_MA,condensation_MA,v_avg_MA,exitflag]...
    =systemLevelHeatExchangerSizingMAto2P_private(flow_arrangement,Q_nom,...
    mdot_2P,p_2P,h_in_2P,...
    u_TLU_2P,v_TLU_2P,T_TLU_2P,nu_TLU_2P,k_TLU_2P,Pr_TLU_2P,...
    idx_liq_2P,idx_vap_2P,a_liq_2P,a_vap_2P,a_mix_2P,b_2P,c_2P,...
    D_ref_2P,S_ref_2P,Nu_lam_2P,delta_h_thres_2P,...
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


    [T_in_2P,props_2P]=preprocess2P(mdot_2P,h_in_2P,p_2P,...
    u_TLU_2P,v_TLU_2P,T_TLU_2P,nu_TLU_2P,k_TLU_2P,Pr_TLU_2P,...
    idx_liq_2P,idx_vap_2P,a_liq_2P,a_vap_2P,a_mix_2P,b_2P,c_2P,...
    D_ref_2P,S_ref_2P,Nu_lam_2P,delta_h_thres_2P);


    [hbar_in_MA,HR_in_MA,~,~,~,~,props_MA]=preprocessMA(mdot_MA,p_MA,T_in_MA,...
    x_w_in_MA,x_g_in_MA,R_a_MA,R_w_MA,R_g_MA,T_TLU_MA,log_p_ws_TLU_MA,h_w_vap_TLU_MA,...
    h_a_TLU_MA,h_w_TLU_MA,h_g_TLU_MA,cp_a_coeff_MA,cp_w_coeff_MA,cp_g_coeff_MA,...
    mu_a_TLU_MA,mu_w_TLU_MA,mu_g_TLU_MA,k_a_TLU_MA,k_w_TLU_MA,k_g_TLU_MA,...
    Pr_a_TLU_MA,Pr_w_TLU_MA,Pr_g_TLU_MA,RH_ws_MA,x_ag_min_MA,...
    a_MA,b_MA,c_MA,D_ref_MA,S_ref_MA,Nu_lam_MA);


    [corr_term_2P,T_seg_2P,h_out_2P,T_out_2P]...
    =correlationTerms2P(Q_nom,h_in_2P,T_in_2P,props_2P);


    [corr_term_MA,~,~,T_in_MA,T_out_MA]=correlationTermsWetMA(...
    -Q_nom,hbar_in_MA,HR_in_MA,props_MA);


    T_seg_MA=(T_in_MA+T_out_MA)/2;




    geometry_2P=10;
    geometry_MA=10;
    Q_seg_calc=Q_nom*ones(N,N);
    h_nodes_2P=repmat(linspace(h_in_2P,h_out_2P,N+1)',1,N);
    T_nodes_2P=repmat(linspace(T_in_2P,T_out_2P,N+1)',1,N);
    u_nodes_2P=h_nodes_2P;
    wgt_liq_seg_2P=zeros(N,N);
    wgt_vap_seg_2P=zeros(N,N);
    wgt_mix_seg_2P=zeros(N,N);
    rho_avg_2P=1;
    T_nodes_MA=repmat(linspace(T_in_MA,T_out_MA,N+1)',1,N);
    x_w_nodes_MA=x_w_in_MA*ones(N+1,N);
    x_g_nodes_MA=x_g_in_MA*ones(N+1,N);
    condensation_MA=zeros(N,N);
    v_avg_MA=1;

    exitflag_inner=ones(N,N);


    if T_in_MA<=T_in_2P
        exitflag=-10;
        return
    elseif T_seg_MA<=T_seg_2P
        exitflag=-20;
        return
    end


    UA_overall=Q_nom/(T_seg_MA-T_seg_2P);



    geometry_2P_init=2*UA_overall/corr_term_2P;
    geometry_MA_init=2*UA_overall/corr_term_MA;

    if flow_arrangement==1



        if T_out_2P>T_in_MA
            exitflag=-11;
            return
        end


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_2P_init,h_in_2P,T_in_2P,props_2P,...
        geometry_MA_init,hbar_in_MA,HR_in_MA,props_MA,...
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


        [~,Q_seg_calc(:,1),h_nodes_2P_tmp,T_nodes_2P_tmp,...
        wgt_liq_seg_2P_tmp,wgt_vap_seg_2P_tmp,wgt_mix_seg_2P_tmp,...
        hbar_nodes_MA_tmp,HR_nodes_MA_tmp,exitflag_inner(:,1)]=fcn(xG);

        h_nodes_2P=repmat(h_nodes_2P_tmp,1,N);
        T_nodes_2P=repmat(T_nodes_2P_tmp,1,N);
        wgt_liq_seg_2P=repmat(wgt_liq_seg_2P_tmp,1,N);
        wgt_vap_seg_2P=repmat(wgt_vap_seg_2P_tmp,1,N);
        wgt_mix_seg_2P=repmat(wgt_mix_seg_2P_tmp,1,N);
        hbar_nodes_MA=repmat(hbar_nodes_MA_tmp,1,N);
        HR_nodes_MA=repmat(HR_nodes_MA_tmp,1,N);

    elseif flow_arrangement==2



        if T_out_2P>T_in_MA
            exitflag=-11;
            return
        end


        props_2P.mdot=-props_2P.mdot;


        heatTransferColinear([],N)

        fcn=@(xG)heatTransferColinear(xG,N,Q_nom,...
        geometry_2P_init,h_out_2P,T_out_2P,props_2P,...
        geometry_MA_init,hbar_in_MA,HR_in_MA,props_MA,...
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


        [~,Q_seg_calc(:,1),h_nodes_2P_tmp,T_nodes_2P_tmp,...
        wgt_liq_seg_2P_tmp,wgt_vap_seg_2P_tmp,wgt_mix_seg_2P_tmp,...
        hbar_nodes_MA_tmp,HR_nodes_MA_tmp,exitflag_inner(:,1)]=fcn(xG);

        h_nodes_2P=repmat(h_nodes_2P_tmp,1,N);
        T_nodes_2P=repmat(T_nodes_2P_tmp,1,N);
        wgt_liq_seg_2P=repmat(wgt_liq_seg_2P_tmp,1,N);
        wgt_vap_seg_2P=repmat(wgt_vap_seg_2P_tmp,1,N);
        wgt_mix_seg_2P=repmat(wgt_mix_seg_2P_tmp,1,N);
        hbar_nodes_MA=repmat(hbar_nodes_MA_tmp,1,N);
        HR_nodes_MA=repmat(HR_nodes_MA_tmp,1,N);


        h_nodes_2P=flip(h_nodes_2P,1);
        T_nodes_2P=flip(T_nodes_2P,1);
        wgt_liq_seg_2P=flip(wgt_liq_seg_2P,1);
        wgt_vap_seg_2P=flip(wgt_vap_seg_2P,1);
        wgt_mix_seg_2P=flip(wgt_mix_seg_2P,1);

    else




        if T_out_2P>T_in_MA
            exitflag=-11;
            return
        end


        props_2P.mdot=props_2P.mdot/N;
        props_2P.DS_ratio=props_2P.DS_ratio*N;
        props_MA.mdot_in=props_MA.mdot_in/N;
        props_MA.mdot_ag=props_MA.mdot_ag/N;
        props_MA.DS_ratio=props_MA.DS_ratio*N;


        heatTransferGrid([],N)

        fcn=@(xG)heatTransferGrid(xG,N,Q_nom,...
        geometry_2P_init,h_in_2P,T_in_2P,props_2P,...
        geometry_MA_init,hbar_in_MA,HR_in_MA,props_MA,...
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


        [~,Q_seg_calc,h_nodes_2P,T_nodes_2P,wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,...
        hbar_nodes_MA,HR_nodes_MA,exitflag_inner]=fcn(xG);
    end

    if any(exitflag_inner<0)
        exitflag=-logspace(N^2-1,0,N^2)*abs(exitflag_inner(:));
        return
    end


    geometry_2P=xG*geometry_2P_init;
    geometry_MA=xG*geometry_MA_init;


    condensation_MA=-props_MA.mdot_ag*diff(HR_nodes_MA,1,1);


    [rho_avg_2P,u_nodes_2P]=postprocess2P(h_nodes_2P,...
    wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,props_2P);


    [v_avg_MA,T_nodes_MA,x_w_nodes_MA,x_g_nodes_MA,T_out_avg_MA]=postprocessMA(...
    hbar_nodes_MA,HR_nodes_MA,props_MA);

    if flow_arrangement==1
        if T_out_avg_MA<T_out_2P
            exitflag=-13;
        end
    else
        if T_out_avg_MA<T_in_2P
            exitflag=-12;
        end
    end

end





function[residual,Q_seg_calc,h_2P,T_2P,wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,...
    hbar_MA,HR_MA,exitflag]=heatTransferColinear(xG,N,Q_nom,...
    geometry_2P_init,h_in_2P,T_in_2P,props_2P,...
    geometry_MA_init,hbar_in_MA,HR_in_MA,props_MA,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_2P_prev1 h_2P_prev2...
    T_2P_prev1 T_2P_prev2...
    wgt_liq_seg_2P_prev1 wgt_liq_seg_2P_prev2...
    wgt_vap_seg_2P_prev1 wgt_vap_seg_2P_prev2...
    wgt_mix_seg_2P_prev1 wgt_mix_seg_2P_prev2...
    hbar_MA_prev1 hbar_MA_prev2...
    HR_MA_prev1 HR_MA_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,1);Q_seg_calc_prev2=NaN(N,1);
        h_2P_prev1=NaN(N+1,1);h_2P_prev2=NaN(N+1,1);
        T_2P_prev1=NaN(N+1,1);T_2P_prev2=NaN(N+1,1);
        wgt_liq_seg_2P_prev1=NaN(N,1);wgt_liq_seg_2P_prev2=NaN(N,1);
        wgt_vap_seg_2P_prev1=NaN(N,1);wgt_vap_seg_2P_prev2=NaN(N,1);
        wgt_mix_seg_2P_prev1=NaN(N,1);wgt_mix_seg_2P_prev2=NaN(N,1);
        hbar_MA_prev1=NaN(N+1,1);hbar_MA_prev2=NaN(N+1,1);
        HR_MA_prev1=NaN(N+1,1);HR_MA_prev2=NaN(N+1,1);
        exitflag_prev1=NaN(N,1);exitflag_prev2=NaN(N,1);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_2P=h_2P_prev1;
        T_2P=T_2P_prev1;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev1;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev1;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev1;
        hbar_MA=hbar_MA_prev1;
        HR_MA=HR_MA_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_2P=h_2P_prev2;
        T_2P=T_2P_prev2;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev2;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev2;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev2;
        hbar_MA=hbar_MA_prev2;
        HR_MA=HR_MA_prev2;
        exitflag=exitflag_prev2;
        return
    end


    geometry_2P=xG*geometry_2P_init;
    geometry_MA=xG*geometry_MA_init;


    xQ=ones(N,1);

    Q_seg_calc=zeros(N,1);
    wgt_liq_seg_2P=zeros(N,1);
    wgt_vap_seg_2P=zeros(N,1);
    wgt_mix_seg_2P=zeros(N,1);
    exitflag=ones(N,1);

    h_2P=h_in_2P*ones(N+1,1);
    T_2P=T_in_2P*ones(N+1,1);

    hbar_MA=hbar_in_MA*ones(N+1,1);
    HR_MA=HR_in_MA*ones(N+1,1);

    residual=NaN;

    for i=1:N

        segmentHeatTransfer()

        fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/N,...
        geometry_2P/N,h_2P(i),T_2P(i),props_2P,...
        geometry_MA/N,hbar_MA(i),HR_MA(i),props_MA);


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


        [~,Q_seg_calc(i),h_2P(i+1),T_2P(i+1),wgt_liq_seg_2P(i),wgt_vap_seg_2P(i),wgt_mix_seg_2P(i),...
        hbar_MA(i+1),HR_MA(i+1)]=fcn(xQ(i));
    end


    residual=sum(Q_seg_calc)/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_2P_prev2=h_2P_prev1;
    T_2P_prev2=T_2P_prev1;
    wgt_liq_seg_2P_prev2=wgt_liq_seg_2P_prev1;
    wgt_vap_seg_2P_prev2=wgt_vap_seg_2P_prev1;
    wgt_mix_seg_2P_prev2=wgt_mix_seg_2P_prev1;
    hbar_MA_prev2=hbar_MA_prev1;
    HR_MA_prev2=HR_MA_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_2P_prev1=h_2P;
    T_2P_prev1=T_2P;
    wgt_liq_seg_2P_prev1=wgt_liq_seg_2P;
    wgt_vap_seg_2P_prev1=wgt_vap_seg_2P;
    wgt_mix_seg_2P_prev1=wgt_mix_seg_2P;
    hbar_MA_prev1=hbar_MA;
    HR_MA_prev1=HR_MA;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,h_2P,T_2P,wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,...
    hbar_MA,HR_MA,exitflag]=heatTransferGrid(xG,N,Q_nom,...
    geometry_2P_init,h_in_2P,T_in_2P,props_2P,...
    geometry_MA_init,hbar_in_MA,HR_in_MA,props_MA,...
    opt_inner_search,opt_inner_solve)


    persistent...
    xG_prev1 xG_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_2P_prev1 h_2P_prev2...
    T_2P_prev1 T_2P_prev2...
    wgt_liq_seg_2P_prev1 wgt_liq_seg_2P_prev2...
    wgt_vap_seg_2P_prev1 wgt_vap_seg_2P_prev2...
    wgt_mix_seg_2P_prev1 wgt_mix_seg_2P_prev2...
    hbar_MA_prev1 hbar_MA_prev2...
    HR_MA_prev1 HR_MA_prev2...
    exitflag_prev1 exitflag_prev2
    if isempty(xG_prev1)
        xG_prev1=NaN;xG_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN(N,N);Q_seg_calc_prev2=NaN(N,N);
        h_2P_prev1=NaN(N+1,N);h_2P_prev2=NaN(N+1,N);
        T_2P_prev1=NaN(N+1,N);T_2P_prev2=NaN(N+1,N);
        wgt_liq_seg_2P_prev1=NaN(N,N);wgt_liq_seg_2P_prev2=NaN(N,N);
        wgt_vap_seg_2P_prev1=NaN(N,N);wgt_vap_seg_2P_prev2=NaN(N,N);
        wgt_mix_seg_2P_prev1=NaN(N,N);wgt_mix_seg_2P_prev2=NaN(N,N);
        hbar_MA_prev1=NaN(N+1,N);hbar_MA_prev2=NaN(N+1,N);
        HR_MA_prev1=NaN(N+1,N);HR_MA_prev2=NaN(N+1,N);
        exitflag_prev1=NaN(N,N);exitflag_prev2=NaN(N,N);
    end
    if nargin<=2
        xG_prev1=NaN;xG_prev2=NaN;
        return
    end


    if isfinite(xG)&&isfinite(xG_prev1)&&(xG==xG_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_2P=h_2P_prev1;
        T_2P=T_2P_prev1;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev1;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev1;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev1;
        hbar_MA=hbar_MA_prev1;
        HR_MA=HR_MA_prev1;
        exitflag=exitflag_prev1;
        return
    elseif isfinite(xG)&&isfinite(xG_prev2)&&(xG==xG_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_2P=h_2P_prev2;
        T_2P=T_2P_prev2;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev2;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev2;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev2;
        hbar_MA=hbar_MA_prev2;
        HR_MA=HR_MA_prev2;
        exitflag=exitflag_prev2;
        return
    end

    NN=N^2;


    geometry_2P=xG*geometry_2P_init;
    geometry_MA=xG*geometry_MA_init;



    xQ=ones(N,N);

    Q_seg_calc=zeros(N,N);
    wgt_liq_seg_2P=zeros(N,N);
    wgt_vap_seg_2P=zeros(N,N);
    wgt_mix_seg_2P=zeros(N,N);
    exitflag=ones(N,N);

    h_2P=h_in_2P*ones(N+1,N);
    T_2P=T_in_2P*ones(N+1,N);

    hbar_MA=hbar_in_MA*ones(N+1,N);
    HR_MA=HR_in_MA*ones(N+1,N);

    residual=NaN;

    for j=1:N
        for i=1:N

            segmentHeatTransfer()

            fcn=@(xQ)segmentHeatTransfer(xQ,Q_nom/NN,...
            geometry_2P/NN,h_2P(i,j),T_2P(i,j),props_2P,...
            geometry_MA/NN,hbar_MA(j,i),HR_MA(j,i),props_MA);


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


            [~,Q_seg_calc(i,j),h_2P(i+1,j),T_2P(i+1,j),...
            wgt_liq_seg_2P(i,j),wgt_vap_seg_2P(i,j),wgt_mix_seg_2P(i,j),...
            hbar_MA(j+1,i),HR_MA(j+1,i)]=fcn(xQ(i,j));
        end
    end


    residual=sum(Q_seg_calc,'all')/Q_nom-1;


    xG_prev2=xG_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_2P_prev2=h_2P_prev1;
    T_2P_prev2=T_2P_prev1;
    wgt_liq_seg_2P_prev2=wgt_liq_seg_2P_prev1;
    wgt_vap_seg_2P_prev2=wgt_vap_seg_2P_prev1;
    wgt_mix_seg_2P_prev2=wgt_mix_seg_2P_prev1;
    hbar_MA_prev2=hbar_MA_prev1;
    HR_MA_prev2=HR_MA_prev1;
    exitflag_prev2=exitflag_prev1;

    xG_prev1=xG;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_2P_prev1=h_2P;
    T_2P_prev1=T_2P;
    wgt_liq_seg_2P_prev1=wgt_liq_seg_2P;
    wgt_vap_seg_2P_prev1=wgt_vap_seg_2P;
    wgt_mix_seg_2P_prev1=wgt_mix_seg_2P;
    hbar_MA_prev1=hbar_MA;
    HR_MA_prev1=HR_MA;
    exitflag_prev1=exitflag;

end





function[residual,Q_seg_calc,h_out_2P,T_out_2P,...
    wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P,...
    hbar_out_MA,HR_out_MA]=segmentHeatTransfer(xQ,Q_nom,...
    geometry_seg_2P,h_in_2P,T_in_2P,props_2P,...
    geometry_seg_MA,hbar_in_MA,HR_in_MA,props_MA)


    persistent...
    xQ_prev1 xQ_prev2...
    residual_prev1 residual_prev2...
    Q_seg_calc_prev1 Q_seg_calc_prev2...
    h_out_2P_prev1 h_out_2P_prev2...
    T_out_2P_prev1 T_out_2P_prev2...
    wgt_liq_seg_2P_prev1 wgt_liq_seg_2P_prev2...
    wgt_vap_seg_2P_prev1 wgt_vap_seg_2P_prev2...
    wgt_mix_seg_2P_prev1 wgt_mix_seg_2P_prev2...
    hbar_out_MA_prev1 hbar_out_MA_prev2...
    HR_out_MA_prev1 HR_out_MA_prev2
    if isempty(xQ_prev1)
        xQ_prev1=NaN;xQ_prev2=NaN;
        residual_prev1=NaN;residual_prev2=NaN;
        Q_seg_calc_prev1=NaN;Q_seg_calc_prev2=NaN;
        h_out_2P_prev1=NaN;h_out_2P_prev2=NaN;
        T_out_2P_prev1=NaN;T_out_2P_prev2=NaN;
        wgt_liq_seg_2P_prev1=NaN;wgt_liq_seg_2P_prev2=NaN;
        wgt_vap_seg_2P_prev1=NaN;wgt_vap_seg_2P_prev2=NaN;
        wgt_mix_seg_2P_prev1=NaN;wgt_mix_seg_2P_prev2=NaN;
        hbar_out_MA_prev1=NaN;hbar_out_MA_prev2=NaN;
        HR_out_MA_prev1=NaN;HR_out_MA_prev2=NaN;
    end
    if nargin==0
        xQ_prev1=NaN;xQ_prev2=NaN;
        return
    end


    if isfinite(xQ)&&isfinite(xQ_prev1)&&(xQ==xQ_prev1)
        residual=residual_prev1;
        Q_seg_calc=Q_seg_calc_prev1;
        h_out_2P=h_out_2P_prev1;
        T_out_2P=T_out_2P_prev1;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev1;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev1;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev1;
        hbar_out_MA=hbar_out_MA_prev1;
        HR_out_MA=HR_out_MA_prev1;
        return
    elseif isfinite(xQ)&&isfinite(xQ_prev2)&&(xQ==xQ_prev2)
        residual=residual_prev2;
        Q_seg_calc=Q_seg_calc_prev2;
        h_out_2P=h_out_2P_prev2;
        T_out_2P=T_out_2P_prev2;
        wgt_liq_seg_2P=wgt_liq_seg_2P_prev2;
        wgt_vap_seg_2P=wgt_vap_seg_2P_prev2;
        wgt_mix_seg_2P=wgt_mix_seg_2P_prev2;
        hbar_out_MA=hbar_out_MA_prev2;
        HR_out_MA=HR_out_MA_prev2;
        return
    end

    mdot_ag_MA=props_MA.mdot_ag;


    Q_seg_2P=xQ*Q_nom;

    Q_seg_MA=-xQ*Q_nom;


    [corr_term_2P,T_seg_2P,h_out_2P,T_out_2P,wgt_liq_seg_2P,wgt_vap_seg_2P,wgt_mix_seg_2P]...
    =correlationTerms2P(Q_seg_2P,h_in_2P,T_in_2P,props_2P);


    UA_seg_2P=corr_term_2P*geometry_seg_2P;


    T_wall=T_seg_2P+Q_seg_2P/UA_seg_2P;


    HR_s_wall=saturationHumidityRatioMA(T_wall,props_MA);


    h_ag_wall=interp1(props_MA.T_TLU,props_MA.h_ag_TLU,T_wall,'linear','extrap');
    h_w_wall=interp1(props_MA.T_TLU,props_MA.h_w_TLU,T_wall,'linear','extrap');


    [corr_term_MA,hbar_seg_MA,cpbar_seg_MA]...
    =correlationTermsWetMA(Q_seg_MA,hbar_in_MA,HR_in_MA,props_MA);


    UA_seg_MA=corr_term_MA*geometry_seg_MA;

    if HR_s_wall>=HR_in_MA

        hbar_wall=h_ag_wall+HR_in_MA*h_w_wall;


        Q_seg_MA_calc=UA_seg_MA*(hbar_wall-hbar_seg_MA)/cpbar_seg_MA;


        HR_out_MA=HR_in_MA;
        Q_combined_seg_MA_calc=Q_seg_MA_calc;
    else

        hbar_s_wall=h_ag_wall+HR_s_wall.*h_w_wall;


        Q_combined_seg_MA_calc=UA_seg_MA*(hbar_s_wall-hbar_seg_MA)/cpbar_seg_MA;


        NTU_seg_MA=UA_seg_MA/cpbar_seg_MA/mdot_ag_MA;
        HR_out_MA=max(0,...
        ((1-NTU_seg_MA/2)*HR_in_MA+NTU_seg_MA*HR_s_wall)/(1+NTU_seg_MA/2));


        mdot_seg_condense=mdot_ag_MA*(HR_in_MA-HR_out_MA);


        h_l_wall=interp1(props_MA.T_TLU,props_MA.h_l_TLU,T_wall,'linear','extrap');


        Phi_seg_condense=mdot_seg_condense*h_l_wall;


        Q_seg_MA_calc=Q_combined_seg_MA_calc+Phi_seg_condense;
    end


    Q_combined_seg_MA=Q_seg_MA+Q_combined_seg_MA_calc-Q_seg_MA_calc;
    hbar_out_MA=hbar_in_MA+Q_combined_seg_MA/mdot_ag_MA;


    Q_seg_calc=-Q_seg_MA_calc;


    residual=Q_seg_calc/Q_nom-xQ;


    xQ_prev2=xQ_prev1;
    residual_prev2=residual_prev1;
    Q_seg_calc_prev2=Q_seg_calc_prev1;
    h_out_2P_prev2=h_out_2P_prev1;
    T_out_2P_prev2=T_out_2P_prev1;
    wgt_liq_seg_2P_prev2=wgt_liq_seg_2P_prev1;
    wgt_vap_seg_2P_prev2=wgt_vap_seg_2P_prev1;
    wgt_mix_seg_2P_prev2=wgt_mix_seg_2P_prev1;
    hbar_out_MA_prev2=hbar_out_MA_prev1;
    HR_out_MA_prev2=HR_out_MA_prev1;

    xQ_prev1=xQ;
    residual_prev1=residual;
    Q_seg_calc_prev1=Q_seg_calc;
    h_out_2P_prev1=h_out_2P;
    T_out_2P_prev1=T_out_2P;
    wgt_liq_seg_2P_prev1=wgt_liq_seg_2P;
    wgt_vap_seg_2P_prev1=wgt_vap_seg_2P;
    wgt_mix_seg_2P_prev1=wgt_mix_seg_2P;
    hbar_out_MA_prev1=hbar_out_MA;
    HR_out_MA_prev1=HR_out_MA;

end