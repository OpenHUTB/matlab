function writeMkCfgResolveFileInfo(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function [fullName, isFound] = resolve_file_info(fullName, searchPaths)\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Initialize output value\n');
    fprintf(fid,'isFound = 0;\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Extract file parts\n');
    fprintf(fid,'[fPath, fName, fExt] = fileparts(fullName);\n');
    fprintf(fid,'\n');
    fprintf(fid,'if is_absolute_path(fPath)==1\n');
    fprintf(fid,'    %% If the file has no extension then try to add it\n');
    fprintf(fid,'    if isempty(fExt)\n');
    fprintf(fid,'        fExt = find_file_extension(fullfile(fPath, fName));\n');
    fprintf(fid,'        fullName = fullfile(fPath, [fullName,fExt]);\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    %% Verify that the file exists\n');
    fprintf(fid,'    if exist(fullName, ''file'')\n');
    fprintf(fid,'        isFound = 1;\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'else\n');
    fprintf(fid,'    %% Walk through the search path\n');
    fprintf(fid,'    for ii = 1:length(searchPaths)\n');
    fprintf(fid,'        thisFullName = fullfile(searchPaths{ii}, fullName);\n');
    fprintf(fid,'        %% If the file has no extension then try to add it\n');
    fprintf(fid,'        if isempty(fExt)\n');
    fprintf(fid,'            fExt = find_file_extension(thisFullName);\n');
    fprintf(fid,'            thisFullName = [thisFullName,fExt];\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'        %% If this candidate path exists then exit\n');
    fprintf(fid,'        if exist(thisFullName, ''file'')\n');
    fprintf(fid,'            fullName = thisFullName;\n');
    fprintf(fid,'            isFound = 1;\n');
    fprintf(fid,'            break\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

