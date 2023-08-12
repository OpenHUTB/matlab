function handlePropertyChange( ~, parameterSpace, changedProperty, ~ )




R36
~
parameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
changedProperty( 1, 1 )string
~
end 

switch changedProperty
case "SelectedForRun"
simulink.multisim.internal.updateDesignStudyNumSimulations( parameterSpace );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvkeNzm.p.
% Please follow local copyright laws when handling this file.

