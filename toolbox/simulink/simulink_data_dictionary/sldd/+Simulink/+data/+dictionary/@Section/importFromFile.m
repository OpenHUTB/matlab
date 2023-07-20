%IMPORTFROMFILE Import variables from MAT or MATLAB file to data dictionary
%section
%
%   [importedVars, existingVars] = IMPORTFROMFILE(sectionObj, fileName)
%   imports variables defined in the MAT or MATLAB file fileName to the
%   data dictionary section sectionObj without overwriting any variables
%   that are already in the target section. If any variables are already in
%   the data dictionary section, IMPORTFROMFILE presents a warning and a
%   list of them. Alternatively, you can return a list of the existing
%   variables using the output argument existingVars.
%
%   [importedVars, existingVars] = IMPORTFROMFILE(sectionObj, fileName, 'Name', Value)
%   imports variables from a file to a target data dictionary section, with
%   additional options specified by a Name-Value pair argument.   
%
%   Optional Name-Value Pair Argument:
%
%     -'existingVarsAction' : Action to take for existing dictionary
%     variables 
%       'none' (default): Attempts to import target variables but does not
%                         import or makes any changes to variables that are
%                         already in the data dictionary section. 
%       'overwrite':      Imports all target variables and overwrites any
%                         variables that are already in the data dictionary
%                         section.
%       'error':          Issues an error, without importing any variables,
%                         if any target variables are already in the data
%                         dictionary section.
%
%   Return argument:
%
%     importedVars : Successfully imported variables
%       Cell array of names of successfully imported variables. A variable
%       is considered successfully imported only if IMPORTFROMFILE assigns
%       the value of the variable to the corresponding entry in the target
%       data dictionary section.
%
%     existingVars : Variables that were not imported
%       Cell array of names of variables that were not imported due to
%       their existence in the target data dictionary section. existingVars
%       has content only if the input argument 'existingVarsAction' is
%       'none' (default). In that case IMPORTFROMFILE does not import
%       variables that are already in the target data dictionary section.
%
%    Examples:
%
%       % Attempt to import all variables contained in the file myData.mat
%       % to the data dictionary section. If some of them are already in
%       % the data dictionary section, present a warning and do not import
%       % them
%       IMPORTFROMFILE(sectionObj, 'myData.mat');
%
%       % Attempt to import all variables contained in the file myData.m
%       % to the data dictionary section. If some of them are already in
%       % the data dictionary section, return their names in output
%       % argument unsuccessfulImports and do not import them   
%       [successfulImports, unsuccessfulImports] = ...
%          IMPORTFROMFILE(sectionObj, 'myData.mat');
%
%       % Attempt to import all variables contained in the file myData.m
%       % to the data dictionary section. If some of them are already in
%       % the data dictionary section, overwrite the corresponding data
%       % dictionary entry
%       IMPORTFROMFILE(sectionObj, 'myData.m', ...
%                      'existingVarsAction', 'overwrite');
%
%                               
%   See also EXPORTTOFILE, IMPORTENUMTYPES,
%   SIMULINK.DATA.DICTIONARY.SECTION 

% Copyright 2014 The MathWorks, Inc.
