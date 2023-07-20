





































function[omega_TLU_ext,flow_rate_TLU_ext,pressure_TLU_ext,torque_TLU_ext,...
    pressure_TLU_zero,torque_TLU_zero,exitflag]...
    =extendCharacteristicCurves_private(omega_TLU,flow_rate_TLU,pressure_TLU,torque_TLU)

%#codegen
    coder.allowpcode('plain')

    exitflag=1;
    [m,n]=size(pressure_TLU);


    omega_TLU_ext=[-omega_TLU(1);0;omega_TLU(:)];



    flow_rate_TLU_ext=[min(2*flow_rate_TLU(1)-flow_rate_TLU(2),0);flow_rate_TLU(:);2*flow_rate_TLU(n)-flow_rate_TLU(n-1)];


    pressure_TLU_ext=[zeros(2,n+2);[zeros(m,1),pressure_TLU,zeros(m,1)]];
    torque_TLU_ext=[zeros(2,n+2);[zeros(m,1),torque_TLU,zeros(m,1)]];


    pressure_TLU_zero=zeros(m,1);
    torque_TLU_zero=zeros(m,1);


    pressure_slope_1=zeros(m,1);
    pressure_slope_n=zeros(m,1);


    I_nan1=zeros(m,1);

    num_nan_prev=inf;


    for i=1:m
        idx_nan=isnan(pressure_TLU(i,:));
        if any(idx_nan)

            num_nan=sum(idx_nan);

            [~,I_nan1(i)]=max(idx_nan);


            if num_nan>n-2
                exitflag=-1;
                return
            end


            if~idx_nan(n)||(num_nan<n-I_nan1(i)+1)
                exitflag=-2;
                return
            end



            if num_nan>num_nan_prev
                exitflag=-3;
                return
            end

            num_nan_prev=num_nan;
        else

            I_nan1(i)=n+1;
            num_nan_prev=0;
        end


        pressure_slope_1(i)=(pressure_TLU(i,2)-pressure_TLU(i,1))...
        /(flow_rate_TLU(2)-flow_rate_TLU(1));



        pressure_slope_n(i)=(pressure_TLU(i,I_nan1(i)-1)-pressure_TLU(i,I_nan1(i)-2))...
        /(flow_rate_TLU(I_nan1(i)-1)-flow_rate_TLU(I_nan1(i)-2));
    end



    pressure_slope_1_avg=min(trapz(omega_TLU,pressure_slope_1)/(omega_TLU(m)-omega_TLU(1)),0);
    pressure_slope_n_avg=min(trapz(omega_TLU,pressure_slope_n)/(omega_TLU(m)-omega_TLU(1)),0);



    for i=1:m

        pressure_TLU_ext(i+2,1)=pressure_TLU(i,1)+pressure_slope_1_avg*(flow_rate_TLU_ext(1)-flow_rate_TLU(1));
        torque_TLU_ext(i+2,1)=torque_TLU(i,1);


        for j=I_nan1(i):n+1
            pressure_TLU_ext(i+2,j+1)=pressure_TLU(i,I_nan1(i)-1)+pressure_slope_n_avg*(flow_rate_TLU_ext(j+1)-flow_rate_TLU(I_nan1(i)-1));
            torque_TLU_ext(i+2,j+1)=torque_TLU(i,I_nan1(i)-1);
        end
    end


    pressure_TLU_zero=interp2(flow_rate_TLU_ext,omega_TLU,pressure_TLU_ext(3:m+2,:),zeros(m,1),omega_TLU(:),'linear');
    torque_TLU_zero=interp2(flow_rate_TLU_ext,omega_TLU,torque_TLU_ext(3:m+2,:),zeros(m,1),omega_TLU(:),'linear');



    torque_TLU_ext(1,:)=-torque_TLU_ext(3,:);

end