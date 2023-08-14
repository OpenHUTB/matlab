function verInfo = ver(arg)
%VER MATLAB, Simulink and toolbox version information.
%   VER displays MathWorks product family header information, followed by 
%   the current MATLAB, Simulink and toolbox version information.
%
%   VER(TOOLBOX_DIR) displays the current version information for the
%   toolbox specified by the string scalar or character vector TOOLBOX_DIR.
%
%   A = VER returns in A the sorted struct array of version information on
%   all toolboxes on the MATLAB path.
%
%   The definition of struct A is:
%           A.Name      : toolbox name
%           A.Version   : toolbox version number
%           A.Release   : toolbox release name
%           A.Date      : toolbox release date
%
%   For example,
%      ver control
%     displays the version info for the Control System Toolbox.
%      A = ver('control');
%     returns in A the version information for the Control System Toolbox.
%
%   See also LICENSE, verLessThan, VERSION, WHATSNEW.

%   Copyright 1984-2019 The MathWorks, Inc.

% Handle number of outputs, displaying general MATLAB information if no
% output argument exists.
if nargout > 0
   isArgout = true;
else
   isArgout = false;
   locDisplayMatlabInformation;
end

if nargin > 0
    arg = convertStringsToChars(arg);
end

showSupportInfo = false;
if nargin > 0
   if ~ischar(arg)
       verStruct = locInitializeVerStruct;
       warning(message('MATLAB:ver:NotAString'));
   elseif strcmpi(arg, '-support')
       showSupportInfo = true;
       % Get information and licensing about all toolboxes.
       verStruct = locGetAllToolboxInfo;
       licInfo = locGetLicenseInfo({verStruct.Name});
       for prodIdx = 1:length(verStruct)
           verStruct(prodIdx).Licenses = licInfo{prodIdx};
       end
   else
       % Get information about a particular toolbox.
       verStruct = locGetSingleToolboxInfo(arg);
       if isempty(verStruct) && ~isArgout
           warning(message('MATLAB:ver:NotFound', arg));
       end
   end
else
    % Get information about all toolboxes.
    verStruct = locGetAllToolboxInfo;
end

if isArgout
   % Return toolbox version information as struct.
   verInfo = verStruct;
else
   % Display toolbox version information on screen.
   locDisplayToolboxList(verStruct, showSupportInfo);
end

end
%--------------------------------------------------------------------------
function locationInfo = locGetMatlabToolboxLocation
% LOCGETMATLABTOOLBOXLOCATION Get folder containing MATLAB Contents.m file
% Return:
%   locationInfo: string containing folder where the Contents.m file for
%                 MATLAB is located

persistent theLocation
if isempty(theLocation)
    theLocation = fullfile(toolboxdir('matlab'), 'general/Contents.m');
end
locationInfo = theLocation;

end
%--------------------------------------------------------------------------
function structInfo = locParseContentsFiles(fNameList)
% LOCPARSECONTENTSFILES  Extract toolbox information from Contents.m file
% Input:
%   fNameList:  cell string array containing MATLAB Contents.m list
% Return:
%   structInfo: struct array defining toolbox information

structInfo = locInitializeVerStruct;
for idx = 1:length(fNameList)
    
    currentFName = fNameList{idx};
    fid = fopen(currentFName,'r');
    if fid < 0
        continue;
    end
    cleanup.fid = onCleanup(@()fclose(fid));
    productName = locParseLineFromFile(fid);
    detailsLine = locParseLineFromFile(fid);

    % If the productName has a trailing period, remove it.
    if ~isempty(productName) && productName(end)=='.'
        productName(end)=[];
    end

    % If the Contents.m file is for MATLAB itself, process it differently.
    if ~isempty(strfind(currentFName, locGetMatlabToolboxLocation))
        % The first line is not used to designate the product (i.e.,
        % MATLAB). Instead, the product is designated at the beginning of
        % the second line.
        productName = 'MATLAB';
        % Look for Version.
        [~,detailsLine] = strtok(detailsLine, 'Version'); %#ok<STTOK>
    end

    detailsPat = '^Version\s+(\S+)\s*(.*?)\s+(\S+)$';
    details = regexpi(detailsLine, detailsPat, 'once', 'tokens');
    if ~isempty(details)
        currentStructInfo = struct('Name', productName,...
                                   'Version', details{1},...
                                   'Release', details{2},...
                                   'Date', locCleanDate(details{3}));
        structInfo = [structInfo, currentStructInfo]; %#ok<AGROW>
    end
