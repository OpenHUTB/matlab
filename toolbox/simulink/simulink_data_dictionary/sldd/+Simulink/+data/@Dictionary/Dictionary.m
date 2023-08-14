%SIMULINK.DATA.DICTIONARY represents a data dictionary
%
%   SIMULINK.DATA.DICTIONARY object represents a data dictionary. The 
%   object allows you to perform operations on the data dictionary 
%   as a whole such as save or discard changes, add other data 
%   dictionaries as references, and import data from the base workspace.
%
%   SIMULINK.DATA.DICTIONARY object is created when creating a new 
%   dictionary through Simulink.data.dictionary.create or opening 
%   an existing dictionary through Simulink.data.dictionary.open
%
%   SIMULINK.DATA.DICTIONARY has the following read only properties:
%     DataSources        - A list of file names of the dictionary's 
%                          directly referenced data dictionaries 
%     HasUnsavedChanges  - Indicate if the dictionary (or any of its 
%                          references) has unsaved changes. The value is 1
%                          if changes have been made since last save and 0 
%                          if not
%     NumberOfEntries    - Total number of entries in data dictionary, 
%                          including those in referenced dictionaries
%
% See also: SIMULINK.DATA.DICTIONARY.CREATE, SIMULINK.DATA.DICTIONARY.OPEN

% Copyright 2014 The MathWorks, Inc.
