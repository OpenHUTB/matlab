function loadModelForApply( modelName, forRevert )






R36
modelName( 1, 1 )string
forRevert( 1, 1 )logical
end 

if ~bdIsLoaded( modelName ) && ~forRevert
load_system( modelName )
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYdAggb.p.
% Please follow local copyright laws when handling this file.

