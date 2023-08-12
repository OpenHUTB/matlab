classdef ( Sealed )ScriptBuilder



properties ( SetAccess = private )
Inputs( 1, 1 )struct = struct
InputTransformers( 1, 1 )struct = struct
Annotations struct = struct( 'tag', {  }, 'metadata', {  } )
Contents cell = {  }
end 

properties 
Title{ mustBeTextScalar( Title ) } = ''
Comment{ mustBeTextScalar( Comment ) } = ''
end 

methods 
function this = ScriptBuilder( varargin )
this = this.append( varargin{ : } );
end 

function this = append( this, varargin )
R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 

contents = varargin( ~cellfun( 'isempty', varargin ) );
for i = 1:numel( contents )
content = contents{ i };
if ~isa( content, 'coderapp.internal.script.ScriptBuilder' )
if ~iscellstr( content )%#ok<ISCLSTR>
contents{ i } = char( content );
elseif isempty( content )
contents{ i } = '';
elseif ~isscalar( content )
contents{ i } = { sprintf( content{ : } ) };
end 
end 
end 
this.Contents( end  + 1:end  + numel( contents ) ) = contents;
end 

function this = appendf( this, format, varargin )
R36
this( 1, 1 )
format{ mustBeTextScalar( format ) }
end 
R36( Repeating )
varargin
end 
this = this.append( sprintf( format, varargin{ : } ) );
end 

function this = input( this, symbol, defaultExpr )
R36
this( 1, 1 )
symbol{ mustBeTextScalar( symbol ) }
defaultExpr{ mustBeTextScalar( defaultExpr ) } = symbol
end 
this.Inputs.( symbol ) = defaultExpr;
end 

function this = transformInput( this, symbol, expr )
R36
this( 1, 1 )
symbol{ mustBeTextScalar( symbol ) }
expr( 1, 1 )function_handle
end 
this.InputTransformers.( symbol ) = expr;
end 

function this = annotate( this, tag, metadata )
R36
this( 1, 1 )
tag{ mustBeTextScalar( tag ) }
metadata{ mustBeTextScalar( metadata ) } = ''
end 
this.Annotations( end  + 1 ).tag = tag;
this.Annotations( end  ).Metadata = metadata;
end 

function varargout = build( obj, varargin )
persistent ip;
if isempty( ip )
ip = inputParser(  );
ip.addParameter( 'Inputs', struct, @isstruct );
ip.addParameter( 'MfzModel', [  ], @( v )isa( v, 'mf.zero.Model' ) );
ip.addParameter( 'UseSections', true, @islogical );
ip.addParameter( 'UseComments', true, @islogical );
ip.addParameter( 'AnnotateComments', false, @islogical );
ip.addParameter( 'ExplicitInputs', false, @islogical );
ip.addParameter( 'ZeroBased', false, @islogical );
ip.addParameter( 'Format', true, @islogical );
end 
ip.parse( varargin{ : } );
context = ip.Results;
ip.parse(  );

sections = cell( 1, numel( obj ) );
annotations = sections;
offset = 0;
for i = 1:numel( obj )
[ sections{ i }, annotations{ i } ] = obj( i ).doBuild( context, offset );
offset = offset + numel( sections{ i } );
end 
code = strjoin( sections, '' );
annotations = [ annotations{ : } ];
[ code, annotations ] = alignAndFormat( code, annotations, context.ZeroBased, context.Format );

if ~isempty( context.MfzModel )
script = coderapp.internal.script.AnnotatedScript( context.MfzModel );
script.Code = code;
if ~isempty( annotations )
script.Annotations = annotations;
end 
varargout{ 1 } = script;
else 
varargout = { code, annotations };
end 
end 
end 

methods ( Access = private )
function [ code, annotations ] = doBuild( this, context, cumOffset )
R36
this( 1, 1 )
context( 1, 1 )struct
cumOffset( 1, 1 )double = 0
end 




flattened = cell( max( numel( this.Contents ) * 2, 1000 ), 4 );
fIdx = 0;
ownerCounter = 1;
builders = { this, context.Inputs };
flatten( this, 0, context.Inputs );
flattened( fIdx + 1:end , : ) = [  ];


replaceSelect = ~cellfun( 'isempty', flattened( :, 2 ) );
[ tokens, starts, ends ] = regexp( flattened( replaceSelect, 3 ), this.REF_PATTERN,  ...
'tokens', 'start', 'end' );

buffer = cell( 1, size( flattened, 1 ) );
annotations = coderapp.internal.script.Annotation.empty(  );
symbols = struct(  );
offset = cumOffset;
tIdx = 0;
stack = [  ];
offsetStack = [  ];
owner = [  ];
pushOwner( 1 );


for i = 1:numel( buffer )
[ ownerId, raw, parentId ] = flattened{ i, [ 1, 3, 4 ] };
if stack( end  ) ~= ownerId
if parentId ~= stack( end  )
popOwner(  );
end 
pushOwner( ownerId );
end 
if replaceSelect( i )
tIdx = tIdx + 1;
if ~isempty( tokens{ tIdx } )
body = applyReferences( raw, tokens{ tIdx }, starts{ tIdx }, ends{ tIdx } );
else 
body = raw;
end 
elseif ~isempty( raw )
body = [ raw{ : } ];
else 
body = '';
end 
offset = offset + numel( body );
buffer{ i } = body;
end 

while ~isempty( stack )
popOwner(  );
end 
code = strjoin( buffer, '' );


