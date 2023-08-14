




function[v_avg,T_nodes,x_w_nodes,x_g_nodes,T_out_avg]=postprocessMA(...
    hbar_nodes,HR_nodes,props)

%#codegen
    coder.allowpcode('plain')


    [N_nodes,cols]=size(hbar_nodes);
    T_nodes=zeros(N_nodes,cols);


    x_w_nodes_smooth=HR_nodes./(1+HR_nodes);
    x_ag_nodes_smooth=1-x_w_nodes_smooth;



    x_ag_min=props.x_ag_min;
    x_w_nodes=1-x_ag_nodes_smooth;

    for i=1:N_nodes
        for j=1:cols
            if x_ag_nodes_smooth(i,j)<x_ag_min*exp(-11)
                x_w_nodes(i,j)=1-10*x_ag_min;
            elseif x_ag_nodes_smooth(i,j)<x_ag_min
                x_w_nodes(i,j)=1-x_ag_min*(1+log(x_ag_nodes_smooth(i,j)/x_ag_min));
            end


            hbar_nodes_TLU=props.h_ag_TLU+HR_nodes(i,j)*props.h_w_TLU;


            T_nodes(i,j)=interp1(hbar_nodes_TLU,props.T_TLU,hbar_nodes(i,j),'linear','extrap');
        end
    end


    x_g_nodes=x_ag_nodes_smooth*props.GR;



    x_g_nodes=min(x_g_nodes,1-x_w_nodes);


    R_nodes=(1-x_w_nodes-x_g_nodes)*props.R_a+x_w_nodes*props.R_w+x_g_nodes*props.R_g;


    v_nodes=R_nodes.*T_nodes/props.p;


    v_seg=(v_nodes(1:N_nodes-1,:)+v_nodes(2:N_nodes,:))/2;


    v_avg=mean(v_seg,'all');


    hbar_out_avg=mean(hbar_nodes(N_nodes,:));


    HR_out_avg=mean(HR_nodes(N_nodes,:));


    hbar_out_avg_TLU=props.h_ag_TLU+HR_out_avg*props.h_w_TLU;


    T_out_avg=interp1(hbar_out_avg_TLU,props.T_TLU,hbar_out_avg,'linear','extrap');

end