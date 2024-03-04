classdef ( Hidden = true )CallGraph

properties ( SetAccess = private, GetAccess = public )
CallGraphInfo
end 

methods 

function this = CallGraph( arg )
this.CallGraphInfo = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );

if nargin == 1

arg = convertStringsToChars( arg );
if iscellstr( arg )
validateattributes( arg, { 'cell' }, { 'nonempty', 'ndims', 2, 'ncols', 2 },  ...
'codeinstrum.internal.CallGraph', '', 1 );
this.populateCallGraph( arg );
else 
if ~isa( arg, 'containers.Map' )
validateattributes( arg, { 'codeinstrum.internal.CallGraph', 'codeinstrum.internal.TraceabilityData' },  ...
{ 'scalar' }, 'codeinstrum.internal.CallGraph', '', 1 );
end 

if isa( arg, 'codeinstrum.internal.CallGraph' )
arg = arg.CallGraphInfo;
end 

if isa( arg, 'containers.Map' )

keys = arg.keys(  );
for ii = 1:numel( keys )
this.CallGraphInfo( keys{ ii } ) = arg( keys{ ii } );
end 
else 

this.extractCallGraph( arg );
end 
end 
end 
end 



function calleeSigs = getCallees( this, callerSigs )
arguments
this( 1, 1 )
callerSigs string = ""
end 


if numel( callerSigs ) == 1 && callerSigs == ""
callerSigs = this.CallGraphInfo.keys(  );
end 
callerSigs = cellstr( convertStringsToChars( callerSigs ) );


calleeSet = containers.Map( 'KeyType', 'char', 'ValueType', 'logical' );
visitedCallerSet = containers.Map( 'KeyType', 'char', 'ValueType', 'logical' );


for ii = 1:numel( callerSigs )
callerSig = callerSigs{ ii };
getCalleesKernel( callerSig );
end 


calleeSigs = calleeSet.keys(  );
calleeSigs = calleeSigs( : );

function getCalleesKernel( callerSig )

visitedCallerSet( callerSig ) = true;


if ~this.CallGraphInfo.isKey( callerSig )
return 
end 


currCalleeSigs = this.CallGraphInfo( callerSig );
for jj = 1:numel( currCalleeSigs )

currCalleeSig = currCalleeSigs{ jj };
calleeSet( currCalleeSig ) = true;
if ~visitedCallerSet.isKey( currCalleeSig )

getCalleesKernel( currCalleeSig );
end 
end 
end 
end 



function callerSigs = getAllCallers( this )
callerSigs = this.CallGraphInfo.keys(  );
end 



function res = plus( lhs, rhs )
validateattributes( rhs, { 'codeinstrum.internal.CallGraph' }, { 'scalar' },  ...
'codeinstrum.internal.CallGraph.plus', '', 2 );

res = codeinstrum.internal.CallGraph( lhs );
rhsKeys = rhs.CallGraphInfo.keys(  );
for ii = 1:numel( rhsKeys )
key = rhsKeys{ ii };
val = rhs.CallGraphInfo( key );
if res.CallGraphInfo.isKey( key )
lhsVal = res.CallGraphInfo( key );
val = unique( [ lhsVal( : );val( : ) ] );
end 
res.CallGraphInfo( key ) = val( : );
end 
end 
end 


methods ( Access = protected )

function extractCallGraph( this, trDbObj )

callLst = trDbObj.getCalls(  );
for ii = 1:numel( callLst )
callerSig = callLst( ii ).callNode.function.signature;
calleeSig = { callLst( ii ).calleeSignature };
if this.CallGraphInfo.isKey( callerSig )
calleeSigs = [ this.CallGraphInfo( callerSig );calleeSig ];
else 
calleeSigs = calleeSig;
end 
this.CallGraphInfo( callerSig ) = calleeSigs;
end 
end 



function populateCallGraph( this, callGraphInfo )

for kk = 1:size( callGraphInfo, 1 )
callerSig = callGraphInfo{ kk, 1 };
calleeSig = callGraphInfo( kk, 2 );
if this.CallGraphInfo.isKey( callerSig )
calleeSigs = [ this.CallGraphInfo( callerSig );calleeSig ];
else 
calleeSigs = calleeSig;
end 
this.CallGraphInfo( callerSig ) = calleeSigs;
end 
end 
end 
end 


