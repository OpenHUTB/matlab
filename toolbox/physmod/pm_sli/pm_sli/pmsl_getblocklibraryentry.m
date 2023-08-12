function [ entry, errorStruct ] = pmsl_getblocklibraryentry( obj )









narginchk( 1, 1 );

lib = '';
entry = [  ];
errorStruct = [  ];

if isnumeric( obj ) || ischar( obj )
obj = get_param( obj, 'Object' );
end 




linkStatus = pmsl_linkstatus( obj );
if strcmp( linkStatus, 'resolved' ) || strcmp( linkStatus, 'inactive' )
refBlock = obj.ReferenceBlock;
if isempty( refBlock )
refBlock = obj.AncestorBlock;
end 
if isempty( refBlock )
errorStruct = pm_errorstruct( 'physmod:pm_sli:pmsl_getblocklibraryentry:UnresolvedLink' );
else 
lib = extractBefore( refBlock, '/' );
end 
else 



root = obj.getParent;
while ~isempty( root ) && ~isa( root, 'Simulink.BlockDiagram' )
root = root.getParent;
end 

if ~isempty( root ) && root.isLibrary
lib = root;
else 
errorStruct = pm_errorstruct( 'physmod:pm_sli:pmsl_getblocklibraryentry:UnresolvedLink' );
end 
end 


if ~isempty( lib )
if ~ischar( lib )
lib = lib.Name;
end 
libDb = PmSli.LibraryDatabase;
[ isEntry, entries ] = libDb.containsEntry( lib );
if isEntry
entry = entries{ 1 };
else 
errorStruct = pm_errorstruct( 'physmod:pm_sli:pmsl_getblocklibraryentry:UnrecognizedLibrary', lib );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWRANPD.p.
% Please follow local copyright laws when handling this file.

