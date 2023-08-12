function ddFilePath = createVariantDict( ddConn, varargin )




addAsRef = true;
if ( nargin > 1 ) && islogical( varargin{ 1 } )
addAsRef = varargin{ 1 };
end 
ddFilePath = '';
variant = '';
options.Resize = 'on';
variant = inputdlg( DAStudio.message( 'SLDD:sldd:VariantCondition' ),  ...
DAStudio.message( 'SLDD:sldd:CreateVariantDictionary' ),  ...
1, { '' }, options );

if ~isempty( variant ) && ~isempty( variant{ : } )
ddFilePath = slprivate( 'slddCreate', false );
if ~isempty( ddFilePath )
ddRef = Simulink.dd.open( ddFilePath );
ddRef.setVariant( variant{ : } );
ddRef.saveChanges(  );
ddRef.close(  );
[ ~, name, ext ] = fileparts( ddFilePath );
if addAsRef
ddConn.addReference( [ name, ext ] );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVsuQjP.p.
% Please follow local copyright laws when handling this file.

