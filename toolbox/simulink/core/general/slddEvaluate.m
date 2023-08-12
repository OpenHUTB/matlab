function outputValue = slddEvaluate( varargin )







outputValue = [  ];
bIncludePath = true;


dd1 = Simulink.dd.open( varargin{ 1 } );


if ( dd1.isOpen )



if ( nargout == 0 )

dd1.getEntry( varargin{ 2 } )

elseif ( nargout == 1 )
try 
if ( varargin{ 3 } )
ddEntryInfo = dd1.getEntryInfo( varargin{ 2 } );
else 
ddEntryInfo = dd1.getEntryAtRevertPoint( varargin{ 2 } );
try 
tmp = dd1.getEntryInfo( varargin{ 2 } );
catch 
if isempty( ddEntryInfo.Status )
ddEntryInfo.Status = 'Del';
end 
end 
end 
ddValue = ddEntryInfo.Value;
catch 
ddValue = Simulink.dd.NullValue;
end 

if ( ~isa( ddValue, 'Simulink.dd.NullValue' ) )
path = '';
if bIncludePath
[ ~, dictName, dictExt ] = fileparts( varargin{ 1 } );
nodename = dd1.getEntryParentName( varargin{ 2 } );
path = [ dictName, dictExt, '/', nodename ];
end 
outputValue = slprivate( 'wrapComparisonItem', ddEntry, ddEntryInfo.Name, ddValue, path, bIncludePath );

outputValue.addprop( 'DataSource' );
outputValue.addprop( 'LastModified' );
outputValue.addprop( 'LastModifiedBy' );
outputValue.addprop( 'Status' );

outputValue.DataSource = ddEntryInfo.DataSource;
outputValue.LastModified = Simulink.dd.private.convertISOTimeToLocal( ddEntryInfo.LastModified );
outputValue.LastModifiedBy = ddEntryInfo.LastModifiedBy;
outputValue.Status = ddEntryInfo.Status;
else 
outputValue = ddValue;
end 
end 
dd1.close(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNqKMgn.p.
% Please follow local copyright laws when handling this file.

