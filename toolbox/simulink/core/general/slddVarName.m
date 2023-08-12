function outputValue = slddVarName( varargin )







outputValue = [  ];


dd1 = Simulink.dd.open( varargin{ 1 } );


if ( dd1.isOpen )



if ( nargout == 1 )
try 
if ( varargin{ 3 } )
entryInfo = dd1.getEntryInfo( varargin{ 2 } );
outputValue = entryInfo.Name;
else 
entryInfo = dd1.getEntryAtRevertPoint( varargin{ 2 } );
outputValue = [ entryInfo.Name, ' (previous)' ];
end 
catch 
end 
if isempty( outputValue )
if ( varargin{ 3 } )
outputValue = '(no entry at current point)';
else 
outputValue = '(no entry at revert point)';
end 
end 
end 

dd1.close(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3RH5fj.p.
% Please follow local copyright laws when handling this file.

