function writeMkCfgIsAbsolutePath(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function bool = is_absolute_path(thisPath)\n');
    fprintf(fid,'\n');
    fprintf(fid,'if isempty(thisPath)\n');
    fprintf(fid,'    bool = 0;\n');
    fprintf(fid,'    return\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n');
    fprintf(fid,'if(thisPath(1)==''.'')\n');
    fprintf(fid,'    %% Relative path\n');
    fprintf(fid,'    bool = 0;\n');
    fprintf(fid,'else\n');
    fprintf(fid,'    if(ispc && length(thisPath)>=2)\n');
    fprintf(fid,'        %% Absolute path on PC start with drive letter or \\(for UNC paths)\n');
    fprintf(fid,'        bool = (thisPath(2)=='':'') | (thisPath(1)==''\\'');\n');
    fprintf(fid,'    else\n');
    fprintf(fid,'        %% Absolute paths on unix start with ''/''\n');
    fprintf(fid,'        bool = thisPath(1)==''/'';\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