end

end
%--------------------------------------------------------------------------
function verStruct0 = locInitializeVerStruct
% LOCINITIALIZEVERSTRUCT  Initialize structure of toolbox information.
% Return:
%   verStruct0: scalar struct initializing toolbox information structure

verStruct0 = struct('Name', {}, 'Version', {}, 'Release', {}, 'Date', {});

end
%--------------------------------------------------------------------------
function theLine = locParseLineFromFile(fid)
% LOCREADLINEFROMFILE  Read and process line from file
% Input:
%   fid:  file identifier
% Return:
%   theLine: string vector containing line read from file, less comment
%   character and surrounding space.

theLine = fgetl(fid);
if ~ischar(theLine)
    theLine = '';
else
    % Remove comment character.
    theLine = strtrim( theLine(2:end) );
end

end
%--------------------------------------------------------------------------
function locDisplayToolboxList(verStruct, showSupportInfo)
% LOCDISPLAYTOOLBOXLIST  Display toolbox information on screen
% Input:
%   verStruct: struct array of toolbox information, sorted by Name
%   showSupportInfo: scalar logical for displaying License information 

% Convert verStruct to a cell array of strings.
verCell = locConvertStructInfoToDispString(verStruct, showSupportInfo);

% Reorder toolbox display string as follows:
% 1. MATLAB (if it exists)
% 2. SIMULINK (if it exists)
% 3. Other Toolboxes (if they exist), sorted by Name.
productNames = {verStruct(:).Name};
matlabIdx    = find(strcmpi('matlab', productNames), 1);
simulinkIdx  = find(strcmpi('simulink', productNames), 1);
toolboxIdx   = 1:length(verStruct);
toolboxIdx([matlabIdx, simulinkIdx]) = [];
displayOrder = [matlabIdx, simulinkIdx, toolboxIdx];
verCell = verCell(displayOrder);

% Display the list.
disp(char(verCell));

end
%--------------------------------------------------------------------------
function dispString = locConvertStructInfoToDispString(structInfo, showSupportInfo)
% LOCCONVERTSTRUCTINFOTODISPSTRING  Convert product information from struct
% to display string
% Input:
%   structInfo: structure array defining toolbox information
%    showSupportInfo: scalar logical for displaying License information 
% Return:
%   dispString: cell array of toolbox information display strings

VERSION_TITLE = getString(message('MATLAB:ver:Version'));
NAME_WIDTH = 50;  % field width for toolbox name string.
VER_WIDTH  = 16;  % field width for toolbox version string.
REL_WIDTH  = max(7, locGetLengthOfLongestString({structInfo.Release}));

if showSupportInfo
    LICENSE_TITLE = getString(message('MATLAB:ver:License'));
    TRIAL_TITLE   = getString(message('MATLAB:ver:Trial'));
else
    licString = '';
end

nProducts = length(structInfo);
dispString = cell(nProducts, 1);
for idx = 1:nProducts
    
    currStructInfo = structInfo(idx);

    % Get the name and, if it exceeds the maximum length, truncate it.
    productName = currStructInfo.Name;
    if length(productName) > NAME_WIDTH
        productName = [productName(1:NAME_WIDTH-3), '...'];
    end

    verString = [VERSION_TITLE, ' ', currStructInfo.Version];
    relString = currStructInfo.Release;

    if showSupportInfo
        % Display the first license.
        currLicense = currStructInfo.Licenses{1};
        if strncmp(currLicense, 'T', 1)
            licString = [TRIAL_TITLE, ' ', currLicense(2:end)];
        else
            licString = [LICENSE_TITLE, ' ', currLicense];
        end
    end

    dispString{idx} = deblank(sprintf('%-*.*s    %-*s    %-*s      %-s', ...
        NAME_WIDTH, NAME_WIDTH, productName, VER_WIDTH, verString, ...
        REL_WIDTH, relString, licString));

