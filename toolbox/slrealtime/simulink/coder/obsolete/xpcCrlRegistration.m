



function[thisTfl,mode]=xpcCrlRegistration

    mode='nocheck';

    thisTfl(1)=RTW.TflRegistry;
    thisTfl(1).Name='XPC_BLAS';
    thisTfl(1).Alias={'BLAS matrix multiplication operator replacement for Simulink Real-Time'};
    thisTfl(1).Description='BLAS matrix multiplication operator replacement for Simulink Real-Time';



    thisTfl(1).TableList={'slrealtime_sem_crl_table.mat','slrealtime_blas_crl_table.mat'};
    thisTfl(1).TargetHWDeviceType={'*'};
    thisTfl(1).IsVisible=false;
end


