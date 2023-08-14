




function[rho_avg,u_nodes]=postprocess2P(h_nodes,wgt_liq,wgt_vap,wgt_mix,props)

%#codegen
    coder.allowpcode('plain')


    [N_nodes,cols]=size(h_nodes);


    u_nodes=interp1(props.h_TLU,props.u_TLU,h_nodes,'linear','extrap');
    v_nodes=interp1(props.h_TLU,props.v_TLU,h_nodes,'linear','extrap');


    v_liq_nodes=v_nodes;
    v_vap_nodes=v_nodes;
    v_mix_nodes=v_nodes;


    for i=1:N_nodes
        for j=1:cols
            if h_nodes(i,j)>props.h_sat_liq
                v_liq_nodes(i,j)=props.v_sat_liq;
            end
            if h_nodes(i,j)<props.h_sat_vap
                v_vap_nodes(i,j)=props.v_sat_vap;
            end
            if h_nodes(i,j)<props.h_sat_liq
                v_mix_nodes(i,j)=props.v_sat_liq;
            end
            if h_nodes(i,j)>props.h_sat_vap
                v_mix_nodes(i,j)=props.v_sat_vap;
            end
        end
    end

    rho_liq_nodes=1./v_liq_nodes;
    rho_vap_nodes=1./v_vap_nodes;


    rho_liq_seg=(rho_liq_nodes(1:N_nodes-1,:)+rho_liq_nodes(2:N_nodes,:))/2;
    rho_vap_seg=(rho_vap_nodes(1:N_nodes-1,:)+rho_vap_nodes(2:N_nodes,:))/2;


    v_mix_min_seg=min(v_mix_nodes(1:N_nodes-1,:),v_mix_nodes(2:N_nodes,:));
    v_mix_max_seg=max(v_mix_nodes(1:N_nodes-1,:),v_mix_nodes(2:N_nodes,:));
    v_ratio_mix_seg=max(v_mix_max_seg./v_mix_min_seg,1+1e-6);


    rho_mix_seg=log(v_ratio_mix_seg)./(v_ratio_mix_seg-1)./v_mix_min_seg;


    rho_seg=wgt_liq.*rho_liq_seg+wgt_vap.*rho_vap_seg+wgt_mix.*rho_mix_seg;


    rho_avg=mean(rho_seg,'all');

end