end

end
%--------------------------------------------------------------------------
function locDisplayMatlabInformation
% LOCDISPLAYMATLABINFORMATION  Display general MATLAB installation
% information as a header to the toolbox information section.

% Find platform OS.
platform = system_dependent('getos');
if ispc
   platform = [platform, ' ', system_dependent('getwinsys')];
elseif ismac
    [status, result] = unix('sw_vers');
    if status == 0
        platform = strrep(result, 'ProductName:', '');
        platform = strrep(platform, sprintf('\t'), '');
        platform = strrep(platform, sprintf('\n'), ' ');
        platform = strrep(platform, 'ProductVersion:', ' Version: ');
        platform = strrep(platform, 'BuildVersion:', 'Build: ');
    end
end

% Construct header and display it.
header = {sprintf('MATLAB %s: %s', getString(message('MATLAB:ver:Version')), version);
          sprintf('MATLAB %s: %s', getString(message('MATLAB:ver:LicenseNumber')), license);
          sprintf('%s: %s', getString(message('MATLAB:ver:OperatingSystem')), platform);
          sprintf('Java %s: %s', getString(message('MATLAB:ver:Version')), version('-java'))};
separator = repmat('-', 1,  locGetLengthOfLongestString(header));
fprintf('%s\n', separator, header{:}, separator);

end
%--------------------------------------------------------------------------
function verStruct = locGetSingleToolboxInfo(arg)
% LOCGETSINGLETOOLBOXINFO  Get version information on a specified toolbox
% Input:
%   arg: string vector defining toolbox directory name
% Return:
%   verStruct: struct defining specific toolbox's version information

% Handle deprecated product names and warn
newname = checkRenamedToolboxFolders(arg);
if ~isequal(newname, arg)
    warning(message('MATLAB:ver:ProductNameDeprecated', arg, newname));
    arg = newname;
end

% Note: -caseinsensitive is an undocumented and unsupported feature
whatMatches = what(arg, '-caseinsensitive');
whatList = strcat({whatMatches.path}, filesep, 'Contents.m');
pathList = locGetContentsListFromPath;
contentsList = intersect(whatList, pathList,'legacy');
contentsList = locRemoveUnwantedEntries(contentsList);
contentsList = locRemoveUnwantedFixPointEntries(contentsList);

% Ensure that MATLAB's Contents.m is in contentsList if given a MATLAB arg.
matlabTbx = locGetMatlabToolboxLocation;
matlabTbxPat = [regexptranslate('escape', fullfile(arg)), '([\\/]general)?[\\/]Contents\.m$'];
if ~isempty(arg) && ~isempty(regexpi(matlabTbx, matlabTbxPat, 'once'))
    contentsList = [{matlabTbx}, contentsList];
end

% Parse Contents.m files of filtered toolbox list.
verStruct = locParseContentsFiles(contentsList);

end
%--------------------------------------------------------------------------
function verStruct = locGetAllToolboxInfo
% LOCGETALLTOOLBOXINFO  Sort toolbox information alphabetically
% Return:
%   verStruct: struct array of toolbox information, sorted by Name

% Filter list to those directories which actually contain Contents.m
if isdeployed
    % Calling WHICH in deployed mode loads the file, which fails.
    contentsList = locGetContentsListFromPath;
else
    % Note that this method produces only existent Contents.m candidates.
    contentsList = which('Contents.m', '-all');
end
contentsList = locRemoveUnwantedEntries(contentsList);
contentsList = locRemoveUnwantedFixPointEntries(contentsList);

% Add the MATLAB toolbox to the top of the path list.
if(~isdeployed)
    contentsList = [locGetMatlabToolboxLocation; contentsList];
end

