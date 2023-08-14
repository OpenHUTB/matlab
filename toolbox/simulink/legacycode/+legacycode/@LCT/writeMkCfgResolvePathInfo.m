function writeMkCfgResolvePathInfo(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function [fullPath, isFound] = resolve_path_info(fullPath, searchPaths)\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Initialize output value\n');
    fprintf(fid,'isFound = 0;\n');
    fprintf(fid,'\n');
    fprintf(fid,'if is_absolute_path(fullPath)==1\n');
    fprintf(fid,'    %% Verify that the dir exists\n');
    fprintf(fid,'    if exist(fullPath, ''dir'')\n');
    fprintf(fid,'        isFound = 1;\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'else\n');
    fprintf(fid,'    %% Walk through the search path\n');
    fprintf(fid,'    for ii = 1:length(searchPaths)\n');
    fprintf(fid,'        thisFullPath = fullfile(searchPaths{ii}, fullPath);\n');
    fprintf(fid,'        %% If this candidate path exists then exit\n');
    fprintf(fid,'        if exist(thisFullPath, ''dir'')\n');
    fprintf(fid,'            isFound = 1;\n');
    fprintf(fid,'            fullPath = thisFullPath;\n');
    fprintf(fid,'            break\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

