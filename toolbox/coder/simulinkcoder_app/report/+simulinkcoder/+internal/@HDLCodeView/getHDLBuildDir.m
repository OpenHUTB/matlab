function dir = getHDLBuildDir( obj, modelName )

arguments
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



