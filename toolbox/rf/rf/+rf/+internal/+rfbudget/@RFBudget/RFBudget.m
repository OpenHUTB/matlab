classdef RFBudget < handle




properties ( Dependent )
Elements
InputFrequency
AvailableInputPower
SignalBandwidth
Solver
WaitBar
Tones
Harmonics
AutoUpdate
end 

properties ( SetAccess = private )
OutputFrequency = [  ]
end 

properties ( Hidden )
TxRxIdx = 0
end 

properties ( Dependent )
OutputPower
TransducerGain
NF
IIP2
OIP2
IIP3
OIP3
SNR
end 

properties 
EIRP
Directivity
end 

properties ( SetAccess = private )
Friis = struct(  ...
'OutputPower', [  ],  ...
'TransducerGain', [  ],  ...
'NF', [  ],  ...
'IIP2', [  ],  ...
'OIP2', [  ],  ...
'IIP3', [  ],  ...
'OIP3', [  ],  ...
'SNR', [  ] )
HarmonicBalance = struct(  ...
'OutputPower', [  ],  ...
'TransducerGain', [  ],  ...
'NF', [  ],  ...
'IIP2', [  ],  ...
'OIP2', [  ],  ...
'IIP3', [  ],  ...
'OIP3', [  ],  ...
'SNR', [  ] )
end 

properties 
HarmonicOrder = [  ]
end 

properties ( Access = private )
PrivateElements = [  ]
PrivateInputFrequency = [  ]
PrivateAvailableInputPower = [  ]
PrivateSignalBandwidth = [  ]
PrivateSolver = 'Friis'
PrivateWaitBar = true
PrivateTones = [  ]
PrivateHarmonics = [  ]
PrivateAutoUpdate = false
end 

properties ( Dependent, Hidden )
Computable
end 

properties ( Access = { ?rf.internal.apps.budget.View } )
StageAvailableGain = [  ]
StageNF = [  ]
StageOIP3 = [  ]
end 

properties ( Hidden, SetAccess = private )
CascadeS = sparameters.empty
WaitBarHandle = [  ]
end 

properties ( Constant, Hidden )

kT = 290 * rf.physconst( 'Boltzmann' )
end 

properties ( Constant, Hidden )
Version = 2.0
end 

methods 
function obj = RFBudget( arg1, arg2, arg3, arg4, arg5, options )





R36
arg1( 1, : ) = [  ]
arg2( 1, : ) = [  ]
arg3( 1, : ) = [  ]
arg4( 1, : ) = [  ]
arg5( 1, : ) = true
options.Elements( 1, : )
options.InputFrequency( 1, : )
options.AvailableInputPower( 1, : )
options.SignalBandwidth( 1, : )
options.AutoUpdate( 1, 1 )logical
options.Solver( 1, 1 )string{ mustBeTextScalar } = 'Friis'
options.WaitBar( 1, 1 )logical = true
options.HarmonicOrder{ mustBeScalarOrEmpty,  ...
mustBeNumeric, mustBeInteger, mustBePositive } = [  ]
end 
narginchk( 0, 14 )


if ~isfield( options, 'Elements' )
options.Elements = arg1;
end 
if ~isfield( options, 'InputFrequency' )
options.InputFrequency = arg2;
end 
if ~isfield( options, 'AvailableInputPower' )
options.AvailableInputPower = arg3;
end 
if ~isfield( options, 'SignalBandwidth' )
options.SignalBandwidth = arg4;
end 
if ~isfield( options, 'AutoUpdate' )
options.AutoUpdate = arg5;
end 

if iscell( options.Elements )
options.Elements = obj.cell2chain( options.Elements );
elseif isa( options.Elements, 'circuit' )
options.Elements = getChain( options.Elements );
end 
obj.InputFrequency = options.InputFrequency;
obj.SignalBandwidth = options.SignalBandwidth;
obj.AvailableInputPower = options.AvailableInputPower;
obj.Solver = convertStringsToChars( options.Solver );
obj.HarmonicOrder = options.HarmonicOrder;
obj.WaitBar = options.WaitBar;
try 
obj.Elements = options.Elements;
catch err
for j = 1:length( obj.Elements )
obj.Elements( j ).Budget = [  ];
delete( obj.Elements( j ).Listener )
end 
rethrow( err )
end 

