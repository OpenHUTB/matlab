%LISTENTRY List data dictionary entries
%
%   LISTENTRY(dictionaryObj) displays in the MATLAB command prompt a table
%   of information about all the entries in the data dictionary
%   dictionaryObj, a Simulink.data.Dictionary object. The displayed
%   information includes 
%     - the entry name
%     - the name of the containing section
%     - the entry status
%     - the date and time an entry was last modified
%     - the last username who modified an entry
%     - the class of the value an entry contains 
%   By default, the function sorts the list of entries alphabetically by
%   entry name. 
%
%   LISTENTRY(sectionObj, Name1, Value1, ...) displays the entries in a
%   data dictionary with additional options specified by one or more
%   Name,Value pair arguments.
%         
%   Optional Name-Value Pair Arguments:
%
%     - 'Ascending' : Sort order of list, by entry name (default) or by
%     other properties using the option 'SortBy'. 
%       true(default): Sorts the list in descending order.
%       false:         Sorts the list in ascending order.
%
%     - 'Class' : Filter list by class
%       Lists only entries whose values are of the specified class.
%
%     - 'LastModifiedBy' : Filter list by username of last modifier 
%       Lists only entries that were last modified by the specified
%       username.
%
%     - 'Limit' : Maximum number of entries to list
%       Lists up to the specified number of entries.
%
%     - 'Name' : Filter list by entry name
%       Lists only entries whose names match the filter criteria. You can
%       use an asterisk character, *, as a wildcard to represent any number
%       of characters.
%
%     - 'Section' : Filter list by data dictionary section
%       Lists only entries that are contained in the specified section.
%
%     - 'SortBy' : Sort list by a specific property
%       Valid values include 'Name' (default), 'Section', 'LastModified',
%       and 'LastModifiedBy'. You can choose to sort the list of entries in
%       ascending order (default), or descending order using the option
%       'Ascending'.
%
%    Examples:
%
%       % List all the entries in data dictionary
%       LISTENTRY(dictionaryObj)
%
%       % List all the entries in data dictionary and sort them in
%       % descending order by entry name   
%       LISTENTRY(dictionaryObj, 'Ascending', false);
%
%       % Filter list of data dictionary entries by Name - list only the
%       % entries whose names begin with max
%       LISTENTRY(dictionaryObj, 'Name', 'max*');
%
%       % List all entries in data dictionary and sort them by the date
%       % and time each entry was last modified 
%       LISTENTRY(dd1, 'SortBy', 'LastModified');
%
%   See also SIMULINK.DATA.DICTIONARY, SIMULINK.DATA.DICTIONARY.ENTRY

% Copyright 2014 The MathWorks, Inc.
