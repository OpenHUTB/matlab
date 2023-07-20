%GETENTRY Get Simulink.data.dictionary.Entry object representing a data
%dictionary entry
%
%   entries = GETENTRY(sectionObj, entryName) creates and returns an array
%   of Simulink.data.dictionary.Entry objects representing data dictionary
%   entries entryName found in the data dictionary section sectionObj, a
%   Simulink.data.dictionary.Section object. GETENTRY returns multiple
%   objects if multiple entries have the specified name in a reference
%   hierarchy of data dictionaries. 
%
%   entryObj = GETENTRY(sectionObj, entryName, 'DataSource', dictionaryName) 
%   returns an object representing a data dictionary entry that is defined
%   in the data dictionary dictionaryName. Use this syntax to uniquely
%   identify an entry that is defined more than once in a  hierarchy of
%   referenced data dictionaries. 
%
%
%    Examples:
%
%       % Get all entries named myEntry from a data dictionary section
%       entries = GETENTRY(sectionObj, 'myEntry');
%
%       % Get the only entry named myEntry that is defined in a section of
%       % a referenced dictionary myRefDictionary.sldd 
%       entryObj = GETENTRY(sectionObj, 'myEntry', ...
%                           'DataSource', 'myRefDictionary.sldd');
%
%   See also DELETEENTRY, SIMULINK.DATA.DICTIONARY.SECTION, 
%   SIMULINK.DATA.DICTIONARY.ENTRY

% Copyright 2014 The MathWorks, Inc.

