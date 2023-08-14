function[...
    YcPoles_Re,...
    YcPoles_Im,...
    YcResidues_Re_a,...
    YcResidues_Re_b,...
    YcResidues_Re_c,...
    YcResidues_Im_a,...
    YcResidues_Im_b,...
    YcResidues_Im_c,...
    YcConstant_a,...
    YcConstant_b,...
    YcConstant_c,...
    HkPoles_Re_mode1,...
    HkPoles_Im_mode1,...
    HkPoles_Re_mode2,...
    HkPoles_Im_mode2,...
    HkPoles_Re_mode3,...
    HkPoles_Im_mode3,...
    HkResidues_Re_mode1_a,...
    HkResidues_Re_mode1_b,...
    HkResidues_Re_mode1_c,...
    HkResidues_Im_mode1_a,...
    HkResidues_Im_mode1_b,...
    HkResidues_Im_mode1_c,...
    HkResidues_Re_mode2_a,...
    HkResidues_Re_mode2_b,...
    HkResidues_Re_mode2_c,...
    HkResidues_Im_mode2_a,...
    HkResidues_Im_mode2_b,...
    HkResidues_Im_mode2_c,...
    HkResidues_Re_mode3_a,...
    HkResidues_Re_mode3_b,...
    HkResidues_Re_mode3_c,...
    HkResidues_Im_mode3_a,...
    HkResidues_Im_mode3_b,...
    HkResidues_Im_mode3_c,...
    tau_delay_m]...
    =overhead_line_param(x,y,rho_c,rho_e,radius,freq,len)












    Nl=length(x);




    [Z,Y]=ee.internal.passive.overhead_line_zy_matrix(x,y,rho_c,rho_e,radius,freq);







    [Yc,Vm,Hm,D,T,Tinv]=ee.internal.passive.characteristic_matrix(Z,Y,freq,len);





    tau_delay_m=ee.internal.passive.propagation_time_delay(Hm,Vm,freq,len);





    Hk=ee.internal.passive.Hk_compute(T,Tinv,D,Hm,freq,tau_delay_m);


    warning('off','rf:rationalfit:ErrorToleranceNotMet');
    warning('off','rf:rationalfit:CheckYourData');
    [Yc_fit_a,Yc_fit_c,Yc_fit_d,~,~,~]=ee.internal.declaration.passive.rationalfit_caller(freq,Yc,'NPoles',[20,20]);
    YcPoles=Yc_fit_a;
    YcNp=length(YcPoles);
    YcResidues=zeros(Nl,Nl,YcNp);
    YcConstant=zeros(Nl,Nl);
    for index_i=1:Nl
        for index_j=1:Nl
            index_num=(index_i-1)*Nl+index_j;
            YcResidues(index_i,index_j,:)=reshape(Yc_fit_c(:,index_num),1,1,YcNp);
            YcConstant(index_i,index_j)=Yc_fit_d(index_num);
        end
    end


    for index_m=1:Nl
        Hk_reshape=squeeze(Hk(:,:,index_m,:));
        [Hk_fit_a,Hk_fit_c,Hk_fit_d,~,~,~]=ee.internal.declaration.passive.rationalfit_caller(freq,Hk_reshape,'NPoles',[20,20]);
        HkPoles{index_m}=Hk_fit_a;
        HkNp=length(HkPoles{index_m});
        HkResidues{index_m}=zeros(Nl,Nl,HkNp);
        HkConstant{index_m}=zeros(Nl,Nl);
        for index_i=1:Nl
            for index_j=1:Nl
                index_num=(index_i-1)*Nl+index_j;
                HkResidues{index_m}(index_i,index_j,:)=reshape(Hk_fit_c(:,index_num),1,1,HkNp);

            end
        end
    end
    warning('on','rf:rationalfit:ErrorToleranceNotMet');
    warning('on','rf:rationalfit:CheckYourData');


    YcPoles_Re=real(YcPoles);
    YcPoles_Im=imag(YcPoles);
    YcResidues_Re_a=real(squeeze(YcResidues(1,:,:)))';
    YcResidues_Re_b=real(squeeze(YcResidues(2,:,:)))';
    YcResidues_Re_c=real(squeeze(YcResidues(3,:,:)))';
    YcResidues_Im_a=imag(squeeze(YcResidues(1,:,:)))';
    YcResidues_Im_b=imag(squeeze(YcResidues(2,:,:)))';
    YcResidues_Im_c=imag(squeeze(YcResidues(3,:,:)))';
    YcConstant_a=YcConstant(1,:);
    YcConstant_b=YcConstant(2,:);
    YcConstant_c=YcConstant(3,:);
    HkPoles_Re_mode1=real(HkPoles{1});
    HkPoles_Im_mode1=imag(HkPoles{1});
    HkPoles_Re_mode2=real(HkPoles{2});
    HkPoles_Im_mode2=imag(HkPoles{2});
    HkPoles_Re_mode3=real(HkPoles{3});
    HkPoles_Im_mode3=imag(HkPoles{3});
    HkResidues_Re_mode1_a=real(squeeze(HkResidues{1}(1,:,:)))';
    HkResidues_Re_mode1_b=real(squeeze(HkResidues{1}(2,:,:)))';
    HkResidues_Re_mode1_c=real(squeeze(HkResidues{1}(3,:,:)))';
    HkResidues_Im_mode1_a=imag(squeeze(HkResidues{1}(1,:,:)))';
    HkResidues_Im_mode1_b=imag(squeeze(HkResidues{1}(2,:,:)))';
    HkResidues_Im_mode1_c=imag(squeeze(HkResidues{1}(3,:,:)))';
    HkResidues_Re_mode2_a=real(squeeze(HkResidues{2}(1,:,:)))';
    HkResidues_Re_mode2_b=real(squeeze(HkResidues{2}(2,:,:)))';
    HkResidues_Re_mode2_c=real(squeeze(HkResidues{2}(3,:,:)))';
    HkResidues_Im_mode2_a=imag(squeeze(HkResidues{2}(1,:,:)))';
    HkResidues_Im_mode2_b=imag(squeeze(HkResidues{2}(2,:,:)))';
    HkResidues_Im_mode2_c=imag(squeeze(HkResidues{2}(3,:,:)))';
    HkResidues_Re_mode3_a=real(squeeze(HkResidues{3}(1,:,:)))';
    HkResidues_Re_mode3_b=real(squeeze(HkResidues{3}(2,:,:)))';
    HkResidues_Re_mode3_c=real(squeeze(HkResidues{3}(3,:,:)))';
    HkResidues_Im_mode3_a=imag(squeeze(HkResidues{3}(1,:,:)))';
    HkResidues_Im_mode3_b=imag(squeeze(HkResidues{3}(2,:,:)))';
    HkResidues_Im_mode3_c=imag(squeeze(HkResidues{3}(3,:,:)))';










end
