%ADDENTRY Insert a new entry into a dictionary
%
%   ADDENTRY(sectionObj, entryName, entryValue) adds an entry, with 
%   name entryName and value entryValue, to the data dictionary section 
%   sectionObj, a Simulink.data.dictionary.Section object.
%
%   entryObj = ADDENTRY(sectionObj, entryName, entryValue) returns a
%   Simulink.data.dictionary.Entry object representing the newly added 
%   data dictionary entry.
%
%    Examples:
%
%       % Add an entry to the data dictionary section, with myNewEntry as
%       % its name and a Simulink.Parameter object as its value 
%       ADDENTRY(sectionObj, 'myNewEntry', Simulink.Parameter);
%
%   See also IMPORTFROMBASEWORKSPACE, IMPORTFROMFILE, DELETEENTRY
%   SIMULINK.DATA.DICTIONARY.SECTION

% Copyright 2014 The MathWorks, Inc.
