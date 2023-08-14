function [buildDir, codeGenName] = targets_get_build_dir(fullSystemPath, stf, hardware)
%TARGETS_GET_BUILD_DIR Get the build directory for a Simulink system path.
%
%   TARGETS_GET_BUILD_DIR(fullSystemPath) returns the build directory for a
%   Simulink system path, if it exists.   Additionally, the base name used 
%   for generated source files can be returned.
%
%   Input arguments:
%
%   Name:       Description:
%
%   fullSystemPath  String containing the name of the Simulink system path to
%                   find a build directory for. This is either the name of a
%                   model or the full path to a subsystem.
%
%   stf             String containing the filename of the system target
%                   file used to determine the build folders for the
%                   specified system. This will override the model
%                   configured system target file.
%
%   Output arguments:
%
%   Name:       Description:
%
%   buildDir    String containing the full path to the build directory
%               or empty if a build directory was not found.
% 
%   codeGenName String containing the base name used for generated 
%               source files.
%
%   Examples:
%
%      1.
%
%      [buildDir codeGenName] = targets_get_build_dir('rtwdemo_mrmtbb')
%
%      2.
%
%      [buildDir codeGenName] = targets_get_build_dir(['rtwdemo_fuelsys/fuel rate' ...
%                                                      sprintf('\n') ...
%                                                     'controller'])
%
%      3.
%
%      [buildDir codeGenName] = targets_get_build_dir('rtwdemo_fuelsys')
%

% Copyright 2007-2020 The MathWorks, Inc.

narginchk(1, 3);
if ~ischar(fullSystemPath)
  TargetCommon.ProductInfo.error('common', 'InputArgNInvalid', '"fullSystemPath"', 'character array');
end

% split fullSystemPath into model and system path
[rootModel, systemPath] = strtok(fullSystemPath, '/');

if nargin > 1
    
    if nargin < 3
        buildFolders = Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(rootModel, stf);
    else
        buildFolders = Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(rootModel, stf, hardware);
    end
else    
    buildFolders = Simulink.filegen.internal.FolderConfiguration(rootModel);
end

if isempty(systemPath)
    % rootModel    
    buildDir = buildFolders.CodeGeneration.absolutePath('ModelCode');
    codeGenName = rootModel;
else  
    % subsystem
    %
    % linear search relevant binfo.mat files for matching 
    % SourceSubsystemName!
    %
   
    buildDir = '';
    codeGenName = '';
    
    % get the list of all files in the appropriate slprj sub-dir
    rootBuildDir = buildFolders.CodeGeneration.Root;
    slprjSubDir = buildFolders.CodeGeneration.TargetRoot;
    files = dir(fullfile(rootBuildDir, slprjSubDir));
    
    % process directories and find the ones with binfo files
    dirIndices = find([files.isdir]);        
    binfoFiles = {};
    possibleCodeGenNames = {};
    for i=1:length(dirIndices)
        dirName = files(dirIndices(i));
        binfoFile = fullfile(rootBuildDir, slprjSubDir, dirName.name, 'tmwinternal', 'binfo.mat');
        if exist(binfoFile, 'file')
            % found file
            binfoFiles{end+1} = binfoFile; %#ok<AGROW>
            possibleCodeGenNames{end+1} = dirName.name; %#ok<AGROW>
        end
    end
    % rogue value for timestamp
    latestTimeStamp = -1;
    % linear search through all matching binfo files
    %
    % loadPostBuild
    action = 'loadPostBuild';
    % load binfo
    minfo_or_binfo = 'binfo';        
    mdlRefTgtType = 'NONE';
    % don't load the whole config set
    loadConfigSet = 0;                
    for i=1:length(binfoFiles)
        % load the binfo
        binfoFile = binfoFiles{i};  
        possibleCodeGenName = possibleCodeGenNames{i};                       
        %
        infoStruct = coder.internal.infoMATFileMgr( ...
                        action, ...
                        minfo_or_binfo, ...
                        possibleCodeGenName, ...
                        mdlRefTgtType, ...
                        binfoFile, ...
                        loadConfigSet);
                       
        % get subsystem from binfo infoStruct
        originalSystem = infoStruct.SourceSubsystemName;
        if strcmp(originalSystem, fullSystemPath)
            % get timestamp for this file
            d = dir(binfoFile);
            currentTimeStamp = d.datenum;
            if currentTimeStamp > latestTimeStamp
                % found new match
                latestTimeStamp = currentTimeStamp;
                codeGenName = possibleCodeGenName;
                
                subsystemFolders = buildFolders.copyAndUpdateModelName(codeGenName);
                
                buildDir = fullfile(rootBuildDir, subsystemFolders.CodeGeneration.ModelCode);                
            end
        end
    end
end
