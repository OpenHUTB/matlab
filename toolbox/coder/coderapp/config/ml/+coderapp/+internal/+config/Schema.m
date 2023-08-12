classdef ( Sealed )Schema < handle



properties ( SetAccess = immutable )
Format char
File char
end 

properties ( SetAccess = private )
UpdatedInSession logical = false
end 

properties ( SetAccess = ?coderapp.internal.config.SchemaValidator )
Valid logical = false
end 

properties ( Access = private )
Content char
TypeManager coderapp.internal.config.ParamTypeManager
end 

methods ( Static )
function schema = fromFile( file, format )
R36
file{ isfile( file ) }
format{ mustBeMember( format, { 'xml', 'json', '' } ) } = ''
end 
if ~isfile( file )
error( 'Could not find file "%s"', file );
end 
if isempty( format )
[ ~, ~, ext ] = fileparts( file );
if strcmp( ext, '.xml' )
format = 'xml';
else 
format = 'json';
end 
end 
schema = coderapp.internal.config.Schema( format, '', file );
end 
end 

methods ( Static, Access = ?coderapp.internal.config.SchemaValidator )
function schema = new( format, contents )
R36
format{ mustBeMember( format, { 'xml', 'json' } ) }
contents( 1, : )char
end 
schema = coderapp.internal.config.Schema( format, contents );
end 
end 

methods ( Access = private )
function this = Schema( format, contents, file )
this.Format = format;
this.Content = contents;
if nargin > 2
this.File = file;
end 



this.Valid = ~isempty( this.File );
end 
end 

methods 
function [ schemaData, typeManager, mfzModel ] = load( this, mfzModel )
R36
this( 1, 1 )
mfzModel( 1, 1 )mf.zero.Model = mf.zero.Model(  )
end 

if ~this.Valid
error( 'Cannot load an invalid schema' );
elseif nargin == 1 && nargout < 3
error( 'If no mf.zero.Model model object is provided, then callers must accept a third output' );
end 

prior = mfzModel.topLevelElements(  );

if this.Format == "xml"
deser = mf.zero.io.XmlParser(  );
else 
deser = mf.zero.io.JSONParser(  );
end 
deser.Model = mfzModel;
deser.RemapUuids = true;
if ~isempty( this.Content )
deser.parseString( this.Content );
elseif isfile( this.File )
deser.parseFile( this.File );
else 
error( 'No embedded content and no file "%s" found', this.File );
end 

schemaData = mfzModel.topLevelElements(  );
schemaData = getSchemaData( schemaData( ~ismember( { schemaData.UUID }, { prior.UUID } ) ) );

typeManager = this.TypeManager;
if isempty( typeManager )

typeManager = schemaData.ParamTypeManager;
if isempty( typeManager )
if nargout < 2
return 
end 
typeManager = coderapp.internal.config.ParamTypeManager(  );
else 
schemaData.ParamTypeManager = [  ];
end 
if ~isempty( schemaData.CustomTypes )
typeManager.registerTypes( cellstr( schemaData.CustomTypes ) );
end 
this.TypeManager = typeManager;
end 
end 

function save( this, filename )
if ~this.Valid
error( 'Cannot save an invalid schema' );
elseif codergui.internal.undefined( this.Content )
error( 'Cannot save an empty schema' );
elseif nargin < 2 || isempty( filename )
filename = this.File;
if isempty( filename )
error( 'Specify a file to save to' );
end 
end 
folder = fileparts( filename );
if ~isempty( folder ) && ~isfolder( folder )
mkdir( folder );
end 
fid = fopen( filename, 'w', 'n', 'utf-8' );
fprintf( fid, '%s', this.Content );
fclose( fid );
end 
end 

methods ( Access = ?coderapp.internal.config.Configuration )
function updateContent( this, content )
R36
this( 1, 1 )
content{ mustBeTextScalar( content ) }
end 
this.Content = content;
this.UpdatedInSession = true;
end 
end 
end 


function sd = getSchemaData( els )
metaClasses = [ els.MetaClass ];
sd = els( strcmp( { metaClasses.mcosName }, 'coderapp.internal.config.schema.SchemaData' ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpERH84O.p.
% Please follow local copyright laws when handling this file.

