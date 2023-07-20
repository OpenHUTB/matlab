%EXPORTTOVERSION export the dictionary to a previous version
%
%   EXPORTTOVERSION(dictionaryObj, foldername, version) export dictionary to
%   previous version in the specified folder. ExportToVersion also exports
%   references to the specified folder. The filenames of the dictionary and
%   its references are preserved.
%
%    Examples:
%
%       % Export the data dictionary dictionaryObj to R2018a to the folder
%       % myR2018aFolder
%       EXPORTTOVERSION(dictionaryObj, 'myR2018aFolder', 'R2018a');
%
%   See also SAVECHANGES, SIMULINK.DATA.DICTIONARY

% Copyright 2018 The MathWorks, Inc.