obj.AutoUpdate = options.AutoUpdate;
end 

function val = get.Computable( obj )
val =  ...
~isempty( obj.PrivateElements ) &&  ...
~isempty( obj.PrivateInputFrequency ) &&  ...
~isempty( obj.PrivateAvailableInputPower ) &&  ...
~isempty( obj.PrivateSignalBandwidth );
end 

function val = get.Elements( obj )
val = obj.PrivateElements;
end 

function set.Elements( obj, val )
index = arrayfun( @( x )isa( x, 'txlineMicrostrip' ), val );
if any( index )
index = arrayfun( @( x )~strcmp( x.Type, 'Standard' ), val( index ) );
if any( index )
error( message( 'rf:rfbudget:InvalidElement',  ...
[ val( index( 1 ) ).Type, ' microstrip transmission line' ],  ...
'nport' ) )
end 
end 

index = arrayfun( @( x )isa( x, 'txlineCPW' ), val );
if any( index )
index = arrayfun( @( x )x.ConductorBacked, val( index ) );
if any( index )
error( message( 'rf:rfbudget:InvalidElement',  ...
'Conductor-backed CPW transmission line', 'nport' ) )
end 
end 

index = arrayfun( @( x )isa( x, 'txlineElectricalLength' ), val );
if any( index )
error( message( 'rf:rfbudget:InvalidElement',  ...
'Electric-length-based transmission line',  ...
'txlineDelayLossless' ) )
end 

