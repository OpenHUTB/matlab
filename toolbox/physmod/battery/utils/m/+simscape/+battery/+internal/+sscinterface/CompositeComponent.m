classdef ( Sealed, Hidden )CompositeComponent < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "CompositeComponent";
end 

properties ( Access = private )
MemberComponent
ComponentFile
Parameters
InitialTargets
VariablePriority
end 

methods 
function obj = CompositeComponent( memberComponent, componentFile, componentArguments )


R36
memberComponent string{ mustBeTextScalar, mustBeNonzeroLengthText }
componentFile string{ mustBeTextScalar, mustBeNonzeroLengthText }
componentArguments.Parameters( :, 2 )string{ mustBeNonzeroLengthText } = string.empty( 0, 2 );
componentArguments.InitialTargets( :, 2 )string{ mustBeNonzeroLengthText } = string.empty( 0, 2 );
componentArguments.VariablePriority( :, 2 )string{ mustBeNonzeroLengthText } = string.empty( 0, 2 );
end 


variablePriority = lower( componentArguments.VariablePriority( :, 2 ) );
prioriesUsingEnum = contains( variablePriority, "priority." );
variablePriority( ~prioriesUsingEnum ) = "priority." + variablePriority( ~prioriesUsingEnum );

obj.MemberComponent = memberComponent;
obj.ComponentFile = componentFile;
obj.Parameters = componentArguments.Parameters;
obj.InitialTargets = componentArguments.InitialTargets;
obj.VariablePriority = [ componentArguments.VariablePriority, variablePriority ];
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )


parameterDefinitions = obj.Parameters( :, 1 ).append( " = ", obj.Parameters( :, 2 ) );
initialTargetDefinitions = obj.InitialTargets( :, 1 ).append( ".value = ", obj.InitialTargets( :, 2 ) );
variablePriorityDefinitions = obj.VariablePriority( :, 1 ).append( ".priority = ", obj.VariablePriority( :, 2 ) );
componentArguments = [ parameterDefinitions;initialTargetDefinitions;variablePriorityDefinitions ];

componentDefinition = obj.MemberComponent.append( " = ", obj.ComponentFile );
if height( componentArguments ) > 0

definitionParts = [ componentDefinition;componentArguments ];
definitionPartsLength = definitionParts.strlength;
cumPartLength = cumsum( definitionPartsLength );
assignmentLines = floor( cumPartLength / obj.IdealCharsPerLine );
newlineExpected = diff( assignmentLines ) ~= 0;
newlineExpected( 1 ) = cumPartLength( 1 ) > obj.IdealCharsPerLine;

delimiter = [ "(";repmat( ",", height( newlineExpected ) - 1, 1 ) ];
delimiter( newlineExpected ) = delimiter( newlineExpected ) + "..." + newline;
componentDefinition = join( definitionParts, delimiter ) + ")";
else 

end 
str = componentDefinition;
end 

function str = getTerminalString( ~ )

str = ";" + newline;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpBWT19F.p.
% Please follow local copyright laws when handling this file.

