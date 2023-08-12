

classdef SBImportData < handle


properties ( Constant = true )
SUPPORTED_EXTENSIONS = { '.xls', '.xlsx', '.csv', '.mat' };
SUPPORTED_TYPES = { 'Excel', 'CSV', 'MAT' };
end 

properties 
Type = '';
StatusMessage = [  ];
end 


properties ( SetAccess = 'protected', GetAccess = 'protected' )
GroupSignalData = SigSuite.empty;
end 

methods ( Access = protected, Hidden = true )
[ outtime, outdata, sigNames, grpNames ] = readFile( this, varargin );
[ status, msg ] = converttoSBObj( this, intime, indata, grpNames, sigNames );
[ status, msg ] = setGroupSignalData( this, intime, indata, sigNames, grpNames );
end 

methods 















function [ sbobj ] = getSBObj( this )
sbobj = this.GroupSignalData.copyObj;
end 



function type = getType( this )
type = this.Type;
end 


end 


methods ( Static = true )



function sigNames = updateSignalNames( sigCnt, varargin )
if ( nargin < 3 )
sigNames = cell( 1, sigCnt );
for i = 1:sigCnt
sigNames{ i } = [ 'Imported_Signal ', num2str( i ) ];
end 
else 
sigNames = varargin{ 1 };
sigIdx = varargin{ 2 };

for sidx = 1:length( sigIdx )
n = sigIdx( sidx );
sigNames{ n } = [ 'Imported_Signal ', num2str( sidx ) ];
end 
end 

end 



function grpNames = updateGroupNames( grpCnt, varargin )
if ( nargin < 3 )
grpNames = cell( 1, grpCnt );
for i = 1:grpCnt
grpNames{ i } = [ 'Imported_Group ', num2str( i ) ];
end 
else 
grpNames = varargin{ 1 };
grpIdx = varargin{ 2 };
for gidx = 1:length( grpIdx )
n = grpIdx( gidx );
grpNames{ n } = [ 'Imported_Group ', num2str( gidx ) ];
end 
end 
end 



function [ sigNames, grpNames ] = updateGroupSignalNames( sigCnt, grpCnt, sigNames, grpNames )
if ( isempty( sigNames ) )
sigNames = sigbldr.extdata.SBImportData.updateSignalNames( sigCnt );
else 
[ anyEmpty, indices ] = sigbldr.internal.utility.getEmptyCellIndices( sigNames );
if anyEmpty
sigNames = sigbldr.extdata.SBImportData.updateSignalNames( sigCnt, sigNames, indices );
end 
end 
if ( isempty( grpNames ) )
grpNames = sigbldr.extdata.SBImportData.updateGroupNames( grpCnt );
else 
[ anyEmpty, indices ] = sigbldr.internal.utility.getEmptyCellIndices( grpNames );
if anyEmpty
grpNames = sigbldr.extdata.SBImportData.updateGroupNames( grpCnt, grpNames, indices );
end 
end 
end 



function verifyFileName( filename )

if ( isempty( filename ) )
DAStudio.error( 'Sigbldr:sigbldr:emptyFileName' );
end 


if ( ~exist( filename, 'file' ) )
DAStudio.error( 'Sigbldr:sigbldr:invalidFile', filename );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp2UWl6T.p.
% Please follow local copyright laws when handling this file.

