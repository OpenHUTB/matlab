function updateDesignStudyErrorText( designStudy )






R36
designStudy( 1, 1 )simulink.multisim.mm.design.DesignStudy
end 

designStudy.ErrorText = "";
updateDesignStudyErrorTextFromParameterTree( designStudy, designStudy.ParameterSpace );
end 

function updateDesignStudyErrorTextFromParameterTree( designStudy, parameterSpaces )
for parameterSpace = parameterSpaces
if ~isempty( parameterSpace.ErrorText )
designStudy.ErrorText = parameterSpace.ErrorText;
elseif isa( parameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
childParameterSpaces = parameterSpace.ParameterSpaces.toArray(  );
updateDesignStudyErrorTextFromParameterTree( designStudy, childParameterSpaces );
end 

if ~isempty( designStudy.ErrorText )
return ;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKXqAk6.p.
% Please follow local copyright laws when handling this file.

