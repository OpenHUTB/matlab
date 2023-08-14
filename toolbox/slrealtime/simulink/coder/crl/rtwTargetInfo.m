function rtwTargetInfo(cm)




    cm.registerTargetInfo(@loc_register_crl);

    function this=loc_register_crl

        this(1)=RTW.TflRegistry;
        this(1).Name='Simulink Real-Time CRL';
        this(1).TableList={'slrealtime_sem_crl_table.mat','slrealtime_blas_crl_table.mat'};
        this(1).BaseTfl='';
        this(1).IsVisible=false;
        this(1).TargetHWDeviceType={'*'};
        this(1).Description='Code Replacement Library for Simulink Real-Time';
