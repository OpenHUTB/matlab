classdef ( Hidden, Sealed )FakeStruct










properties ( GetAccess = private, SetAccess = immutable )
Owner_ coderapp.internal.hw.FakeConfigSet
end 

properties ( GetAccess = { ?coderapp.internal.hw.FakeStruct, ?coderapp.internal.hw.FakeConfigSet }, SetAccess = private )
Data_ struct
end 

methods 
function this = FakeStruct( fakeConfigSet, data )
R36
fakeConfigSet coderapp.internal.hw.FakeConfigSet{ mustBeScalarOrEmpty( fakeConfigSet ) } = coderapp.internal.hw.FakeConfigSet.empty(  )
data struct{ mustBeScalarOrEmpty( data ) } = struct(  )
end 
this.Owner_ = fakeConfigSet;
this.Data_ = data;
end 

function value = subsref( this, subs )
value = this.Data_;
for i = 1:numel( subs )
sub = subs( i );
switch sub.type
case '.'
if i > 1 || isfield( value, sub.subs )
value = value.( sub.subs );
else 
value = builtin( 'subsref', this, subs( i:end  ) );
return 
end 
otherwise 
if ~isstruct( value )
value = builtin( 'subsref', this.wrapFieldValue( value ), subs( i:end  ) );
return 
end 
end 
end 
value = this.wrapFieldValue( value );
end 

function this = subsasgn( this, subs, value )
tokens = {  };
for i = 1:numel( subs )
sub = subs( i );
switch sub.type
case '.'
tokens{ end  + 1 } = sub.subs;%#ok<AGROW>
otherwise 
value = builtin( 'subsasgn', eval( [ 'this.Data_.', strjoin( tokens, '.' ) ] ), subs( i:end  ), value );%#ok<EVLDOT,NASGU>
break 
end 
end 
storage = strjoin( tokens, '.' );
eval( sprintf( 'this.Data_.%s = value;', storage ) );
if ~isempty( this.Owner_ )
this.Owner_.onStorageModified( storage );
end 
end 

function n = numel( ~, varargin )
n = 1;
end 

function yes = isscalar( ~ )
yes = true;
end 

function hasFields = isfield( this, fieldNames )
hasFields = isfield( this.Data_, fieldNames );
end 

function out = rmfield( this, fields )
out = this.wrapFieldValue( rmfield( this.Data_, fields ) );
end 

function out = setfield( this, field, value )
out = this.wrapFieldValue( setfield( this.Data_, field, value ) );
end 

function varargout = orderfields( this, arg )
[ result, perm ] = orderfields( this.Data_, arg );
varargout{ 1 } = this.wrapFieldValue( result );
if nargout > 1
varargout{ 2 } = perm;
end 
end 

function out = getfield( this, varargin )
out = this.wrapFieldValue( getfield( this.Data_, varargin{ : } ) );
end 

function names = fieldnames( this )
names = fieldnames( this.Data_ );
end 

function names = fields( this )
names = fields( this.Data_ );
end 

function disp( this )
disp( this.Data_ );
end 
end 

methods ( Access = private )
function out = wrapFieldValue( this, value )
if isstruct( value )
out = coderapp.internal.hw.FakeStruct( this.Owner_, value );
else 
out = value;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHLctOd.p.
% Please follow local copyright laws when handling this file.

