%IMPORTFROMBASEWORKSPACE Import base workspace variables to data dictionary
%
%   [importedVars, existingVars] = IMPORTFROMBASEWORKSPACE(dictionaryObj)
%   imports all variables from the MATLAB base workspace to the data
%   dictionary dictionaryObj without overwriting existing entries in the
%   dictionary. If any base workspace variables are already in the data
%   dictionary, IMPORTFROMBASEWORKSPACE presents a warning and a list of
%   them.
%
%   [importedVars, existingVars] = IMPORTFROMBASEWORKSPACE(dictionaryObj, 'Name1', Value1, ...)
%   imports base workspace variables to a data dictionary, with additional
%   options specified by one or more Name-Value pair arguments.
%         
%   Optional Name-Value Pair Arguments:
%
%     - 'clearWorkspaceVars' : Flag to clear base workspace of imported variables 
%       false(default): Does not clear the base workspace of any
%                       successfully imported variables. 
%       true:           Clears the base workspace of any successfully imported
%                       variables.
%
%     - 'existingVarsAction' : Action to take for existing dictionary variables 
%       'none'(default): Attempts to import target variables but does not
%                        import or makes any changes to variables that are
%                        already in the data dictionary.
%       'overwrite':     Imports all target variables and overwrites any
%                        variables that are already in the data dictionary
%                        section.
%       'error':         Issues an error, without importing any variables,
%                        if any target variables are already in the data
%                        dictionary. 
%
%     - 'varList' : Variables to import 
%       Cell array of names of selective variables to import. Default
%       option value is empty to import all variables. 
%
%   Return arguments:
%
%     importedVars : Successfully imported variables
%       Names of successfully imported variables, returned as a cell array
%       of strings. A variable is considered successfully imported only if 
%       IMPORTFROMBASEWORKSPACE assigns the value of the variable to the 
%       corresponding entry in the target data dictionary.
%
%     existingVars : Variables that were not imported
%       Names of target variables that were not imported due to their 
%       existence in the target data dictionary, returned as a cell array
%       of strings. existingVars has content only if the input argument 
%       'existingVarsAction' is 'none' (default). In that case 
%       IMPORTFROMBASEWORKSPACE does not import variables that are already
%       in the target data dictionary.
%
%    Examples:
%
%       % Import all base workspace variables to the data dictionary 
%       IMPORTFROMBASEWORKSPACE(dictionaryObj);
%
%       % Import only the variables X, Y, and Z to the data dictionary
%       IMPORTFROMBASEWORKSPACE(dictionaryObj, ...
%                               'varList', {'X', 'Y', 'Z'});
%
%       % Import the variable 'existVar' and overwrite the corresponding
%       % entry in the data dictionary if it already exists
%       IMPORTFROMBASEWORKSPACE(dictionaryObj, ...
%                               'varList', {'existVar'}, ...
%                               'existingVarsAction', 'overwrite');
%
%       % Import the variables 'X' and 'Y' and return their names in output
%       % argument successfulImports if they are not in the data dictionary.
%       % Attempt to import the variables 'existVar1' and 'existVar2'. If
%       % they are already in the dictionary, return their names in output
%       % argument unsuccessfulImports and do not import them 
%       [successfulImports, unsuccessfulImports] = ...
%            IMPORTFROMBASEWORKSPACE(dictionaryObj, 'varList', ...
%                                    {'X', 'Y', 'existVar1', 'existVar2'}); 
%                               
%   See also IMPORTENUMTYPES, SIMULINK.DATA.DICTIONARY

% Copyright 2014 The MathWorks, Inc.
