classdef SumConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
Inputs
Accum
Out
Supported
end 

methods 
function obj = SumConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
blkObj = varargin{ 1 };
obj.Supported = false;
inputSpec = blkObj.Inputs;
if inputSpec == "2"
obj.Supported = true;
end 
pluses = strfind( inputSpec, '+' );
if ~contains( inputSpec, '-' ) && length( pluses ) == 2
obj.Supported = true;
end 

obj.Inputs = inputGroupInfos;
obj.Accum = pathItemGroupInfos( 'Accumulator' );
obj.Out = pathItemGroupInfos( 'Output' );
end 

function apply( obj, cpModel )
if obj.Supported
cpModel.addConstraint( cpopt.internal.ConstraintType.Sum, { obj.Inputs{ 1 }.ID, obj.Inputs{ 2 }.ID }, { obj.Accum.ID } );
cpModel.addConstraint( cpopt.internal.ConstraintType.Same, { obj.Accum.ID }, { obj.Out.ID } );
else 
if obj.Accum.isProposable(  )
cpModel.setVariable( obj.Accum.ID, 1, 0 );
end 
if obj.Out.isProposable(  )
cpModel.setVariable( obj.Out.ID, 1, 0 );
end 
for i = 1:length( obj.Inputs )
in = obj.Inputs{ i };
if in.isProposable(  )
cpModel.setVariable( in.ID, 1, 0 );
end 
end 
end 
end 

function redundant = isRedundant( obj )
redundant = obj.Accum.isKnown(  ) && obj.Out.isKnown(  );
for i = 1:length( obj.Inputs )
redundant = redundant && obj.Inputs{ i }.isKnown(  );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpShWkV3.p.
% Please follow local copyright laws when handling this file.

