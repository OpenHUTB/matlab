function writeMkCfgLoopForResolvingPaths(h,fid,hasLib,singleCPPMexFile)%#ok<INUSL>






    fprintf(fid,'%% Get the serialized paths information\n');
    fprintf(fid,'info = get_serialized_info();\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Get all S-Function''s name in the current model\n');
    fprintf(fid,'sfunNames = {};\n');
    fprintf(fid,'if ~isempty(bdroot)\n');
    fprintf(fid,'    sfunBlks = find_system(bdroot,...\n');
    fprintf(fid,'        ''LookUnderMasks'', ''all'',...\n');
    fprintf(fid,'        ''FollowLinks'', ''on'',...\n');
    fprintf(fid,'        ''BlockType'', ''S-Function''...\n');
    fprintf(fid,'    );\n');
    fprintf(fid,'    sfunNames = get_param(sfunBlks, ''FunctionName'');\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n');
    fprintf(fid,'for ii = 1:length(info)\n');
    fprintf(fid,'    %% If the S-Function isn''t part of the current build then skip its path info\n');
    fprintf(fid,'    if isempty(strmatch(info(ii).SFunctionName, sfunNames, ''exact''))\n');
    fprintf(fid,'        continue\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Path to the S-function source file\n');
    if singleCPPMexFile


        fprintf(fid,'    if strcmp(info(ii).Language, ''C'') && info(ii).singleCPPMexFile==0\n');
    else

        fprintf(fid,'    if strcmp(info(ii).Language, ''C'')\n');
    end
    fprintf(fid,'        fext = ''.c'';\n');
    fprintf(fid,'    else\n');
    fprintf(fid,'        fext = ''.cpp'';\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    pathToSFun = fileparts(which([info(ii).SFunctionName,fext]));\n');

    if singleCPPMexFile


        fprintf(fid,['    if isempty(pathToSFun) && strcmp(info(ii).Language, ''C'')',...
        ' && info(ii).singleCPPMexFile\n']);
        fprintf(fid,'        pathToSFun = fileparts(which([info(ii).SFunctionName,''.c'']));\n');
        fprintf(fid,'    end\n');
    end

    fprintf(fid,'    if isempty(pathToSFun)\n');
    fprintf(fid,'        pathToSFun = currDir;\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Default search paths for this S-function\n');
    fprintf(fid,'    defaultPaths = [{pathToSFun} {currDir}];\n');
    fprintf(fid,'    allPaths = [defaultPaths matlabPaths];\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Verify if IncPaths are absolute or relative and then complete\n');
    fprintf(fid,'    %% relative paths with the full S-function dir or current dir or MATLAB path\n');
    fprintf(fid,'    incPaths = info(ii).IncPaths;\n');
    fprintf(fid,'    for jj = 1:length(incPaths)\n');
    fprintf(fid,'        [fullPath, isFound] = resolve_path_info(correct_path_sep(incPaths{jj}), allPaths);\n');
    fprintf(fid,'        if (isFound==0)\n');
    fprintf(fid,'            DAStudio.error(''Simulink:tools:LCTErrorCannotFindIncludePath'',...\n');
    fprintf(fid,'                incPaths{jj});\n');
    fprintf(fid,'        else\n');
    fprintf(fid,'            incPaths{jj} = fullPath;\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    incPaths = [incPaths defaultPaths];\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Verify if SrcPaths are Absolute or Relative and then complete\n');
    fprintf(fid,'    %% relative paths with the full S-function dir or current dir or MATLAB path\n');
    fprintf(fid,'    srcPaths = info(ii).SrcPaths;\n');
    fprintf(fid,'    for jj = 1:length(srcPaths)\n');
    fprintf(fid,'        [fullPath, isFound] = resolve_path_info(correct_path_sep(srcPaths{jj}), allPaths);\n');
    fprintf(fid,'        if (isFound==0)\n');
    fprintf(fid,'            DAStudio.error(''Simulink:tools:LCTErrorCannotFindSourcePath'',...\n');
    fprintf(fid,'                srcPaths{jj});\n');
    fprintf(fid,'        else\n');
    fprintf(fid,'            srcPaths{jj} = fullPath;\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    srcPaths = [srcPaths defaultPaths];\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Common search paths for Source files specified with path\n');
    fprintf(fid,'    srcSearchPaths = [srcPaths matlabPaths];\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Add path to source files if not specified and complete relative\n');
    fprintf(fid,'    %% paths with the full S-function dir or current dir or search\n');
    fprintf(fid,'    %% paths and then extract only the path part to add it to the srcPaths\n');
    fprintf(fid,'    sourceFiles = info(ii).SourceFiles;\n');
    fprintf(fid,'    pathFromSourceFiles = cell(1, length(sourceFiles));\n');
    fprintf(fid,'    for jj = 1:length(sourceFiles)\n');
    fprintf(fid,'        [fullName, isFound] = resolve_file_info(correct_path_sep(sourceFiles{jj}), srcSearchPaths);\n');
    fprintf(fid,'        if isFound==0\n');
    fprintf(fid,'            DAStudio.error(''Simulink:tools:LCTErrorCannotFindSourceFile'',...\n');
    fprintf(fid,'                sourceFiles{jj});\n');
    fprintf(fid,'        else\n');
    fprintf(fid,'            %% Extract the path part only\n');
    fprintf(fid,'            [fpath, fname, fext] = fileparts(fullName);\n');
    fprintf(fid,'            pathFromSourceFiles{jj} = fpath;\n');
    fprintf(fid,'        end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'    srcPaths = [srcPaths pathFromSourceFiles];\n');
    fprintf(fid,'\n');

    if singleCPPMexFile
        fprintf(fid,'    %% Add the sources to the list of dependencies\n');
        fprintf(fid,'    if info(ii).singleCPPMexFile\n');
        fprintf(fid,'       allSrcs = RTW.unique([allSrcs sourceFiles]);\n');
        fprintf(fid,'    end\n');
        fprintf(fid,'\n');
    end


    if hasLib
        fprintf(fid,'    %% Verify if LibPaths are Absolute or Relative and then complete\n');
        fprintf(fid,'    %% relative paths with the full S-function dir or current dir or MATLAB path\n');
        fprintf(fid,'    libPaths = info(ii).LibPaths;\n');
        fprintf(fid,'    for jj = 1:length(libPaths)\n');
        fprintf(fid,'        [fullPath, isFound] = resolve_path_info(correct_path_sep(libPaths{jj}), allPaths);\n');
        fprintf(fid,'        if (isFound==0)\n');
        fprintf(fid,'            DAStudio.error(''Simulink:tools:LCTErrorCannotFindLibraryPath'',...\n');
        fprintf(fid,'                libPaths{jj});\n');
        fprintf(fid,'        else\n');
        fprintf(fid,'            libPaths{jj} = fullPath;\n');
        fprintf(fid,'        end\n');
        fprintf(fid,'    end\n');
        fprintf(fid,'    libPaths = [libPaths defaultPaths];\n');
        fprintf(fid,'\n');
        fprintf(fid,'    %% Common search paths for Host and Target Lib with relative paths\n');
        fprintf(fid,'    libSearchPaths = [libPaths matlabPaths];\n');
        fprintf(fid,'\n');
        fprintf(fid,'    if (isSimTarget==1)\n');
        fprintf(fid,'        %% Add path to host lib files if not specified and complete relative\n');
        fprintf(fid,'        %% paths with the full S-function dir or current dir or MATLAB path\n');
        fprintf(fid,'        libFiles = info(ii).HostLibFiles;\n');
        fprintf(fid,'        for jj = 1:length(libFiles)\n');
        fprintf(fid,'            [fullName, isFound] = resolve_file_info(correct_path_sep(libFiles{jj}), libSearchPaths);\n');
        fprintf(fid,'            if isFound==0\n');
        fprintf(fid,'                DAStudio.error(''Simulink:tools:LCTErrorCannotFindLibraryFile'',...\n');
        fprintf(fid,'                    libFiles{jj});\n');
        fprintf(fid,'            else\n');
        fprintf(fid,'                libFiles{jj} = fullName;\n');
        fprintf(fid,'            end\n');
        fprintf(fid,'        end\n');
        fprintf(fid,'\n');
        fprintf(fid,'    else\n');
        fprintf(fid,'        %% Add path to target lib files if not specified and complete relative \n');
        fprintf(fid,'        %% paths with the full S-function dir or current dir or MATLAB path\n');
        fprintf(fid,'        libFiles = info(ii).TargetLibFiles;\n');
        fprintf(fid,'        for jj = 1:length(libFiles)\n');
        fprintf(fid,'            [fullName, isFound] = resolve_file_info(correct_path_sep(libFiles{jj}), libSearchPaths);\n');
        fprintf(fid,'            if isFound==0\n');
        fprintf(fid,'                DAStudio.error(''Simulink:tools:LCTErrorCannotFindLibraryFile'',...\n');
        fprintf(fid,'                    libFiles{jj});\n');
        fprintf(fid,'            else\n');
        fprintf(fid,'                libFiles{jj} = fullName;\n');
        fprintf(fid,'            end\n');
        fprintf(fid,'        end\n');
        fprintf(fid,'    end\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'    %% Concatenate known include and source directories\n');
    fprintf(fid,'    allIncPaths = RTW.uniquePath([allIncPaths incPaths]);\n');
    fprintf(fid,'    allSrcPaths = RTW.uniquePath([allSrcPaths srcPaths]);\n');
    fprintf(fid,'\n');

    if hasLib
        fprintf(fid,'    %% Concatenate Host or Target libraries\n');
        fprintf(fid,'    allLibs   = RTW.uniquePath([allLibs libFiles]);\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'end\n');
    fprintf(fid,'\n');


