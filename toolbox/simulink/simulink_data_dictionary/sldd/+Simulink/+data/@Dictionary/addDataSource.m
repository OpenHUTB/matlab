%ADDDATASOURCE Add reference data dictionary to parent data dictionary
%
%   ADDDATASOURCE(dictionaryObj, refDictionaryFile) adds a data dictionary,
%   refDictionaryFile, as a reference dictionary to a parent dictionary
%   represented by dictionaryObj, a Simulink.data.Dictionary object. The
%   parent dictionary  contains all the entries that are defined in the
%   referenced dictionary until the referenced dictionary is removed from
%   the parent dictionary. The DataSource property of an entry indicates
%   the dictionary that defines the entry. 
%
%   The name of the data dictionary to be added as a reference, 
%   refDictionaryFile, shall not include a path and must exist on MATLAB
%   path. 
%
%    Examples:
%
%       % Add the data dictionary mySubDictionary.sldd as a reference
%       % dictionary to data dictionary dictionaryObj
%       ADDDATASOURCE(dictionaryObj, 'mySubDictionary.sldd');
%
%   See also REMOVEDATASOURCE, SIMULINK.DATA.DICTIONARY,
%   SIMULINK.DATA.DICTIONARY.ENTRY

% Copyright 2014 The MathWorks, Inc.
