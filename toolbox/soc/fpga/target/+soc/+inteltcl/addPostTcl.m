function addPostTcl(fid,~)


    fprintf(fid,'set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {AUTO}\n');
    fprintf(fid,'set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {4}\n');
    fprintf(fid,'set_interconnect_requirement {$system} {qsys_mm.burstAdapterImplementation} {PER_BURST_TYPE_CONVERTER}\n');
    fprintf(fid,'validate_system\n');
    fprintf(fid,'save_system system_top.qsys\n');
end

