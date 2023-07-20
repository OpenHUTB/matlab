%DELETEENTRY Delete data dictionary entry from section
%
%   DELETEENTRY(sectionObj, entryName) deletes a data dictionary
%   entry entryName from the data dictionary section sectionObj, a
%   Simulink.data.dictionary.Section object. If there are multiple entries
%   with the same name (defined more than once in a hierarchy of reference
%   dictionaries), all the entries are deleted.
%
%   DELETEENTRY(sectionObj, entryName, 'DataSource', dictionaryName)
%   deletes an entry that is defined in the data dictionary DictionaryName.
%   Use this syntax to uniquely identify an entry that may be defined more
%   than once in a hierarchy of referenced data dictionaries.
%
%   If you associate a data dictionary entry with one or more 
%   Simulink.data.dictionary.Entry objects and later delete the entry 
%   using the DELETEENTRY function, the objects remain with their Status
%   property set to 'Deleted'. 
%
%    Examples:
%
%       % Delete all entries named myEntry from a data dictionary section
%       DELETEENTRY(sectionObj, 'myEntry');
%
%       % Delete the only entry named myEntry that is defined in a section
%       % of a reference dictionary myRefDictionary.sldd  
%       DELETEENTRY(sectionObj, ...
%                   'myEntry', 'DataSource', 'myRefDictionary.sldd');
%
%   See also ADDENTRY, SIMULINK.DATA.DICTIONARY.SECTION,
%   SIMULINK.DATA.DICTIONARY.ENTRY

% Copyright 2014 The MathWorks, Inc.

