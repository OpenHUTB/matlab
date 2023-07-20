function writeMkCfgVerifySimulinkVersion(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function verify_simulink_version()\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Retrieve Simulink version\n');
    fprintf(fid,'slVerStruct = ver(''simulink'');\n');
    fprintf(fid,'slVer = str2double(strsplit(slVerStruct.Version,''.''));\n');
    fprintf(fid,'%% Verify that the actual platform supports the function used\n');
    fprintf(fid,'if slVer(1)<6 || (slVer(1)==6 && slVer(2)<4)\n');
    fprintf(fid,'    DAStudio.error(''Simulink:tools:LCTErrorBadSimulinkVersion'', slVerStruct.Version)\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

