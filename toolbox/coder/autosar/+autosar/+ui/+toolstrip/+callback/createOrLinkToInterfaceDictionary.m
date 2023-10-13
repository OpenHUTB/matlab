function createOrLinkToInterfaceDictionary( actionName, cbinfo, namedargs )




arguments
    actionName
    cbinfo
    namedargs.OpenInterfaceDictUI = true;
end

modelName = SLStudio.Utils.getModelName( cbinfo );


isCreatingNewInterfaceDict = strcmp( actionName, 'autosarCreateInterfaceDictionaryAction' );
if isCreatingNewInterfaceDict


    isLinked = autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary( modelName );
    assert( ~isLinked, 'model %s is already linked to an interface dictionary', modelName );


    [ ddFile, ddFilePath ] = uiputfile(  ...
        { '*.sldd', 'Interface Dictionary files (*.sldd)'; ...
        '*.*', 'All Files (*.*)' },  ...
        DAStudio.message( 'autosarstandard:dictionary:CreateNewInterfaceDict' ) );
else

    [ ddFile, ddFilePath ] = uigetfile( { '*.sldd', 'Interface Dictionary files (*.sldd)'; ...
        '*.*', 'All Files (*.*)' },  ...
        DAStudio.message( 'autosarstandard:dictionary:LinkToInterfaceDict' ) );
end

userPressedCancel = isequal( ddFile, 0 );
if userPressedCancel
    return ;
end

if isCreatingNewInterfaceDict

    ddFilePath = ddFilePath( 1:end  - 1 );
    pathCell = regexp( path, pathsep, 'split' );
    dictOnPath = any( strcmpi( ddFilePath, pathCell ) );
    if ( ~dictOnPath && ~strcmpi( ddFilePath, pwd ) )
        DAStudio.error( 'autosarstandard:dictionary:InterfaceDictNotOnPath', ddFile );
    end


    ddFullFilePath = fullfile( ddFilePath, ddFile );
    if exist( ddFullFilePath, 'file' )
        try
            Simulink.dd.delete( ddFullFilePath );
        catch
            DAStudio.error( 'SLDD:sldd:DeleteOpenDictionaryError' );
        end
    end
end


pb = Simulink.internal.ScopedProgressBar(  ...
    DAStudio.message( 'autosarstandard:editor:ConfigInterfaceDictProgressUI' ) );%#ok<NASGU>

if isCreatingNewInterfaceDict

    dictAPI = Simulink.interface.dictionary.create( ddFile );
else



    dd = Simulink.dd.open( ddFile );%#ok<NASGU>
    assert( sl.interface.dict.api.isInterfaceDictionary( ddFile ),  ...
        '%s is not an interface dictionary.', ddFile );
    dictAPI = Simulink.interface.dictionary.open( ddFile );
end

interfaceDictFileName = dictAPI.DictionaryFileName;



deliverPlatformNotification = ~dictAPI.hasPlatformMapping( 'AUTOSARClassic' );
set_param( modelName, 'DataDictionary', interfaceDictFileName );
if ~isCreatingNewInterfaceDict && deliverPlatformNotification
    autosar.ui.toolstrip.callback.deliverPlatformMappingNotification(  ...
        modelName, dictAPI.DictionaryFileName );
end


sharedM3IModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictAPI.filepath(  ) );
assert( sharedM3IModel.isvalid(  ), 'dictionary %s does not have m3iModel', interfaceDictFileName );

m3iModelComposition = autosar.api.Utils.m3iModel( modelName );
m3iModelDict = autosar.dictionary.Utils.getM3IModelForDictionaryFile( interfaceDictFileName );
autosar.dictionary.Utils.updateModelMappingWithDictionary( modelName, interfaceDictFileName );
Simulink.AutosarDictionary.ModelRegistry.addReferencedModel( m3iModelComposition, m3iModelDict );


if isCreatingNewInterfaceDict
    tran = M3I.Transaction( m3iModelDict );
    autosar.dictionary.internal.migrateXmlOptions( m3iModelComposition, m3iModelDict, false );
    tran.commit(  );



    arProps = autosar.api.getAUTOSARProperties( interfaceDictFileName );
    arProps.set( 'XmlOptions', 'XmlOptionsSource', 'Inherit' );


    dictAPI.save(  );
end


if namedargs.OpenInterfaceDictUI
    systemcomposer.createInterfaceEditorComponent( cbinfo.studio, true, true );
end




