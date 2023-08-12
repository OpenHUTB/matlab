classdef ( Sealed )Release




properties ( Constant, Hidden )
CURRENT = coderapp.internal.util.Release(  )
end 

properties 
Year( 1, 1 )uint32{ mustBeGreaterThan( Year, 0 ) } = year( now(  ) )
Cycle( 1, 1 )string{ mustBeMember( Cycle, [ "a", "b" ] ) } = "a"
end 

properties ( Dependent, SetAccess = immutable, Hidden )
IsPast
IsPresent
IsFuture

Value( 1, 1 )string

IsFirst( 1, 1 )logical

IsSecond( 1, 1 )logical
end 

properties ( Dependent, GetAccess = private, SetAccess = immutable )
Number( 1, 1 )double
end 

methods 

function obj = Release( mainArg, minorArg )
R36
mainArg = [  ]
minorArg = [  ]
end 

switch nargin
case 0
shortRelStr = char( version( '-release' ) );
obj.Year = str2double( shortRelStr( 1:end  - 1 ) );
obj.Cycle = shortRelStr( end  );
case 1
if isa( mainArg, 'coderapp.internal.util.Release' )
obj = mainArg;
elseif isnumeric( mainArg )

years = zeros( 1, numel( mainArg ) * 2 );
years( 1:2:end  ) = mainArg;
years( 2:2:end  ) = mainArg;
cycles = repmat( [ "a", "b" ], 1, numel( mainArg ) );
obj = coderapp.internal.util.Release( years, cycles );
if iscolumn( mainArg )
obj = obj';
end 
else 
mustBeText( mainArg );
obj = coderapp.internal.util.Release.parse( mainArg );
end 
case 2
mainArg = double( string( mainArg ) );
minorArg = lower( string( minorArg ) );
if isempty( mainArg ) || isempty( minorArg )
obj = coderapp.internal.util.Release.empty(  );
return 
end 
assert( isscalar( mainArg ) || isscalar( minorArg ) || numel( mainArg ) == numel( minorArg ),  ...
'Length of arguments must match or one must be scalar' );
if isscalar( mainArg )
mainArg = repmat( mainArg, size( minorArg ) );
end 
if isscalar( minorArg )
minorArg = repmat( minorArg, size( mainArg ) );
end 
obj = repmat( coderapp.internal.util.Release.CURRENT, size( mainArg ) );
for i = 1:numel( obj )
obj( i ).Year = mainArg( i );
obj( i ).Cycle = minorArg( i );
end 
end 
end 


function obj = next( obj )

for i = 1:numel( obj )
if ( obj( i ).IsFirst )
obj( i ).Cycle = "b";
else 
obj( i ).Year = obj( i ).Year + 1;
obj( i ).Cycle = "a";
end 
end 
end 


function obj = previous( obj )

for i = 1:numel( obj )
if ( obj( i ).IsSecond )
obj( i ).Cycle = "a";
else 
obj( i ).Year = obj( i ).Year - 1;
obj( i ).Cycle = "b";
end 
end 
end 


function [ sorted, order ] = sort( obj )
[ ~, order ] = sort( reshape( [ obj.Number ], size( obj ) ) );
sorted = obj( order );
end 


function equal = eq( a, b )
[ a, b ] = promote( a, b );
[ operatable, sz ] = coderapp.internal.util.binaryOperatorHelper( a, b,  ...
'coderapp.internal.util.Release', DebugName = 'EQ' );
if operatable
equal = reshape( [ a.Number ] == [ b.Number ], sz );
else 
equal = false( sz );
end 
end 


function result = ne( a, b )
result = ~eq( a, b );
end 


function result = gt( a, b )
[ a, b ] = promote( a, b );
[ operatable, sz ] = coderapp.internal.util.binaryOperatorHelper( a, b,  ...
'coderapp.internal.util.Release', DebugName = 'GT' );
if operatable
result = reshape( [ a.Number ] > [ b.Number ], sz );
else 
result = false( sz );
end 
end 


function result = lt( a, b )
[ a, b ] = promote( a, b );
[ operatable, sz ] = coderapp.internal.util.binaryOperatorHelper( a, b,  ...
'coderapp.internal.util.Release', DebugName = 'LT' );
if operatable
result = reshape( [ a.Number ] < [ b.Number ], sz );
else 
result = false( sz );
end 
end 


function result = ge( a, b )
[ a, b ] = promote( a, b );
[ operatable, sz ] = coderapp.internal.util.binaryOperatorHelper( a, b,  ...
'coderapp.internal.util.Release', DebugName = 'GE' );
if operatable
result = reshape( [ a.Number ] >= [ b.Number ], sz );
else 
result = false( sz );
end 
end 


