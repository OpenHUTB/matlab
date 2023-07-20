function rtwTargetInfo(tr)







    tr.registerTargetInfo(@loc_createTfl);

end

function simTgtTfl=loc_createTfl
    simTgtTfl(1)=RTW.TflRegistry('SIM');
    simTgtTfl(1).Name='Simulation Target TFL';
    simTgtTfl(1).TableList={'simtgt_tfl_table_tmw.mat','inline_intel_avx2_crl_table.mat','inline_intel_avx_crl_table.mat','inline_intel_sse41_crl_table.mat','inline_intel_sse2_crl_table.mat','inline_intel_sse_crl_table.mat'};
    simTgtTfl(1).TargetHWDeviceType={'*'};

end


