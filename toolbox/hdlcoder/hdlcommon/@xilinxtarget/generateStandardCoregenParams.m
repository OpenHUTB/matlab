function extraArgs=generateStandardCoregenParams(fid,opInCLI,dataType)




    fprintf(fid,'CSET c_rate=1\n');
    fprintf(fid,'CSET c_has_ce=true\n');
    fprintf(fid,'CSET c_has_sclr=true\n');
    fprintf(fid,'CSET c_speed=Maximum_speed\n');
    fprintf(fid,'CSET c_mult_usage=No_Usage\n');


    fprintf(fid,'CSET maximum_latency=false\n');
    fprintf(fid,'CSET c_optimization=Speed_Optimized\n');
    fprintf(fid,'CSET c_has_divide_by_zero=false\n');
    fprintf(fid,'CSET c_has_invalid_op=false\n');
    fprintf(fid,'CSET c_has_operation_nd=false\n');
    fprintf(fid,'CSET c_has_operation_rfd=false\n');
    fprintf(fid,'CSET c_has_overflow=false\n');
    fprintf(fid,'CSET c_has_rdy=false\n');
    fprintf(fid,'CSET c_has_underflow=false\n');


    fprintf(fid,'# User Parameters\n');
    extraArgs=targetcodegen.targetCodeGenerationUtils.getExtraArgs(opInCLI,dataType);
    fprintf(fid,'%s\n',extraArgs);

    fprintf(fid,'# END Parameters\n');


    fprintf(fid,'GENERATE\n');


