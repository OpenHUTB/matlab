function[full_phi_value,full_torque_value]=rotational_detent_vector_private(single_phi_vector,single_torque_vector,center_spacing)%#codegen




    coder.allowpcode('plain');

    num_phi_points=length(single_phi_vector);
    num_detents=length(center_spacing);
    phi_value=zeros(1,num_phi_points*num_detents);

    for i=1:num_detents
        for j=1:num_phi_points
            phi_value(j+(i-1)*num_phi_points)=single_phi_vector(j)+center_spacing(i);
        end
    end
    torque_value=repmat(single_torque_vector,1,num_detents);



    [~,wrap_index]=max([phi_value,pi]>=pi);

    full_phi_value=circshift(phi_value-2*pi*(phi_value>=pi),-(wrap_index-1));
    full_torque_value=circshift(torque_value,-(wrap_index-1));


    [~,back_index]=max([flip(phi_value),-2*pi]<-pi);

    if back_index~=num_phi_points*num_detents+1
        full_phi_value=circshift(full_phi_value+2*pi*(full_phi_value<-pi),back_index-1);
        full_torque_value=circshift(full_torque_value,back_index-1);
    end

end