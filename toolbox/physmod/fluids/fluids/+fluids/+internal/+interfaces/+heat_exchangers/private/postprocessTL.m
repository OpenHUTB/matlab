



function rho_avg=postprocessTL(T_nodes,props)

%#codegen
    coder.allowpcode('plain')


    rho_nodes=interp1(props.T_TLU,props.rho_TLU,T_nodes,'linear','extrap');


    rho_seg=(rho_nodes(1:end-1,:)+rho_nodes(2:end,:))/2;


    rho_avg=mean(rho_seg,'all');

end