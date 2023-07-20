%SIMULINK.DATA.DICTIONARY.ENTRY Represent a data dictionary entry 
%
%   SIMULINK.DATA.DICTIONARY.ENTRY object represents a data dictionary
%   entry. The object allows you to perform operations on a data dictionary
%   entry such as assign the entry a value or change the name of the entry.
%
%   SIMULINK.DATA.DICTIONARY.ENTRY object can be created by using functions
%   such as getEntry, addEntry, and find on a
%   Simulink.data.dictionary.Section object that represents a data
%   dictionary section. Once created, the Simulink.data.dictionary.Entry
%   object exists independently of the Simulink.data.dictionary.Section
%   object from which it is obtained or created.
%
%   SIMULINK.DATA.DICTIONARY.ENTRY has the following properties:
%     Name            - Name of entry.
%     DataSource      - File name of the data dictionary that defines this
%                       entry.
%     LastModified    - Read only property indicating the date and time the
%                       entry was last modified.
%     LastModifiedBy  - Read only property representing the name of last 
%                       user to modify entry.
%     Status          - Read only property representing the state of entry, 
%                       i.e., 'New', 'Modified', 'Unchanged', or 'Deleted'.
%                       The Status value is valid since the last data 
%                       dictionary save. If the represented entry was
%                       deleted, for instance by the function deleteEntry,
%                       the Status property of the object is set to
%                       'Deleted' and only its Name and Status properties
%                       are accessible.
%
%  Use getValue function to access the current value of an entry. 
%  Use setValue function to assign a new value to an entry.
%
% See also: SIMULINK.DATA.DICTIONARY, SIMULINK.DATA.DICTIONARY.SECTION, GETVALUE, SETVALUE

% Copyright 2014 The MathWorks, Inc.

    
