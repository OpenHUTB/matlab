%IMPORTENUMTYPES Import enumerated type definitions to data dictionary
%
%   [importedTypes, importFailures] = importEnumTypes(dictionaryObj, targetTypes)
%   imports to the data dictionary identified by dictionaryObj the 
%   definitions of one or more enumerated types identified by targetTypes. 
%
% Input arguments:
%   1.dictionaryObj:
%     Target data dictionary, specified as a Simulink.data.Dictionary object.
%         
%   2.targetTypes:
%     Enumerated type definitions to import, specified as a cell array of 
%     enumerated type names. If any target types are defined using classdef
%     blocks in MATLAB or P-files, the files must be on MATLAB path.
%
% Return arguments:
%   1.importedTypes:
%     Target enumerated type definitions successfully imported, returned as
%     an array of structures. Each structure in the array represents one 
%     imported type. The className field of each structure identifies a 
%     type by name and the renamedFiles field identifies any renamed MATLAB
%     and/or P-files.
%
%   2.importFailures:
%     Enumerated type definitions targeted but not imported, returned as 
%     an array of structures. Each structure in the array represents one 
%     type not imported. The className field of each structure identifies
%     a type by name and the reason field explains the failure.
%
% NOTE:
%   - IMPORTENUMTYPES does not import MATLAB variables created using 
%     enumerated types but instead, in support of those variables, imports
%     the definitions of the types. The target data dictionary stores the
%     definition of a successfully imported type as an entry. Before you
%     can import an enumerated data type definition to the target data
%     dictionary, you must clear the base workspace of any variables
%     created using the target type. 
%   - If an enumerated type to be imported is defined using a classdef
%     block in a MATLAB or P-file, IMPORTENUMTYPES imports the type
%     definition directly from the file if the file is on the MATLAB path.
%     In order to avoid conflicting definitions for the imported type, 
%     IMPORTENUMTYPES automatically renders the MATLAB and/or P-file
%     ineffective by appending a .save extension. The .save extension
%     forces variables to rely on the type definition in the target data
%     dictionary and not on the definition in the original MATLAB or
%     P-file. You can remove the .save extension to restore the file to its
%     original state. 
%   - If an enumerated type to be imported is defined using the
%     Simulink.defineIntEnumType function, IMPORTENUMTYPES does not rename
%     any file, because such type is not defined using MATLAB or P-file.
%
%   See also IMPORTFROMBASEWORKSPACE, SIMULINK.DATA.DICTIONARY

% Copyright 2014 The MathWorks, Inc.


