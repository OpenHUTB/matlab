function bdHandle=getBDRoot(iZCIdentifier)

    bdHandle=[];
    if~isempty(bdroot)&&systemcomposer.internal.isSystemComposerModel(bdroot)
        bdHandle=get_param(bdroot,'handle');
    end

    if nargin>0
        bdHandle=[];
        listOfSystem=find_system('SearchDepth',0);
        for itr=1:numel(listOfSystem)
            if(systemcomposer.internal.isSystemComposerModel(listOfSystem{itr}))
                bdHandle=get_param(listOfSystem{itr},'Handle');
                if~isempty(iZCIdentifier)&&~isempty(bdHandle)
                    sysArchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdHandle);
                    model=sysArchApp.getArchViewsAppMgr.getModel;
                    parts=strsplit(iZCIdentifier,':');
                    mfUUID=parts{2};
                    if~isempty(model.findElement(mfUUID))
                        return;
                    else
                        bdHandle=[];
                    end
                else
                    return;
                end
            end
        end
    end
end

