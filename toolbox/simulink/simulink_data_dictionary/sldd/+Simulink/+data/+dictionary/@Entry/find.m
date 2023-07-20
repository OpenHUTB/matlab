%FIND Search in array of data dictionary entries
%
%   foundEntries = FIND(targetEntries, <conditions>)
%   returns an array of matching entries that were found in the array of
%   data dictionary entries targetEntries. This syntax can match the search
%   criteria <conditions> either with the properties of the entries or with
%   the properties of their values.
%         
%   Optional conditions:
%
%     '-value':     
%       This option causes FIND to search only in the values of the input
%       entries. Specify this option before any other search conditions or
%       options.  
%
%     PName1,PValue1, ... , PNameN,PValueN:
%       This condition is specified as one or more name-value pairs
%       representing names and values of properties of the input entries or
%       of their values. If you specify more than one name-value pair, the
%       returned entries meet all of the criteria. If you include the
%       '-value' option to search in the values of the entries, the search
%       conditions apply to the values of the entries rather than to the
%       entries themselves. 
%
%     '-property',propertyName:
%       This name-value pair causes FIND to search for entries, or their
%       values if you use the '-value' option, that have the property
%       propertyName regardless of the value of the property.  
% 
%     '-class',className:
%       This name-value pair causes FIND to search for entries, or their
%       values if you use the '-value' option, that are objects of the
%       class className. Specify className as a string.   
% 
%     '-isa',className:
%       This name-value pair causes FIND to search for entries, or their
%       values if you use the '-value' option, that are objects of the
%       class or of any subclass derived from the class className.  
%
%     '-and', '-or', '-xor', '-not':
%       These logical-operator options modify or combine multiple search
%       conditions
%
%     '-regexp':
%       This option allows you to use regular expressions in your search
%       condition. This option affects only search condition that follow
%       '-regexp', e.g., 
%          foundEntries = FIND(targetEntries, '-regexp', 'P1Name', 'regularExp') or 
%          foundEntries = FIND(targetEntries, '-value', '-regexp', 'P1Name', 'regularExp')
%       searches entries or values (depending on '-value' option) using
%       regular expressions as if the value of the property P1Name is
%       passed to REGEXP as:
%          regexp('P1Name', 'regularExp').  
%
%    Examples:
%
%       % Search for entries that were last
%       % modified by the user jsmith 
%       foundEntries = FIND(targetEntries, 'LastModifiedBy', 'jsmith')
%
%       % Search for entries that were last modified by the user jsmith or
%       % whose names begin with fuel   
%       foundEntries = FIND(targetEntries, ...
%                           'LastModifiedBy', 'jsmith', '-or', ...
%                           '-regexp', 'Name', 'fuel*')
%
%       % Search for entries whose values are Simulink.Parameter objects
%       % and have a 'DataType' property set to 'int8' 
%       foundEntries = FIND(targetEntries, ...
%                           '-value', ...
%                           '-class', 'Simulink.Parameter', '-and', ...
%                           'DataType', 'int8') 
%
%   See also SIMULINK.DATA.DICTIONARY.ENTRY,
%   SIMULINK.DATA.DICTIONARY.SECTION.FIND

% Copyright 2014 The MathWorks, Inc.


