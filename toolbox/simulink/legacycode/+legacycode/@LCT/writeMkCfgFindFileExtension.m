function writeMkCfgFindFileExtension(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function fext = find_file_extension(fullName)\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Initialize output value\n');
    fprintf(fid,'fext = [];\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Use ''dir'' because this command has the same behavior both\n');
    fprintf(fid,'%% on PC and Unix\n');
    fprintf(fid,'theDir = dir([fullName,''.*'']);\n');
    fprintf(fid,'if ~isempty(theDir)\n');
    fprintf(fid,'    for ii = 1:length(theDir)\n');
    fprintf(fid,'        if theDir(ii).isdir\n');
    fprintf(fid,'            continue\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'        [fpath, fname, fext] = fileparts(theDir(ii).name);\n');
    fprintf(fid,'        if ~isempty(fext)\n');
    fprintf(fid,'            break %% stop on first occurrence\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

