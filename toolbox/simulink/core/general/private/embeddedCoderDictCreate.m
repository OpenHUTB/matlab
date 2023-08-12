






function varargout = embeddedCoderDictCreate( varargin )



url = simulinkcoder.internal.app.ViewSDP( '', 'CreateAndSave', true );
if nargout == 1
varargout{ 1 } = url;
end 
end 

function varargout = createDataInterfaceAutomatically( varargin )%#ok
ddFilepath = '';
[ filename, pathname ] = uiputfile(  ...
{ '*.sldd', 'Data Dictionary files (*.sldd)'; ...
'*.*', 'All Files (*.*)' },  ...
'Create a new Data Dictionary' );
if ~isequal( filename, 0 ) && ~isequal( pathname, 0 )

ddFilepath = fullfile( pathname, filename );
if exist( ddFilepath, 'file' )
try 
Simulink.dd.delete( ddFilepath );
catch e
errordlg( e.message, DAStudio.message( 'SLDD:sldd:CreateNewDataDictionary' ) );
end 
end 
if ~exist( ddFilepath, 'file' )
try 
dd1 = Simulink.dd.create( ddFilepath, 'SubdictionaryErrorAction', 'warn' );
if dd1.isOpen
if ( nargin < 1 ) || ( islogical( varargin{ 1 } ) && varargin{ 1 } )
dd1.explore;
end 


simulinkcoder.internal.app.ViewSDP( '' )
end 

catch e
errordlg( e.message, DAStudio.message( 'SLDD:sldd:CreateNewDataDictionary' ) );

if ~strcmpi( e.identifier, 'SLDD:sldd:SlddFileWithSameNameAlreadyOpen' )
Simulink.data.dictionary.closeAll( filename, '-discard' );
end 
if isfile( ddFilepath )
delete( ddFilepath );
end 
ddFilepath = '';
end 
else 
ddFilepath = '';
end 
end 

if nargout == 1
varargout{ 1 } = ddFilepath;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpjdcsIN.p.
% Please follow local copyright laws when handling this file.

