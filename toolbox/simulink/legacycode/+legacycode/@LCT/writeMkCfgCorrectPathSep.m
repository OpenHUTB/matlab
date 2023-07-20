function writeMkCfgCorrectPathSep(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function thePath = correct_path_sep(thePath)\n');
    fprintf(fid,'\n');
    fprintf(fid,'if isunix\n');
    fprintf(fid,'    wrongFilesepChar = ''\\'';\n');
    fprintf(fid,'    filesepChar = ''/'';\n');
    fprintf(fid,'else\n');
    fprintf(fid,'    wrongFilesepChar = ''/'';\n');
    fprintf(fid,'    filesepChar = ''\\'';\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n');
    fprintf(fid,'seps = find(thePath==wrongFilesepChar);\n');
    fprintf(fid,'if(~isempty(seps))\n');
    fprintf(fid,'    thePath(seps) = filesepChar;\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');
