function createQuartus(hbuild,NumJobs)
    fid=fopen(fullfile(hbuild.ProjectDir,hbuild.DesignTclFile.quartus),'w');
    fprintf(fid,'project_new quartus_prj -overwrite\n');
    fprintf(fid,'set_global_assignment -name FAMILY "%s"\n',hbuild.Board.DeviceFamily);
    fprintf(fid,'set_global_assignment -name DEVICE "%s"\n',hbuild.Board.Device);
    fprintf(fid,'set_global_assignment -name TOP_LEVEL_ENTITY system_top\n');
    fprintf(fid,'set_global_assignment -name QSYS_FILE system_top.qsys\n');
    fprintf(fid,'set_global_assignment -name SDC_FILE %s\n',hbuild.ConstraintFile.timingConstr);
    fprintf(fid,'set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON\n');
    fprintf(fid,'set_global_assignment -name NUM_PARALLEL_PROCESSORS %d\n',NumJobs);
    fprintf(fid,'set_global_assignment -name HPS_EARLY_IO_RELEASE ON\n');
    fprintf(fid,'set_global_assignment -name TIMEQUEST_REPORT_SCRIPT quartus_timing_query.tcl\n');
    fprintf(fid,'set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON\n');


    fprintf(fid,'source %s\n',hbuild.ConstraintFile.pinConstr);
    fprintf(fid,'project_close\n');
    fclose(fid);
end