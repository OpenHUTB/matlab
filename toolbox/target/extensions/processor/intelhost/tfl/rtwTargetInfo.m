function rtwTargetInfo(cm)




    cm.registerTargetInfo(@loc_IPP_register_tfl);
end


function[this,mode]=loc_IPP_register_tfl

    mode='nocheck';

    arch=computer('arch');
    tablename='';

    iswin64=false;
    switch arch
    case 'win32'
        tablename='intel_ipp_tfl_table_win_32.mat';
    case 'win64'
        tablename='intel_ipp_tfl_table_win_64.mat';
        iswin64=true;
    case 'glnxa64'
        tablename='intel_ipp_tfl_table_glnxa_64.mat';
    end

    switch(arch)
    case{'win32','win64','glnxa64'}
        idx=0;
        mingwId='GNU-x';


        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP';
        this(idx).TableList={tablename};
        this(idx).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon','Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','Intel->x86-64 (Linux 64)',...
        'AMD->x86-64 (Windows64)','AMD->x86-64 (Linux 64)'};
        this(idx).Description='Use Intel IPP library for optimized code generation';
        this(idx).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE with GNU99 extensions';
        this(idx).Alias={'Intel IPP (GNU)','Intel IPP/SSE (GNU)'};
        this(idx).TableList={'intel_sse_tfl_table.mat',tablename};
        this(idx).BaseTfl='GNU';
        this(idx).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon','Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','Intel->x86-64 (Linux 64)',...
        'AMD->x86-64 (Windows64)','AMD->x86-64 (Linux 64)'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('gcc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;


        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP for x86-64 (Windows)';
        this(idx).TableList={'intel_ipp_tfl_table_win_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)'};
        this(idx).Description='Use Intel IPP library for optimized code generation';
        this(idx).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE with GNU99 extensions for x86-64 (Windows)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_win_64.mat'};
        this(idx).BaseTfl='GNU';
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE for x86-64 (Windows)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_win_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;



        if iswin64



            for i_lib=1:numel(this)
                this(i_lib).TargetToolchain={['-',mingwId]};
            end
        end



        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP for x86-64 (Windows using MinGW compiler)';
        this(idx).TableList={'intel_ipp_tfl_table_win_64_mingw.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)'};
        if iswin64



            this(idx).TargetToolchain={mingwId};
        end
        this(idx).Description='Use Intel IPP library for optimized code generation';
        this(idx).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE for x86-64 (Windows using MinGW compiler)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_win_64_mingw.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)'};
        if iswin64



            this(idx).TargetToolchain={mingwId};
        end
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('mingw');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;



        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP for x86/Pentium (Windows)';
        this(idx).TableList={'intel_ipp_tfl_table_win_32.mat'};
        this(idx).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon'};
        this(idx).Description='Use Intel IPP library for optimized code generation';
        this(idx).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE with GNU99 extensions for x86/Pentium (Windows)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_win_32.mat'};
        this(idx).BaseTfl='GNU';
        this(idx).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE for x86/Pentium (Windows)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_win_32.mat'};
        this(idx).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;


        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP for x86-64 (Linux)';
        this(idx).TableList={'intel_ipp_tfl_table_glnxa_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Linux 64)','AMD->x86-64 (Linux 64)'};
        this(idx).Description='Use Intel IPP library for optimized code generation';
        this(idx).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry('RTW');
        this(idx).Name='Intel IPP/SSE with GNU99 extensions for x86-64 (Linux)';
        this(idx).TableList={'intel_sse_tfl_table.mat','intel_ipp_tfl_table_glnxa_64.mat'};
        this(idx).BaseTfl='GNU';
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Linux 64)','AMD->x86-64 (Linux 64)'};
        this(idx).Description='Use Intel IPP library and SSE instructions for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('gcc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;



        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel SSE (Windows)';
        this(idx).TableList={'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat',...
        'intel_ipp_tfl_table_win_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)','MatlabHost'};
        this(idx).Description='Use Intel IPP library and SSE/SSE2/SSE3/SSSE3/SSE4.1 intrinsics for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel AVX (Windows)';
        this(idx).TableList={'inline_intel_avx2_crl_table.mat',...
        'inline_intel_avx_crl_table.mat',...
        'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat',...
        'intel_ipp_tfl_table_win_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)','MatlabHost'};
        this(idx).Description='Use Intel IPP library and SSE/SSE2/SSE3/SSSE3/SSE4.1/AVX/AVX2 intrinsics for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel SSE (Linux)';
        this(idx).TableList={'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat',...
        'intel_ipp_tfl_table_glnxa_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Linux 64)','AMD->x86-64 (Linux 64)','MatlabHost'};
        this(idx).Description='Use Intel IPP library and SSE/SSE2/SSE3/SSSE3/SSE4.1 intrinsics for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('gcc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel AVX (Linux)';
        this(idx).TableList={'inline_intel_avx2_crl_table.mat',...
        'inline_intel_avx_crl_table.mat',...
        'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat',...
        'intel_ipp_tfl_table_glnxa_64.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Linux 64)','AMD->x86-64 (Linux 64)','MatlabHost'};
        this(idx).Description='Use Intel IPP library and SSE/SSE2/SSE3/SSSE3/SSE4.1/AVX/AVX2 intrinsics for optimized code generation';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('gcc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel AVX-512 (Windows)';
        this(idx).TableList={'inline_intel_avx512f_crl_table.mat',...
        'inline_intel_fma_crl_table.mat',...
        'inline_intel_avx2_crl_table.mat',...
        'inline_intel_avx_crl_table.mat',...
        'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','AMD->x86-64 (Windows64)','MatlabHost'};
        this(idx).Description='UseSSE/SSE2/SSE3/SSSE3/SSE4.1/AVX/AVX2/AVX512 intrinsics for optimized code generation on Windows target';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('msvc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

        idx=idx+1;
        this(idx)=RTW.TflRegistry;
        this(idx).Name='Intel AVX-512 (Linux)';
        this(idx).TableList={'inline_intel_avx512f_crl_table.mat',...
        'inline_intel_fma_crl_table.mat',...
        'inline_intel_avx2_crl_table.mat',...
        'inline_intel_avx_crl_table.mat',...
        'inline_intel_sse41_crl_table.mat',...
        'inline_intel_sse2_crl_table.mat',...
        'inline_intel_sse_crl_table.mat'};
        this(idx).TargetHWDeviceType={'Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Linux 64)','AMD->x86-64 (Linux 64)','MatlabHost'};
        this(idx).Description='Use SSE/SSE2/SSE3/SSSE3/SSE4.1/AVX/AVX2/AVX512 intrinsics for optimized code generation on Linux target';
        tc=RTW.TargetCharacteristics;
        tc.DataAlignment=data_align_specification('gcc');
        this(idx).TargetCharacteristics=tc;
        this(idx).IsVisible=false;

    otherwise
        this(1)=RTW.TflRegistry;
        this(1).Name='Intel IPP';
        this(1).TableList={'intel_ipp_tfl_table_mac_64.mat'};
        this(1).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon','Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','Intel->x86-64 (Linux 64)','Intel->x86-64 (Mac OS X)',...
        'AMD->x86-64 (Windows64)','AMD->x86-64 (Linux 64)','AMD->x86-64 (Mac OS X)'};
        this(1).Description='Use Intel IPP library for optimized code generation';
        this(1).LanguageConstraint={'C99 (ISO)','C89/C90 (ANSI)'};
        this(1).IsVisible=false;

        this(2)=RTW.TflRegistry;
        this(2).Name='Intel IPP/SSE with GNU99 extensions';
        this(2).Alias={'Intel IPP/SSE (GNU)'};
        this(2).TableList={};
        this(2).BaseTfl='GNU';
        this(2).TargetHWDeviceType={'Intel Pentium','AMD->K5/K6/Athlon','Intel->x86-64','AMD->Athlon 64',...
        'Intel->x86-64 (Windows64)','Intel->x86-64 (Linux 64)','Intel->x86-64 (Mac OS X)',...
        'AMD->x86-64 (Windows64)','AMD->x86-64 (Linux 64)','AMD->x86-64 (Mac OS X)'};
        this(2).Description='Use Intel IPP library for optimized code generation';
        this(2).IsVisible=false;
    end


end


function da=data_align_specification(compiler)


    switch lower(compiler)
    case 'msvc'
        aT='__declspec(align(%n))';
    case{'gcc','g++','clang','mingw'}
        aT='__attribute((aligned(%n)))';
    otherwise
        error('Unhandled: %s',compiler);
    end

    as=RTW.AlignmentSpecification;
    as.AlignmentType={'DATA_ALIGNMENT_LOCAL_VAR',...
    'DATA_ALIGNMENT_STRUCT_FIELD',...
    'DATA_ALIGNMENT_GLOBAL_VAR'};
    as.AlignmentSyntaxTemplate=aT;
    as.SupportedLanguages={'c','c++'};
    da=RTW.DataAlignment;
    da.addAlignmentSpecification(as);

end


