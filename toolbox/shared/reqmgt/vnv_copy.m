function vnv_copy(method,obj,varargin)




    if islogical(method)

        duplicationEnabled(method);
        return;
    end


    if strcmp(get_param(0,'CopyBlkRequirement'),'off')
        return;
    end

    [modelH,objH,isSf]=rmisl.resolveObj(obj);


    if rmisl.isComponentHarness(modelH)||Simulink.harness.internal.isInAtomicAction()
        return;
    end


    artifactPath=get_param(modelH,'FileName');
    slreq.data.DataModelObj.checkLicense(['allow ',artifactPath]);
    cll=onCleanup(@()slreq.data.DataModelObj.checkLicense('clear'));

    if isempty(varargin)
        action='copy';
    else
        action=varargin{1};
    end

    switch lower(action)
    case 'disablelink'

        w=slreq.internal.TempFlags.changeFlag('IsRedirectingLibObj',false);%#ok<NASGU>
        rmidata.duplicateDisabled(objH);
        return;
    case 'restorelink'








        try
            if bdIsLibrary(bdroot(objH))
                libRoot=bdroot(objH);
                if slreq.utils.isInPerspective(libRoot)
                    mgr=slreq.app.MainManager.getInstance;
                    mmgr=mgr.markupManager;



                    mmgr.hideMarkupsAndConnectorsForModel(libRoot);
                end

                ownerBlk=get_param(objH,'BlockCopiedFrom');
                ownerHandle=Simulink.ID.getHandle(ownerBlk);
                ownerRoot=bdroot(ownerHandle);

                if slreq.utils.isInPerspective(ownerRoot,true)
                    mgr=slreq.app.MainManager.getInstance;
                    mmgr=mgr.markupManager;



                    mmgr.hideMarkupsAndConnectorsForModel(ownerRoot);
                end

            end
        catch ex %#ok<NASGU>


        end

        rmidata.restoreDisabled(objH);
        return;
    case 'postrestorelink'
        try
            modelRoot=bdroot(objH);
            if bdIsLibrary(modelRoot)

                if slreq.utils.isInPerspective(modelRoot)
                    mgr=slreq.app.MainManager.getInstance;
                    bmgr=mgr.badgeManager;
                    mmgr=mgr.markupManager;
                    bmgr.enableBadges(modelRoot);
                    mmgr.showMarkupsAndConnectorsForModel(modelRoot);
                end

                ownerBlk=get_param(objH,'BlockCopiedFrom');
                if isempty(ownerBlk)


                    allModels={};
                else

                    ownerHandle=Simulink.ID.getHandle(ownerBlk);
                    ownerRoot=bdroot(ownerHandle);
                    allModels={ownerRoot};
                end

                for index=1:length(allModels)
                    cModel=get_param(allModels{index},'Handle');
                    if slreq.utils.isInPerspective(cModel)
                        mgr=slreq.app.MainManager.getInstance;
                        bmgr=mgr.badgeManager;
                        mmgr=mgr.markupManager;
                        bmgr.enableBadges(cModel);
                        mmgr.showMarkupsAndConnectorsForModel(cModel);
                    end

                end


            end
        catch ex %#ok<NASGU>


        end

        return;
    case 'removelink'

        rmidata.breakDisabled(objH);
        return;
    otherwise

        if isempty(objH)
            return;
        end

        if~isSf&&...
            ~strcmp(get_param(objH,'BlockType'),'SubSystem')&&...
            isChildOfSfBlock(objH)
            return;
        end
    end















    switch lower(method)
    case 'objcopy'





        srcSid=get_param(objH,'BlockCopiedFrom');
        newSid=Simulink.ID.getSID(objH);
        if strcmp(srcSid,newSid)
            ownerRoot=bdroot(objH);
            if slreq.utils.isInPerspective(ownerRoot)
                mgr=slreq.app.MainManager.getInstance;
                bmgr=mgr.badgeManager;
                mmgr=mgr.markupManager;
                bmgr.enableBadges(ownerRoot);
                mmgr.showMarkupsAndConnectorsForModel(ownerRoot);
            end
            return;
        end

        if duplicationEnabled()
            rmidata.duplicate(objH,modelH);
        else
            srcSid=get_param(objH,'BlockCopiedFrom');
            if shouldDuplicateOnCopy(srcSid)
                rmidata.duplicate(objH,modelH,srcSid);
            end
        end
    case 'chartcopy'
        if duplicationEnabled()
            rmidata.duplicateChart(objH,modelH,varargin{1});
        else
            slH=varargin{1};
            srcSid=get_param(slH,'BlockCopiedFrom');
            if shouldDuplicateOnCopy(srcSid)
                rmidata.duplicateChart(objH,modelH,slH,srcSid);
            end
        end
    case 'mdlref'

        rmisl.mdlRefSyncReqs(varargin{2},objH)
    otherwise
        warning(message('Slvnv:vnv_copy:unsupportedMethod',method));
    end

end

function yesno=duplicationEnabled(value)
    persistent rmiFeatureState
    if nargin>0
        rmiFeatureState=value;
    elseif isempty(rmiFeatureState)
        rmiFeatureState=rmipref('DuplicateOnCopy');













    end
    yesno=rmiFeatureState;
end

function yesno=shouldDuplicateOnCopy(srcSid)
    if isempty(srcSid)
        yesno=false;
        return;
    end
    srcMdlName=strtok(srcSid,':');
    yesno=strcmp(get_param(srcMdlName,'ReqHilite'),'on');
end

function result=isChildOfSfBlock(blockH)
    parentBlock=get_param(blockH,'Parent');
    if isempty(parentBlock)
        result=false;
    else
        paretnH=get_param(parentBlock,'Handle');
        result=~isempty(paretnH)&&...
        strcmpi(get_param(paretnH,'Type'),'Block')&&...
        slprivate('is_stateflow_based_block',paretnH);
    end
end


