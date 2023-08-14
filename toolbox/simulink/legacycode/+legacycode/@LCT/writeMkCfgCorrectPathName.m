function writeMkCfgCorrectPathName(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function thePaths = correct_path_name(thePaths)\n');
    fprintf(fid,'\n');
    fprintf(fid,'for ii = 1:length(thePaths)\n');
    fprintf(fid,'    thePaths{ii} = rtw_alt_pathname(thePaths{ii});\n');
    fprintf(fid,'end\n');
    fprintf(fid,'thePaths = RTW.uniquePath(thePaths);\n');
    fprintf(fid,'\n\n');


