function simTgtTfl=createTfl






    akimaFeatureVal=slfeature('SLAkimaInterpSupport');
    simTgtTfl(1)=RTW.TflRegistry('SIM');
    simTgtTfl(1).Name='Simulation Target TFL';
    if akimaFeatureVal<=0
        simTgtTfl(1).TableList={'simtgt_tfl_table_tmw.mat'};
    else
        simTgtTfl(1).TableList={'simtgt_tfl_table_tmw.mat','make_simtgt_akima_lookup_tfl_table'};
    end
    simTgtTfl(1).TargetHWDeviceType={'*'};


    simTgtTfl(2)=RTW.TflRegistry('SIM');
    simTgtTfl(2).Name='Simulation Target TFL IPP';
    if akimaFeatureVal<=0
        simTgtTfl(2).TableList={'make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat'};
    else
        simTgtTfl(2).TableList={'make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat','make_simtgt_akima_lookup_tfl_table'};
    end
    simTgtTfl(2).TargetHWDeviceType={'*'};







    simTgtTfl(3)=RTW.TflRegistry('SIM');
    simTgtTfl(3).Name='Simulation Target IPP BLAS';
    if akimaFeatureVal<=0
        simTgtTfl(3).TableList={'make_simtgt_blas_tfl_table','make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat'};
    else
        simTgtTfl(3).TableList={'make_simtgt_blas_tfl_table','make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat','make_simtgt_akima_lookup_tfl_table'};
    end
    simTgtTfl(3).TargetHWDeviceType={'*'};



    simTgtTfl(4)=RTW.TflRegistry('SIM');
    simTgtTfl(4).Name='Simulation Target TFL BLAS';
    if akimaFeatureVal<=0
        simTgtTfl(4).TableList={'make_simtgt_blas_tfl_table','simtgt_tfl_table_tmw.mat'};
    else
        simTgtTfl(4).TableList={'make_simtgt_blas_tfl_table','simtgt_tfl_table_tmw.mat','make_simtgt_akima_lookup_tfl_table'};
    end
    simTgtTfl(4).TargetHWDeviceType={'*'};






    simTgtTfl(5)=RTW.TflRegistry('SIM');
    simTgtTfl(5).Name='Simulation Target IPP BLAS SIMD';
    if akimaFeatureVal<=0
        simTgtTfl(5).TableList={'make_simtgt_blas_tfl_table','make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat'};
    else
        simTgtTfl(5).TableList={'make_simtgt_blas_tfl_table','make_simtgt_ipp_tfl_table','simtgt_tfl_table_tmw.mat','make_simtgt_akima_lookup_tfl_table'};
    end

    if ismac
        simTgtTfl(5).TableList{end+1}='inline_intel_avx2_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_avx_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse41_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse2_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse_crl_table.mat';
    else
        simTgtTfl(5).TableList{end+1}='inline_intel_avx512f_sim_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_avx2_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_avx_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse41_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse2_crl_table.mat';
        simTgtTfl(5).TableList{end+1}='inline_intel_sse_crl_table.mat';
    end

    simTgtTfl(5).TargetHWDeviceType={'*'};













end




