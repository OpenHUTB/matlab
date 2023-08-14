%REMOVEDATASOURCE Remove reference data dictionary from parent data
%dictionary
%
%   REMOVEDATASOURCE(dictionaryObj, refDictionaryFile) removes a referenced
%   data dictionary, refDictionaryFile, from a parent dictionary
%   dictionaryObj, a Simulink.data.Dictionary object. As a result, the
%   parent dictionary no longer contains the entries that are defined in
%   the referenced dictionary.
%
%   The name of the dictionary to be removed as a reference, 
%   refDictionaryFile, shall not include a path and must exist on MATLAB
%   path.
%
%    Examples:
%
%       % Remove the referenced data dictionary myRefDictionary.sldd from
%       % its parent dictionary dictionaryObj
%       REMOVEDATASOURCE(dictionaryObj, 'myRefDictionary.sldd');
%
%   See also ADDDATASOURCE, SIMULINK.DATA.DICTIONARY

% Copyright 2014 The MathWorks, Inc.
