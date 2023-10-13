function interfaceEditorCB( cbinfo, namedArgs )





arguments
    cbinfo( 1, 1 );
    namedArgs.InitFromModelStudio = false;
    namedArgs.LinkExistingDict = false;
end

import Simulink.interface.dictionary.internal.DictionaryClosureUtils

modelName = SLStudio.Utils.getModelName( cbinfo );
mainDD = get_param( modelName, 'DataDictionary' );

if namedArgs.InitFromModelStudio


    isToolstripButtonTurnedOn = true;
else
    isToolstripButtonTurnedOn = cbinfo.EventData;
end

if isToolstripButtonTurnedOn
    if isempty( mainDD )
        if namedArgs.InitFromModelStudio

            if namedArgs.LinkExistingDict
                createOrLinkActionId = 'autosarLinkInterfaceDictionaryAction';
            else
                createOrLinkActionId = 'autosarCreateInterfaceDictionaryAction';
            end
            autosar.ui.toolstrip.callback.createOrLinkToInterfaceDictionary( createOrLinkActionId, cbinfo, OpenInterfaceDictUI = false );
            ddFile = get_param( modelName, 'DataDictionary' );
            if isempty( ddFile )

                return ;
            end
        end
    end
else

    toggleInterfaceEditorVisibility( modelName );
    return
end



interfaceDictFiles = DictionaryClosureUtils.getLinkedInterfaceDicts( modelName );
for dictIdx = 1:length( interfaceDictFiles )
    interfaceDictFile = interfaceDictFiles{ dictIdx };
    interfaceDictAPI = Simulink.interface.dictionary.open( interfaceDictFile );
    if ~interfaceDictAPI.hasPlatformMapping( 'AUTOSARClassic' )
        autoSaveDict = ~interfaceDictAPI.isDirty(  );
        interfaceDictAPI.addPlatformMapping( 'AUTOSARClassic' );
        if autoSaveDict
            try
                interfaceDictAPI.save(  );
            catch


                autosar.ui.toolstrip.callback.deliverPlatformMappingNotification(  ...
                    modelName, interfaceDictAPI.DictionaryFileName );
            end
        end
    end
end


if ~namedArgs.InitFromModelStudio
    systemcomposer.createInterfaceEditorComponent( cbinfo.studio, true, true );
end

end

function toggleInterfaceEditorVisibility( modelName )

allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
studio = allStudios( 1 );
if strcmp( get_param( studio.App.blockDiagramHandle, 'Name' ), modelName )
    comp = studio.getComponent( 'GLUE2:DDG Component', 'InterfaceEditor' );
    if ~isempty( comp )

        if ~comp.isVisible
            studio.showComponent( comp );
            studio.focusComponent( comp );
        else
            studio.hideComponent( comp );
        end
    end
end
end