% Parse Contents.m files of filtered toolbox list.
verStruct = locParseContentsFiles(contentsList);

% Sort struct array of version information based on Name.
productNames = {verStruct(:).Name};
[~,idx] = sort(productNames);
verStruct = verStruct(idx);

end
%--------------------------------------------------------------------------
function contentsList = locGetContentsListFromPath
% LOCGETCONTENTSLISTFROMPATH  Construct contents list using the MATLAB path
% Return:
%   contentsList = cell string array of potential Contents.m entries

% Note that this method may produce non-existent Contents.m candidates.
pathList = regexp(matlabpath, pathsep, 'split')';
contentsList = strcat(pathList, filesep, 'Contents.m');

end
%--------------------------------------------------------------------------
function contentsList = locRemoveUnwantedEntries(contentsList)
% LOCREMOVEUNWANTEDENTRIES  Remove unwanted entries from contents list
% Input:
%   contentsList = cell string array containing MATLAB Contents.m list
% Return:
%   contentsList = cell string array containing pruned list

% Construct regular expression search pattern for unwanted path entries.
% Namely, this includes toolbox/matlab and toolbox/local entries, as well
% as entries under class and package directories.
mlrPat = regexptranslate('escape', [matlabroot, filesep]);
pat = ['^', mlrPat, '(toolbox|mcr)[\\/](local|matlab)[\\/]|[\\/][+@]'];

% Remove the unwanted entries.
contentsList(~cellfun('isempty', regexpi(contentsList, pat, 'once'))) = [];

end
%--------------------------------------------------------------------------
function contentsList = locRemoveUnwantedFixPointEntries(contentsList)
% LOCREMOVEUNWANTEDFIXPOINTENTRIES  Remove unwanted toolbox/fixpoint/Contents.m entry
% Input:
%   contentsList = cell string array containing MATLAB Contents.m list
% Return:
%   contentsList = cell string array containing pruned list

mlrPat = regexptranslate('escape', [matlabroot, filesep]);
pat = ['^', mlrPat, '(toolbox)[\\/](fixpoint)[\\/]|[\\/][+@]'];

% Remove the toolbox/fixpoint directory entry from the path list.
contentsList(~cellfun('isempty', regexpi(contentsList, pat, 'once'))) = [];

end
%--------------------------------------------------------------------------
function licenseInfo = locGetLicenseInfo(productName)
% LOCGETLICENSEINFO  Get license information for a product.
% Input:
%   productName: a string defining the product name.
% Output:
%   licInfo:     a cell array of cell strings containing the license(s).

licenseStruct = matlab.internal.licensing.getLicInfo(productName);
licenseInfo   = {licenseStruct.license_number};

end
%--------------------------------------------------------------------------
function lenStr = locGetLengthOfLongestString(aCellStr)
% LOCGETLONGESTSTRINGLENGTH  Get length of longest string in a cell string.
% Input:
%   aCellstr: a cell string containing the license(s).
% Output:
%   lenStr:   a string containing the license for MATLAB.

lenStr = size(char(aCellStr), 2);

end
%--------------------------------------------------------------------------
function cleanDate = locCleanDate(dirtyDate)
% LOCCLEANDATE  forces a date to be in the format of DD-Mmm-YYYY
% Input:
%   dirtyDate: string vector defining a date
% Return:
%   cleanDate: string vector defining the date in the format DD-Mmm-YYYY

slashLoc = strfind(dirtyDate, '-');
if length(slashLoc) > 1
    
   dayStr = dirtyDate(1:slashLoc(1) - 1);
   monthStr = dirtyDate(slashLoc(1) + 1:slashLoc(2) - 1);
   yearStr = dirtyDate(slashLoc(2) + 1:end);
   
   if length(dayStr) == 1
      dayStr = ['0', dayStr];
   end
   
   if length(monthStr) > 2
      monthStr = [upper(monthStr(1)), lower(monthStr(2:3))];
   end
   
   cleanDate = [dayStr, '-', monthStr, '-', yearStr];
   
else
   cleanDate = dirtyDate;
end

end
