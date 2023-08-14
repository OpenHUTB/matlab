function writeMkCfgMlPaths(h,fid)%#ok<INUSL>




    fprintf(fid,'%% Verify the Simulink version\n');
    fprintf(fid,'verify_simulink_version();\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Get the current directory\n');
    fprintf(fid,'currDir = pwd;\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Get the MATLAB search paths and remove the toolbox sub-directories except simfeatures\n');
    fprintf(fid,'pSep = pathsep;\n');
    fprintf(fid,'matlabPaths = regexp([matlabpath pSep], [''.[^'' pSep '']*'' pSep], ''match'');\n');
    fprintf(fid,'if ~isempty(matlabPaths)\n');
    fprintf(fid,'    filteredPathIndices = strncmp(fullfile(matlabroot,''toolbox''), matlabPaths, numel(fullfile(matlabroot,''toolbox'')));\n');
    fprintf(fid,'    lctPath = fileparts(which(''sldemo_lct_builddemos''));\n');
    fprintf(fid,'    if ~isempty(lctPath)\n');

    fprintf(fid,'        filteredPathIndices(strncmp([lctPath pSep], matlabPaths, numel([lctPath pSep]))) = 0;\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    lctPath = fileparts(which(''rtwdemo_lct_builddemos''));\n');
    fprintf(fid,'    if ~isempty(lctPath)\n');

    fprintf(fid,'        filteredPathIndices(strncmp([lctPath pSep], matlabPaths, numel([lctPath pSep]))) = 0;\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    matlabPaths(filteredPathIndices) = [];\n');
    fprintf(fid,'    matlabPaths = strrep(matlabPaths, pSep, '''');\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n');