function result = le( a, b )
[ a, b ] = promote( a, b );
[ operatable, sz ] = coderapp.internal.util.binaryOperatorHelper( a, b,  ...
'coderapp.internal.util.Release', DebugName = 'LE' );
if operatable
result = reshape( [ a.Number ] <= [ b.Number ], sz );
else 
result = false( sz );
end 
end 


function result = colon( first, aArg, bArg )
if nargin == 2
step = 1;
second = aArg;
else 
mustBeInteger( aArg );
step = aArg;
second = bArg;
end 

[ first, second ] = promote( first, second );
assert( isscalar( first ) && isscalar( second ),  ...
'Colong-indexing with Release objects only works with scalars' )
if step == 0 || ( step < 0 && second > first ) || ( step > 0 && first > second )
result = coderap.internal.util.Release.empty(  );
return 
end 

numbers = first.Number:( step / 2 ):second.Number;
result = numberToRelease( numbers );
end 


function result = plus( a, b )
[ a, b ] = numerify( a, b );
result = numberToRelease( a + b );
end 


function result = minus( a, b )
[ a, b ] = numerify( a, b );
result = numberToRelease( a - b );
end 


function result = isequal( a, b )
[ a, b ] = promote( a, b );
result = all( size( a ) == size( b ) ) && all( a == b );
end 


function result = isequaln( a, b )
result = isequal( a, b );
end 


function hash = keyHash( obj )
hash = keyHash( char( obj ) );
end 


function tf = keyMatch( a, b )
tf = strcmp( class( a ), class( b ) ) && a == b;
end 


function result = string( obj )
result = reshape( [ obj.Value ], size( obj ) );
end 


function result = cellstr( obj )
result = cellstr( string( obj ) );
end 


function result = char( this )
R36
this( 1, 1 )
end 
result = char( this.string(  ) );
end 


function past = get.IsPast( this )
past = this < this.CURRENT;
end 


function past = get.IsPresent( this )
past = this == this.CURRENT;
end 


function past = get.IsFuture( this )
past = this > this.CURRENT;
end 


function yes = get.IsFirst( this )
yes = this.Cycle == "a";
end 


function yes = get.IsSecond( this )
yes = ~this.IsFirst;
end 


function value = get.Value( this )
value = "R" + this.Year + this.Cycle;
end 


function number = get.Number( this )
number = double( this.Year );
if this.IsSecond
number = number + 0.5;
end 
end 
end 

methods ( Static )

function releases = parse( relStrs )
R36
relStrs string
end 

if isempty( relStrs )
releases = coderapp.internal.util.Release.empty(  );
return 
end 
tokens = regexp( cellstr( relStrs ), '^R?(\d{4})(a|b)$', 'tokens', 'once' );
isInvalid = cellfun( 'isempty', tokens );
if any( isInvalid )
error( 'Invalid release strings: %s', strjoin( relStrs( isInvalid ), ', ' ) );
end 
tokens = vertcat( tokens{ : } );
releases = coderapp.internal.util.Release( tokens( :, 1 ), tokens( :, 2 ) );
end 
end 

methods ( Static, Hidden )

function valid = isValidRelease( release )
R36
release{ mustBeText }
end 

valid = ~cellfun( 'isempty', regexp( cellstr( release ), '^R?(\d{4})(a|b)$', 'once' ) );
end 


function mustBeValidRelease( release )
R36
release{ mustBeText }
end 

assert( all( coderapp.internal.util.Release.isValidRelease( release ) ),  ...
'Must be valid MATLAB release specifiers' );
end 
end 
end 


function [ a, b ] = promote( a, b )
if ~isa( a, 'coderapp.internal.util.Release' )
a = coderapp.internal.util.Release.parse( a );
end 
if ~isa( b, 'coderapp.internal.util.Release' )
b = coderapp.internal.util.Release.parse( b );
end 
end 


function [ a, b ] = numerify( a, b )
if isa( a, 'coderapp.internal.util.Release' )
a = a.Number;
else 
a = double( floor( a ) ) / 2;
end 
if isa( b, 'coderapp.internal.util.Release' )
b = b.Number;
else 
b = double( floor( b ) ) / 2;
end 
end 


function releases = numberToRelease( nums )
nums = round( nums * 2 ) / 2;
years = floor( nums );
cycles = repmat( "a", size( nums ) );
cycles( years ~= nums ) = "b";
releases = coderapp.internal.util.Release( years, cycles );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpPdZ4sX.p.
% Please follow local copyright laws when handling this file.

