function Motor=autoblks_getMotorPlotsCb(P_rated,T_rated,N_max,bp)



























    N_base=double(uint32(P_rated/(T_rated*(2*pi/60))));

    N=1:N_max;
    T_max=P_rated./((2*pi/60).*N);
    T_max(1:N_base)=T_rated*ones(1,N_base);
    P=2*pi.*N.*T_max/60;
























    Speed_idx=linspace(0,N_max,bp-1);
    Speed_bp=zeros(1,bp);
    idx=length(find(Speed_idx<=N_base));

    Speed_bp(1:idx)=Speed_idx(1:idx);
    Speed_bp(idx+1)=N_base;
    Speed_bp(idx+2:end)=Speed_idx(idx+1:end);

    Motor.Spd_bp=Speed_bp;
    Motor.Trq_bp=zeros(1,bp);
    Motor.Pwr_bp=zeros(1,bp);
    Motor.N_base=N_base;

    for idx=1:bp
        if Speed_bp(idx)==0
            Motor.Trq_bp(idx)=T_max(1);
            Motor.Pwr_bp=P(1);
        else
            Motor.Trq_bp(idx)=T_max(uint32(Speed_bp(idx)));
            Motor.Pwr_bp(idx)=P(uint32(Speed_bp(idx)));
        end

    end

end