function[angle_vector_full,pressure_table,pressure_mismatch]=piston_vector_private(angle_vector,pressure,stroke_num)%#codegen



    coder.allowpcode('plain');


    if angle_vector(1)==-pi*stroke_num/2&&angle_vector(end)==pi*stroke_num/2
        angle_vector_full=[-pi*stroke_num,angle_vector,pi*stroke_num];
        if any(pressure(1,:,:)~=pressure(end,:,:))
            pressure_mismatch=true;
        else
            pressure_mismatch=false;
        end
    else
        angle_vector_full=[angle_vector(end)-stroke_num*pi,angle_vector,angle_vector(1)+stroke_num*pi];
        pressure_mismatch=false;
    end


    dims=size(pressure);
    if dims(1)==1
        pressure_table=[pressure(end),pressure,pressure(1)]';
    else
        pressure_table=[pressure(end,:,:);pressure;pressure(1,:,:)];
    end

end