function dir = getHDLBuildDir( obj, modelName )








R36
obj
modelName char = ''
end 


targetDir = hdlget_param( modelName, 'TargetDirectory' );




hasFileSep = contains( targetDir, filesep );
if ~hasFileSep
cgDir = fullfile( pwd, targetDir, modelName );
else 
cgDir = fullfile( targetDir, modelName );
end 



dir = [ cgDir, filesep ];



if ~isfile( [ dir, 'hcv' ] )
dir = [  ];
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp2S_rHK.p.
% Please follow local copyright laws when handling this file.

