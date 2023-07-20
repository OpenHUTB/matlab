function[sourceName,isModelContext,varargout]=getDictionaryInfo(bdOrDDName,context)





    if isnumeric(bdOrDDName)
        sourceName=get_param(bdOrDDName,'Name');
        isModelContext=true;
    else
        [~,sourceName,ext]=fileparts(bdOrDDName);
        isModelContext=false;
        if nargin>1
            isModelContext=strcmpi(context,'Model');
        elseif isempty(ext)||~strcmpi(ext,'.sldd')
            isModelContext=true;
        end
    end

    if nargout>2
        dd=[];
        dictionaryReopened=false;
        if(isModelContext)
            bdH=get_param(bdOrDDName,'handle');
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            mf0Model=app.getCompositionArchitectureModel;
        else
            if isempty(Simulink.data.dictionary.getOpenDictionaryPaths([bdOrDDName,'.sldd']))

                dictionaryReopened=true;
            end
            dd=Simulink.data.dictionary.open(systemcomposer.InterfaceEditor.getFullDDName(bdOrDDName));
            mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(dd.filepath());
        end
        zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
        piCatalog=zcModel.getPortInterfaceCatalog();
        varargout{1}=piCatalog;
        varargout{2}=dd;
        varargout{3}=dictionaryReopened;
    end

end

