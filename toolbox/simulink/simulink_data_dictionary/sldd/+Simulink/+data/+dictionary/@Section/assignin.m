%ASSIGNIN Assign value to data dictionary entry
%
%   ASSIGNIN(sectionObj, entryName, entryValue) assigns the value 
%   entryValue to the data dictionary entry entryName in the data 
%   dictionary section sectionObj, a Simulink.data.dictionary.Section
%   object. 
%
%   If an entry with the specified name is not in the target
%   section, ASSIGNIN creates the entry with the specified name and value.
%
%   If an entry with the name entryName is not defined in the target 
%   data dictionary section but is defined in a referenced dictionary,
%   ASSIGNIN does not create a new entry in the target section but 
%   operates on the entry in the referenced dictionary.
%
%   See also EVALIN, ADDENTRY, SIMULINK.DATA.DICTIONARY.SECTION,

% Copyright 2014 The MathWorks, Inc.
