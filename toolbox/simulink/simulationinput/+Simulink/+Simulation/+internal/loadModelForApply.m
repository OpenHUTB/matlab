function loadModelForApply( modelName, forRevert )

arguments
    modelName( 1, 1 )string
    forRevert( 1, 1 )logical
end

if ~bdIsLoaded( modelName ) && ~forRevert
    load_system( modelName )
end
end
