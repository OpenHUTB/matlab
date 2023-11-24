function ImportProfileCB(data,varargin)

    [file,path]=uigetfile('*.xml');
    if file==0
        return
    end
    filePath=fullfile(path,file);
    pfl=systemcomposer.internal.profile.Profile.loadFromFile(filePath);
    profile=systemcomposer.internal.profile.Profile.getProfile(pfl);

    if isa(data,'SLM3I.CallbackInfo')
        topArchMdl=ZCStudio.getArchitectureFromCurrentContext(data);
        editor=data.studio.App.getActiveEditor();
    elseif nargin==2
        topArchMdl=data;
        studio=varargin{1};
        editor=studio.App.getActiveEditor();
    else
        assert(false,'Invalid arguments');
    end

    dict=get_param(topArchMdl.getName,'DataDictionary');
    if~isempty(dict)




        ddConn=Simulink.data.dictionary.open(dict);
        mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddConn.filepath());
        zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
        piCatalog=zcModel.getPortInterfaceCatalog;
        if isempty(piCatalog.getProfile(profile.getName()))



            response=questdlg(...
            message('SystemArchitecture:studio:ConfirmImportToModelAndDictionary',dict,profile.getName()).string,...
            message('SystemArchitecture:studio:ConfirmImportToModelAndDictionaryTitle').string,...
            message('SystemArchitecture:studio:ConfirmImportToModelAndDictionaryOpt').string,...
            message('SystemArchitecture:studio:ConfirmImportToModelOpt').string,...
            message('SystemArchitecture:studio:Cancel').string,...
            message('SystemArchitecture:studio:ConfirmImportToModelAndDictionaryOpt').string);
            if strcmp(response,message('SystemArchitecture:studio:ConfirmImportToModelAndDictionaryOpt').string)


                piCatalog.addProfile(filePath);
            elseif strcmp(response,message('SystemArchitecture:studio:ConfirmImportToModelOpt').string)

            elseif isempty(response)||strcmp(response,message('SystemArchitecture:studio:Cancel').string)


                return;
            end
        end
    end


    if isempty(findobj(topArchMdl.p_Model.getProfiles,'p_Name',profile.getName()))

        topArchMdl.p_Model.addProfile(profile.getName);
        editor.deliverInfoNotification('SystemArchitecture:Profile:SuccessfulImport',...
        DAStudio.message('SystemArchitecture:Profile:SuccessfulImport',profile.getName()));
    else

        editor.deliverInfoNotification('SystemArchitecture:Profile:ProfileAlreadyImported',...
        DAStudio.message('SystemArchitecture:Profile:ProfileAlreadyImported',profile.getName()));
    end
end
