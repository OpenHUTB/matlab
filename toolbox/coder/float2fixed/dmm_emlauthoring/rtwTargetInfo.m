function rtwTargetInfo(tr)








    tr.registerTargetInfo(@loc_createTfl);

end

function[dmmTgtTfl,mode]=loc_createTfl

    mode='nocheck';

    dmmTgtTfl(1)=RTW.TflRegistry('RTW');
    dmmTgtTfl(1).Name='DMM';
    dmmTgtTfl(1).Description='DMM internal table.';


    dmmTgtTfl(1).TableList={'private_dmm_customization_tfl_table_tmw.mat'};
    dmmTgtTfl(1).IsVisible=false;
    dmmTgtTfl(1).OverrideLangStdTfls=true;
    dmmTgtTfl(1).TargetHWDeviceType={'*'};
end
