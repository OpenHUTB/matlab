function varargout=fixProfileUse(mdlOrSlddName,varargin)


























    if nargin>2
        error('Expected 2 arguments')
    end

    switch nargin
    case 2
        action=varargin{1};
        verbose=false;

    case 3
        action=varargin{1};
        verbose=varargin{2};

    end


    if isempty(action)||~any(strcmp(action,{'fix','report'}))
        error('Invalid action argument. Use ''fix'' or ''report''.')
    end

    nameAndExt=strsplit(mdlOrSlddName,'.');
    if length(nameAndExt)>=2
        assert(strcmp(nameAndExt{2},'sldd'));
        ddObj=Simulink.data.dictionary.open(mdlOrSlddName);
        mf0mdl=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
        intrfCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0mdl);
        profNamespace=intrfCatalog.getProfileNamespaceFromContext;
    else

        mf0mdl=get_param(mdlOrSlddName,'SystemComposerMF0Model');
        zcMdl=get_param(mdlOrSlddName,'SystemComposerModel');
        zcMdlImpl=zcMdl.getImpl;
        profNamespace=zcMdlImpl.getProfileNamespace;
    end


    mdl=mf.zero.Model;
    pc=systemcomposer.internal.profile.ProfileUseChecker.analyze(mdl,profNamespace);

    if~pc.isProfileOutdated
        varargout{1}='Profile is not outdated. Exiting..';
        return;
    end

    assert(pc.isProfileOutdated);

    switch action
    case 'report'
        assert(pc.isProfileOutdated);
        pc.report;
    case 'fix'
        txn=mf0mdl.beginTransaction;
        profNamespace.synchronizePostLoad(pc);
        txn.commit;
        if~profNamespace.p_IsProfileOutdated
            varargout{1}='Success!';
        else
            varargout{1}='Failed!';
        end
    end

end