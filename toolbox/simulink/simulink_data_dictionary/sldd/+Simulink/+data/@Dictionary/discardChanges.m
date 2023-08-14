%DISCARDCHANGES Discard changes to data dictionary
%
%   DISCARDCHANGES(dictionaryObj) discards all changes made to the input
%   data dictionary dictionaryObj, a Simulink.data.Dictionary object, since
%   the last time changes to the dictionary were saved using the
%   saveChanges function. DISCARDCHANGES also discards changes made to
%   referenced data dictionaries. The changes to the dictionary and its
%   referenced dictionaries are permanently lost after using this function.
%
%   See also SAVECHANGES, SIMULINK.DATA.DICTIONARY

% Copyright 2014 The MathWorks, Inc.
