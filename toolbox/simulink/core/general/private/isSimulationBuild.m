function isSimBuild = isSimulationBuild( mdl, modelReferenceTargetType )




switch modelReferenceTargetType
case 'SIM'
isSimBuild = true;
case 'RTW'
isSimBuild = false;
otherwise 
if bdIsLoaded( mdl )













isAccelBuild =  ...
isequal( get_param( mdl, 'SystemTargetFile' ), 'accel.tlc' );
isRAccelBuild =  ...
isequal( get_param( mdl, 'SystemTargetFile' ), 'raccel.tlc' );

isSimBuild = isAccelBuild || isRAccelBuild;
else 
isSimBuild = false;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpnQIk84.p.
% Please follow local copyright laws when handling this file.