function flatten( builder, parentId, inputs )
if isempty( builder.Contents )
return 
end 
ownerCounter = ownerCounter + 1;
id = ownerCounter;
inputs = applyInputs( builder, inputs );
builders( id, : ) = { builder, inputs };
for ii = 1:numel( builder.Contents )
next = builder.Contents{ ii };
if isempty( next )
continue 
end 
fIdx = fIdx + 1;
if isobject( next )
for jj = 1:numel( next )
flatten( next( jj ), id, inputs );
end 
else 
if ischar( next )
flag = true;
else 
flag = [  ];
end 
flattened( fIdx, : ) = { id, flag, next, parentId };
end 
end 
end 

function inputs = applyInputs( owner, inputs )

inputNames = fieldnames( owner.Inputs );
if ~isempty( inputNames )
unresolved = inputNames( ~isfield( inputs, inputNames ) );
for ii = 1:numel( unresolved )
if context.ExplicitInputs
error( 'Unresolved script input "%s"', unresolved{ ii } );
else 
inputs.( unresolved{ ii } ) = owner.Inputs.( unresolved{ ii } );
end 
end 
end 


transformables = fieldnames( owner.InputTransformers );
for ii = 1:numel( transformables )
transform = owner.InputTransformers.( transformables{ ii } );
output = char( transform( inputs ) );
inputs.( transformables{ ii } ) = output;
end 
end 

function pushOwner( id )
owner = builders{ id, 1 };
symbols = builders{ id, 2 };
stack( end  + 1 ) = id;
offsetStack( end  + 1 ) = offset;
end 

function processed = applyReferences( text, tokens, starts, ends )
segments = cell( 1, numel( tokens ) );
pos = 1;
for ii = 1:numel( tokens )
token = tokens{ ii }{ 1 };
if ~isfield( symbols, token )
error( 'Reference to undefined input "%s"', token );
end 
segments{ ii } = [ text( pos:starts( ii ) - 1 ), symbols.( token ) ];
pos = ends( ii ) + 1;
end 
processed = [ segments{ : }, text( pos:end  ) ];
end 

function popOwner(  )
if context.UseComments && ~isempty( owner.Comment )
comment = sprintf( '%% %s\n', owner.Comment );
else 
comment = '';
end 
if context.UseSections && ~isempty( owner.Title )
sectionHeader = sprintf( '%%%% %s\n', owner.Title );
sectionFooter = newline;
else 
sectionHeader = '';
sectionFooter = '';
end 
if ~isempty( comment ) || ~isempty( sectionHeader )
body = [ sectionHeader, comment, body, sectionFooter ];
end 

if ~isempty( owner.Annotations )
if context.AnnotateComments
annotStart = offsetStack( end  );
else 
annotStart = offsetStack( end  ) + numel( sectionHeader ) + numel( comment );
end 
annotEnd = offset - 1;
if ~context.ZeroBased
annotStart = annotStart + 1;
end 
newAnnots = repmat( coderapp.internal.script.Annotation, 1, numel( owner.Annotations ) );
for j = 1:numel( owner.Annotations )
rawAnnot = owner.Annotations( j );
newAnnots( j ).Tag = rawAnnot.tag;
newAnnots( j ).Metadata = rawAnnot.Metadata;
newAnnots( j ).Start = annotStart;
newAnnots( j ).End = annotEnd;
end 
annotations( end  + 1:end  + numel( newAnnots ) ) = newAnnots;
end 
stack( end  ) = [  ];
offsetStack( end  ) = [  ];
if ~isempty( stack )
[ owner, symbols ] = builders{ stack( end  ), : };
else 
owner = [  ];
symbols = struct(  );
end 
end 
end 
end 

properties ( Constant, Access = private )
REF_PATTERN = sprintf( '`([a-zA-Z][a-zA-Z0-9_]{0,%d}?)`', namelengthmax - 1 )
end 
end 


function [ code, annotations ] = alignAndFormat( code, annotations, zeroBased, format )
if isempty( code ) || isempty( strtrim( code ) )
return 
end 

mtPre = mtree( code, '-comments' );
if mtPre.count(  ) == 0 || strcmp( mtPre.root(  ).kind(  ), 'ERR' )
error( 'Invalid script contents: "%s"', code );
end 

preLefts = mtPre.lefttreepos(  );
preRights = mtPre.righttreepos(  );
alignment = zeros( numel( annotations ), 2 );
unadjust = double( zeroBased );
low = 1;

[ ~, order ] = sortrows( [ vertcat( annotations.Start ), vertcat( annotations.End ) ] );
annotations = annotations( order );


for i = 1:numel( annotations )
lIdx = find( preLefts( low:end  ) <= annotations( i ).Start + unadjust, 1, 'last' ) + low - 1;
rIdx = find( preRights( low:end  ) >= annotations( i ).End, 1, 'first' ) + low - 1;
annotations( i ).Start = preLefts( lIdx ) - unadjust;
annotations( i ).End = preRights( rIdx );
alignment( i, : ) = [ lIdx, rIdx ];
low = lIdx;
end 

if format
code = strtrim( mtPre.tree2str(  ) );
mtPost = mtree( code );
postLefts = mtPost.lefttreepos(  );
postRights = mtPost.righttreepos(  );


for i = 1:numel( annotations )
annotations( i ).Start = postLefts( alignment( i, 1 ) ) - unadjust;
annotations( i ).End = postRights( alignment( i, 2 ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNRCBSF.p.
% Please follow local copyright laws when handling this file.

