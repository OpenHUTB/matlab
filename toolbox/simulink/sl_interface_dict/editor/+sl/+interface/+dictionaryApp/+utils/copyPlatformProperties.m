function copyPlatformProperties( dictObj, sourceDictEntry, destinationDictEntry )

arguments
    dictObj Simulink.interface.Dictionary;
    sourceDictEntry Simulink.interface.dictionary.NamedElement;
    destinationDictEntry Simulink.interface.dictionary.NamedElement;
end

if ~dictObj.hasPlatformMapping( 'AUTOSARClassic' )

    return ;
end

platformMapping = dictObj.getPlatformMapping( "AUTOSARClassic" );

[ propNames, propValues ] = platformMapping.getPlatformProperties( sourceDictEntry );

nameValueVec = cell( 1, 2 * length( propNames ) );
nameValueVec( 1:2:2 * length( propNames ) ) = propNames;
nameValueVec( 2:2:2 * length( propNames ) ) = propValues;

platformMapping.setPlatformProperty( destinationDictEntry, nameValueVec{ : } );

if isprop( sourceDictEntry, 'Elements' )

    assert(  ...
        numel( sourceDictEntry.Elements ) == numel( destinationDictEntry.Elements ),  ...
        'Expected same hierarchy in source and destination' );
    for childIdx = 1:length( sourceDictEntry.Elements )
        sourceElem = sourceDictEntry.Elements( childIdx );
        destElem = destinationDictEntry.Elements( childIdx );
        sl.interface.dictionaryApp.utils.copyPlatformProperties( dictObj,  ...
            sourceElem, destElem );
    end
end
