

function RemoveProfileCB(archOrDD,profNames)



    prompt=message('SystemArchitecture:studio:ConfirmDeleteProfileModel',strjoin(profNames)).string;
    if ischar(archOrDD)

        prompt=message('SystemArchitecture:studio:ConfirmDeleteProfileDictionary',strjoin(profNames)).string;
        ddConn=Simulink.data.dictionary.open(archOrDD);
    end
    confirm=questdlg(...
    prompt,...
    message('SystemArchitecture:studio:ConfirmDeleteProfileTitle').string,...
    message('SystemArchitecture:studio:ConfirmDeleteProfile_Yes').string,...
    message('SystemArchitecture:studio:Cancel').string,...
    message('SystemArchitecture:studio:Help').string,...
    message('SystemArchitecture:studio:Cancel').string);

    if strcmp(confirm,message('SystemArchitecture:studio:ConfirmDeleteProfile_Yes').string)

        for idx=1:numel(profNames)
            try
                if isa(archOrDD,'systemcomposer.architecture.model.design.Architecture')

                    archOrDD.p_Model.removeProfile(profNames{idx});
                else

                    mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddConn.filepath());
                    zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
                    piCatalog=zcModel.getPortInterfaceCatalog;
                    piCatalog.removeProfile(profNames{idx});
                end
            catch ME
                diag=MSLException(get_param(archOrDD.getName,'handle'),ME.identifier,ME.message);
                sldiagviewer.reportError(diag);
            end
        end
    elseif strcmp(confirm,message('SystemArchitecture:studio:Help').string)

        helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'define_profiles');
    end
end
