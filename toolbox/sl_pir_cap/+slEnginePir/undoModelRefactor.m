function undoModelRefactor( models, backupModelPrefix, m2m_dir )

arguments
    models
    backupModelPrefix
    m2m_dir = ''
end

for modelIndex = 1:length( models )
    modelName = models{ modelIndex };
    fullpath = which( modelName );
    [ ~, values ] = fileattrib( fullpath );
    if values.UserWrite == 0
        continue ;
    end
    C = textscan( modelName, '%s', 'Delimiter', '/' );
    modelName = C{ 1 }{ 1 };
    if ~bdIsLoaded( modelName )
        continue ;
    end
    backupModelName = slEnginePir.util.getBackupModelName( backupModelPrefix, modelName );
    if ~bdIsLoaded( backupModelName )
        if exist( [ m2m_dir, backupModelName, '.slx' ], 'file' ) == 0
            DAStudio.error( 'sl_pir_cpp:creator:BackupFileNotFound', backupModelName );
        end
        load_system( [ m2m_dir, backupModelName ] );
    end

    backupModelHandle = get_param( backupModelName, 'Handle' );
    modelHandle = get_param( modelName, 'Handle' );
    Simulink.BlockDiagram.deleteContents( modelName );

    Simulink.SLPIR.CloneDetection.copyContentFromBackupModel( backupModelHandle, modelHandle );

    replaceModelRefNames( modelName, backupModelPrefix );
    save_system( modelName );
end

end

function replaceModelRefNames( mdl, backmdlprefix )
mdlref_blks = find_system( mdl, 'MatchFilter', @Simulink.match.allVariants, 'LookUnderMasks', 'all',  ...
    'FindAll', 'on', 'IncludeCommented', 'on', 'BlockType', 'ModelReference' );
for ii = 1:length( mdlref_blks )
    t = get_param( mdlref_blks( ii ), 'ModelName' );
    if ~strcmp( t, '<Enter Model Name>' )
        set_param( mdlref_blks( ii ), 'ModelName', t( length( backmdlprefix ) + 1:end  ) );
    end
end
end