ant = arrayfun( @( x )isa( x, 'rfantenna' ), val );
num = 1:numel( ant );
idx = num( ant ~= 0 );
Rx = 0;%#ok<NASGU>
if ~isempty( idx )
if numel( idx ) > 1
error( message( 'rf:shared:MultipleAntennas' )' )
end 

Rx = strcmpi( val( idx ).Type, 'Receiver' );
TxRx = strcmpi( val( idx ).Type, 'TransmitReceive' );

if idx ~= 1 && Rx
error( message( 'rf:shared:RxAntennaPosition' ) )

elseif idx == 1 && Rx
warning( message( 'rf:shared:InputPower' ) )

elseif idx ~= length( val ) && ~TxRx
error( message( 'rf:shared:TxAntennaPosition' ) )
end 
end 

if ~isempty( val )
if isa( val, 'rf.internal.apps.budget.Element' )
newval = autoforward( val( 1 ) );
for i = 2:numel( val )
newval( i ) = autoforward( val( i ) );
end 
val = newval;
else 
validateattributes( val,  ...
{ 'amplifier', 'modulator', 'rfelement', 'nport',  ...
'rffilter', 'rf.internal.rfbudget.Element' },  ...
{ 'vector' }, '', 'Elements' )
checkChain( val )
end 
end 



if ~isempty( obj.PrivateElements )
for i = 1:numel( obj.PrivateElements )
if isvalid( obj.PrivateElements( i ) )
obj.PrivateElements( i ).Budget = [  ];
delete( obj.PrivateElements( i ).Listener )
end 
end 
end 



for i = 1:numel( val )
elem = val( i );
if isempty( elem.Budget ) || ~isvalid( elem.Budget )
elem.Budget = obj;
c = metaclass( elem );
p = c.PropertyList.findobj( 'SetObservable', true );
elem.Listener = addlistener( elem, p, 'PostSet',  ...
@( h, e )computeOrErase( obj ) );
else 


if i > 1
for j = 1:i - 1
val( j ).Budget = [  ];
delete( val( j ).Listener )
end 
end 
error( message( 'rf:rfbudget:InOtherBudget', i ) )
end 
end 
obj.PrivateElements = val( : )';
computeOrErase( obj )
end 

function val = get.InputFrequency( obj )
val = obj.PrivateInputFrequency;
end 

function set.InputFrequency( obj, val )
if isequal( val, obj.InputFrequency )
return 
end 
if ~isempty( val )
validateattributes( val, { 'numeric' },  ...
{ 'vector', 'finite', 'real' }, '',  ...
'InputFrequency' )
end 
obj.PrivateInputFrequency = val( : );
computeOrErase( obj )
end 

function val = get.AvailableInputPower( obj )
val = obj.PrivateAvailableInputPower;
end 

function set.AvailableInputPower( obj, val )
if isequal( val, obj.AvailableInputPower )
return 
end 
if ~isempty( val )
validateattributes( val, { 'numeric' },  ...
{ 'scalar', 'finite', 'real' }, '', 'AvailableInputPower' )
end 
obj.PrivateAvailableInputPower = val;
computeOrErase( obj )
end 

function val = get.SignalBandwidth( obj )
val = obj.PrivateSignalBandwidth;
end 

function set.SignalBandwidth( obj, val )
if isequal( val, obj.SignalBandwidth )
return 
end 
if ~isempty( val )
validateattributes( val, { 'numeric' },  ...
{ 'scalar', 'finite', 'real', 'positive' }, '',  ...
'SignalBandwidth' )
end 
obj.PrivateSignalBandwidth = val;
computeOrErase( obj )
end 

function val = get.AutoUpdate( obj )
val = obj.PrivateAutoUpdate;
end 

function set.AutoUpdate( obj, val )
if isequal( val, obj.AutoUpdate )
return 
end 
validateattributes( val, { 'logical', 'numeric' },  ...
{ 'nonempty', 'scalar' }, '', 'AutoUpdate' )
obj.PrivateAutoUpdate = logical( val );
if obj.AutoUpdate
computeBudget( obj )
end 



end 

function val = get.Solver( obj )
val = obj.PrivateSolver;
end 

function set.Solver( obj, val )
if strcmpi( val, obj.Solver )
return 
end 
validateattributes( val, { 'char', 'string' }, { 'nonempty', 'row' }, '', 'Solver' )
val = validatestring( val, { 'Friis', 'HarmonicBalance' } );
obj.PrivateSolver = val;


eraseResults( obj )
if obj.AutoUpdate
computeBudget( obj )
end 
end 

function set.HarmonicOrder( obj, val )
mustBeScalarOrEmpty( val )
mustBeNumeric( val )
if ~isempty( val )
mustBeInteger( val )
mustBePositive( val )
end 
obj.HarmonicOrder = val;
end 

function val = get.WaitBar( obj )
val = obj.PrivateWaitBar;
end 

function set.WaitBar( obj, val )
validateattributes( val, { 'logical', 'numeric' },  ...
{ 'nonempty', 'scalar' }, '', 'WaitBar' )
obj.PrivateWaitBar = val;
end 

function val = get.Tones( obj )
val = obj.PrivateTones;
end 

function val = get.Harmonics( obj )
val = obj.PrivateHarmonics;
end 

function val = get.NF( obj )
val = obj.( obj.Solver ).NF;
end 

function val = get.TransducerGain( obj )
val = obj.( obj.Solver ).TransducerGain;
end 

function val = get.IIP2( obj )
val = obj.( obj.Solver ).IIP2;
end 

function val = get.OIP2( obj )
val = obj.( obj.Solver ).OIP2;
end 

function val = get.IIP3( obj )
val = obj.( obj.Solver ).IIP3;
end 

function val = get.OIP3( obj )
val = obj.( obj.Solver ).OIP3;
end 

function val = get.SNR( obj )
val = obj.( obj.Solver ).SNR;
end 

function val = get.OutputPower( obj )
val = obj.( obj.Solver ).OutputPower;
end 
end 

methods ( Hidden )
function writeMissingNportFiles( obj )
for i = 1:length( obj.Elements )
elem = obj.Elements( i );
if isa( elem, 'nport' ) || isa( elem, 'amplifier' )
maybeWriteTouchstoneFile( elem, i )
end 
end 
end 
end 

methods 
function show( obj )
rfBudgetAnalyzer( obj )
end 

function delete( obj )


if ~isempty( obj.PrivateElements )
for i = 1:numel( obj.PrivateElements )
if isvalid( obj.PrivateElements( i ) )
obj.PrivateElements( i ).Budget = [  ];
delete( obj.PrivateElements( i ).Listener )
end 
end 
end 
end 
end 

methods 
hDoc = exportScript( obj )
out = exportRFBlockset( obj, sys, freqdelta )
out = exportTestbench( obj )
computeBudget( obj, varargin )
rfplot( obj, varargin )
s = smithplot( obj, m, n, varargin )
p = polar( obj, m, n, varargin )
end 

methods ( Hidden )
varargout = exportSimulink( obj, options )
rfs = exportRFSystem( obj )
out = oneToneAnalyses( obj )
out = twoToneAnalyses( obj )
end 

methods ( Access = private )
[ ckt, success ] = exportRFEngine( obj, varargin )
end 

methods ( Access = private )
function eraseFriis( obj )
obj.Friis.OutputPower = [  ];
obj.Friis.TransducerGain = [  ];
obj.Friis.NF = [  ];
obj.Friis.IIP2 = [  ];
obj.Friis.OIP2 = [  ];
obj.Friis.IIP3 = [  ];
obj.Friis.OIP3 = [  ];
obj.Friis.SNR = [  ];
end 

function eraseHarmonicBalance( obj )
obj.HarmonicBalance.OutputPower = [  ];
obj.HarmonicBalance.TransducerGain = [  ];
obj.HarmonicBalance.NF = [  ];
obj.HarmonicBalance.IIP2 = [  ];
obj.HarmonicBalance.OIP2 = [  ];
obj.HarmonicBalance.IIP3 = [  ];
obj.HarmonicBalance.OIP3 = [  ];
obj.HarmonicBalance.SNR = [  ];
end 

function eraseResults( obj )
obj.PrivateTones = [  ];
obj.PrivateHarmonics = [  ];
obj.StageAvailableGain = [  ];
obj.StageNF = [  ];
obj.StageOIP3 = [  ];
obj.OutputFrequency = [  ];
obj.EIRP = [  ];
eraseFriis( obj )
eraseHarmonicBalance( obj )
end 

function computeOrErase( obj )
if obj.AutoUpdate
computeBudget( obj )
else 
eraseResults( obj )
end 
end 
end 

methods 
function ckt = circuit( obj, varargin )
if isempty( obj.Elements )
ckt = circuit( varargin{ : } );
else 
ckt = circuit( obj.Elements, varargin{ : } );
end 
end 
end 

methods 
function disp( obj )
f = fields( obj );
if ~isscalar( obj )
[ M, N ] = size( obj );
if feature( 'hotlinks' )
fprintf( '  %dx%d <a href="matlab:helpPopup rfbudget">rfbudget</a> array with properties:\n\n',  ...
M, N );
else 
fprintf( '  %dx%d rfbudget array with properties:\n\n',  ...
M, N );
end 
cellfun( @( s )fprintf( '    %s\n', s ), f )
else 
if feature( 'hotlinks' )
fprintf( '  <a href="matlab:helpPopup rfbudget">rfbudget</a> with properties:\n\n' )
else 
fprintf( '  rfbudget with properties:\n\n' )
end 


if isempty( obj.Elements )
fprintf( '%23s: []\n', f{ 1 } );
else 
fprintf( '%23s: [1x%d %s]\n', f{ 1 },  ...
numel( obj.Elements ), class( obj.Elements ) )
end 


if isempty( obj.InputFrequency )
s{ 1, 1 } = sprintf( '%23s:      [] Hz', f{ 2 } );
else 
[ y, ~, u ] = engunits( obj.InputFrequency );
if isscalar( obj.InputFrequency )
s{ 1, 1 } = sprintf( '%23s: %7.4g %sHz', f{ 2 }, y, u );
else 
s = {  };
fprintf( '%23s: (Hz) [%dx1 double]\n', f{ 2 },  ...
numel( obj.InputFrequency ) );
end 
end 


if isempty( obj.AvailableInputPower )
s{ end  + 1, 1 } = sprintf( '%23s:      [] dBm', f{ 3 } );
else 
s{ end  + 1, 1 } = sprintf( '%23s: %7.4g dBm', f{ 3 },  ...
obj.AvailableInputPower );
end 


if isempty( obj.SignalBandwidth )
s{ end  + 1, 1 } = sprintf( '%23s:      [] Hz', f{ 4 } );
else 
[ y, ~, u ] = engunits( obj.SignalBandwidth );
s{ end  + 1, 1 } = sprintf( '%23s: %7.4g %sHz', f{ 4 }, y, u );
end 


s = char( s );
i = [ true( 1, 24 ), ( sum( s( :, 25:32 ) ~= ' ' ) > 0 ), true( 1, 4 ) ];
starts = find( diff( i ) ~= 0 );
i( starts( 1 ) + 1 ) = true;
disp( s( :, i ) )


if isempty( obj.Solver )
fprintf( '%23s:      []   \n', f{ 5 } );
else 
fprintf( '%23s: %-11s\n', f{ 5 }, obj.Solver );
if strcmp( obj.Solver, 'HarmonicBalance' )
if ~isempty( obj.HarmonicOrder )
fprintf( '%23s: %d\n', 'HarmonicOrder', obj.HarmonicOrder )
end 
if obj.WaitBar
fprintf( '%23s: true\n', f{ 6 } )
else 
fprintf( '%23s: false\n', f{ 6 } )
end 
end 
end 


if obj.AutoUpdate
fprintf( '%23s: true\n', f{ 9 } )
else 
fprintf( '%23s: false\n', f{ 9 } )
end 

if ~obj.Computable || isempty( obj.OutputFrequency )
return 
end 

fprintf( '\n   Analysis Results\n' )


[ y, ~, u ] = engunits( obj.OutputFrequency );
ant = zeros( 1, length( obj.Elements ) );
for i = 1:length( obj.Elements )
ant( i ) = isa( obj.Elements( i ), 'rfantenna' );
end 
index = find( ant == 1 );
Rx = 0;
if isprop( obj.Elements( index ), 'Type' )
if strcmpi( obj.Elements( index ).Type, 'Receiver' ) ||  ...
strcmpi( obj.Elements( index ).Type, 'TransmitReceive' )
Rx = 1;
end 
end 
if any( ant ) && ~Rx
units = { 
sprintf( '%sHz', u )
'dBm'
'dB'
'dB'
'dBm'
'dBm'
'dBm'
'dBm'
'dB'
'dBm';'dBi' };
else 
units = { 
sprintf( '%sHz', u )
'dBm'
'dB'
'dB'
'dBm'
'dBm'
'dBm'
'dBm'
'dB'
 };
end 
c = [ f( 10:10 + length( units ) - 1 ), units ];

units = cellfun( @( x )sprintf( '(%s)', x ), c( :, 2 ),  ...
'UniformOutput', false );
units = cellfun( @( x )sprintf( '%-5s', x ), units,  ...
'UniformOutput', false );

if ~obj.Computable
s = cellfun( @( x )sprintf( '%23s: []', x ), c( :, 1 ),  ...
'UniformOutput', false );
elseif ~isscalar( obj.InputFrequency )
r = sprintf( '[%dx%d double]',  ...
numel( obj.InputFrequency ), numel( obj.Elements ) );
s = [ sprintf( '%23s: (Hz)  %s', c{ 1, 1 }, r );
cellfun( @( x, y )sprintf( '%23s: %s %s', x, y, r ),  ...
c( 2:end , 1 ), units( 2:end  ), 'UniformOutput', false ) ];

for k = 2:length( s )
if isempty( obj.( c{ k, 1 } ) )
i = regexp( s{ k }, '[' );
n = length( s{ k }( i:end  ) );
e = ' ';
e = e( ones( 1, n ) );
e( 1:2 ) = '[]';
s{ k }( i:end  ) = e;
end 
end 
elseif isscalar( obj.Elements )

d = [ sprintf( '%11.4g', y );
cellfun( @( x )sprintf( '%11.4g', obj.( x ) ),  ...
c( 2:end , 1 ), 'UniformOutput', false ) ];

for k = 1:length( d )
if all( d{ k, : } == ' ' )
d{ k }( end  - 1:end  ) = '[]';
end 
end 
d = char( d );
i = ( sum( d ~= ' ' ) > 0 );
starts = find( diff( i ) ~= 0 );
i( starts( 1 ) + 1 ) = true;
d = cellstr( d( :, i ) );

s = cellfun( @( x, y, z )sprintf( '%23s: %s %s', x, y, z ),  ...
c( :, 1 ), d, units, 'UniformOutput', false );
else 

d = [ sprintf( '%11.4g', y );
cellfun( @( x )sprintf( '%11.4g', obj.( x ) ),  ...
c( 2:end , 1 ), 'UniformOutput', false ) ];
d = char( d );
i = ( sum( d ~= ' ' ) > 0 );
starts = find( diff( i ) == 1 );
idx = [ starts( 2:end  ) - 1;starts( 2:end  ) ];
i( idx( : ) ) = 1;
d = cellstr( d( :, i ) );

s = cellfun( @( x, y, z )sprintf( '%23s: %s [%s]', x, y, z ),  ...
c( :, 1 ), units, d, 'UniformOutput', false );
end 
disp( char( s ) )
end 
fprintf( '\n' )
end 

function out = clone( obj )
out = rfbudget;
out.AutoUpdate = false;
if ~isempty( obj.Elements )

warning( 'off', 'rf:shared:InputPower' )
out.Elements = clone( obj.Elements( 1 ) );
for i = 2:numel( obj.Elements )
out.Elements( i ) = clone( obj.Elements( i ) );
end 
warning( 'on', 'rf:shared:InputPower' )
end 
out.InputFrequency = obj.InputFrequency;
out.AvailableInputPower = obj.AvailableInputPower;
out.SignalBandwidth = obj.SignalBandwidth;


out.PrivateSolver = obj.Solver;
out.WaitBar = obj.WaitBar;
out.PrivateTones = obj.Tones;
out.PrivateHarmonics = obj.Harmonics;
out.PrivateAutoUpdate = obj.AutoUpdate;


out.StageAvailableGain = obj.StageAvailableGain;
out.StageNF = obj.StageNF;
out.StageOIP3 = obj.StageOIP3;
out.OutputFrequency = obj.OutputFrequency;
out.Friis = obj.Friis;
out.HarmonicBalance = obj.HarmonicBalance;
out.HarmonicOrder = obj.HarmonicOrder;
out.CascadeS = obj.CascadeS;
out.EIRP = obj.EIRP;
out.Directivity = obj.Directivity;
end 
end 

methods ( Static, Hidden )
function obj = loadobj( s )
if isstruct( s )
obj = rfbudget( 'AutoUpdate', false );
obj.PrivateElements = s.PrivateElements;
obj.PrivateInputFrequency = s.PrivateInputFrequency;
obj.PrivateAvailableInputPower = s.PrivateAvailableInputPower;
obj.PrivateSignalBandwidth = s.PrivateSignalBandwidth;
obj.PrivateAutoUpdate = s.PrivateAutoUpdate;
if isfield( s, 'PrivateSolver' )
obj.PrivateSolver = s.PrivateSolver;
solver = obj.Solver;
else 
solver = 'Friis';
end 
if isfield( s, 'PrivateWaitBar' )
obj.PrivateWaitBar = s.PrivateWaitBar;
end 
obj.StageNF = s.StageNF;
obj.StageOIP3 = s.StageOIP3;
obj.OutputFrequency = s.OutputFrequency;
p = { 'OutputPower', 'TransducerGain', 'NF', 'IIP2', 'OIP2', 'IIP3', 'OIP3', 'SNR' };
for k = 1:length( p )
if isfield( s, p{ k } ) && ~isempty( s.( p{ k } ) )
obj.( solver ).( p{ k } ) = s.( p{ k } );
end 
end 
else 
obj = s;
end 
end 
end 

methods ( Static, Hidden )
function elems = cell2chain( c )
for i = 1:numel( c )
validateattributes( c{ i },  ...
{ 'amplifier', 'modulator', 'rfelement', 'nport',  ...
'sparameters', 'yparameters', 'zparameters',  ...
'tparameters', 'abcdparameters',  ...
'hparameters', 'gparameters',  ...
'char' },  ...
{ 'nonempty', 'vector' }, '',  ...
sprintf( 'Element %d', i ) )
if isa( c{ i }, 'char' )
c{ i } = nport( c{ i } );
elseif isa( c{ i }, 'rf.internal.netparams.AllParameters' )
c{ i } = nport( c{ i } );
end 
end 
elems = [ c{ : } ];
end 


function pos = newPos( p, x, y )

ht = p( 4 ) - p( 2 );
wd = p( 3 ) - p( 1 );
pos = [ x, y - ht / 2, x + wd, y + ht / 2 ];
end 

function [ new_x, eng_exp, units_x ] = engunitsGLimited( x )
[ new_x, eng_exp, units_x ] = engunits( x );
if eng_exp < 1e-9
new_x = ( 1e-9 / eng_exp ) * new_x;
units_x = 'G';
elseif eng_exp > 1
new_x = ( 1 / eng_exp ) * new_x;
units_x = '';
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnXFJPG.p.
% Please follow local copyright laws when handling this file.

