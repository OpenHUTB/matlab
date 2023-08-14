function writeMkCfgFunctionHeader(h,fid)%#ok<INUSL>






    thisDate=datestr(now,0);
    slVer=ver('simulink');


    fprintf(fid,'function makeInfo = rtwmakecfg()\n');
    fprintf(fid,'%%RTWMAKECFG adds include and source directories to the make files.\n');
    fprintf(fid,'%%   makeInfo=RTWMAKECFG returns a structured array containing build info.\n');
    fprintf(fid,'%%   Please refer to the rtwmakecfg API section in the Simulink Coder\n');
    fprintf(fid,'%%   documentation for details on the format of this structure.\n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%%   Simulink version    : %s %s %s\n',slVer.Version,slVer.Release,slVer.Date);
    fprintf(fid,'%%   MATLAB file generated on : %s\n',thisDate);
    fprintf(fid,'\n');
