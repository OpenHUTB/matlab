function [ location, locationIsValid, foundVarName ] = findVariable( mdl_name, textToParse, blockFullName )





location = '';
locationIsValid = false;
foundVarName = '';

varList = parseExpression( textToParse );

for varName = varList
varName = varName{ 1 };

searchLoc = 'startUnderMask';
[ tmp_location, tmp_locationIsValid ] = slprivate( 'getVariableLocation', mdl_name, varName, blockFullName, searchLoc );

if tmp_locationIsValid
if locationIsValid
location = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Multiple' );
locationIsValid = true;
foundVarName = '';
break ;
else 
location = tmp_location;
locationIsValid = tmp_locationIsValid;
foundVarName = varName;
end 
end 
end 
end 

function varList = parseExpression( textToParse )
tree = mtree( textToParse );
ids = tree.mtfind( 'Kind', 'ID' );
vars = strings( ids );
varList = unique( vars );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdvhRWw.p.
% Please follow local copyright laws when handling this file.

