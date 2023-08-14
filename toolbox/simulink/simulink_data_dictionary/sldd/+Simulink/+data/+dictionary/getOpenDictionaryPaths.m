%Simulink.data.dictionary.getOpenDictionaryPaths   Get file paths of open
%Simulink data dictionaries.
%   Simulink.data.dictionary.getOpenDictionaryPaths returns the file paths
%   of all open dictionaries that have the specified name, or of all open
%   dictionaries if no name is specified.
%
%   You can specify the target dictionary file name without a file path. If
%   multiple open dictionaries have the specified name,
%   getOpenDictionaryPaths returns multiple file paths.
%
%   Examples:
%
%      1. Get a list of file paths of all open dictionaries named 'mydd.sldd'.
%
%           openDDs =
%           Simulink.data.dictionary.getOpenDictionaryPaths('mydd.sldd')
%      
%         The variable 'openDDs' stores the file paths in a cell array of
%         strings.
%
%      2. Get a list of file paths of all open dictionaries.
%
%           openDDs = Simulink.data.dictionary.getOpenDictionaryPaths
%
%         The variable 'openDDs' stores the file paths in a cell array of
%         strings.
%
%   See also SIMULINK.DATA.DICTIONARY, SIMULINK.DATA.DICTIONARY.CLOSEALL

% Copyright 2015 The MathWorks, Inc.
% Built-in function.
