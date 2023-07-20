function rmi_sl_callback(method,modelH)




    persistent rmiInstalledAndLicensed deferredNotifications lastAutocreated

    if isempty(rmiInstalledAndLicensed)||strcmp(method,'reset')
        [rmiInstalled,rmiLicensed]=rmi.isInstalled();
        rmiInstalledAndLicensed=(rmiInstalled&&rmiLicensed);
        deferredNotifications=containers.Map('KeyType','double','ValueType','any');

        if strcmp(method,'reset')
            return;
        end
    end



    deferPostloadDataName="ReqDeferPostLoadActions";


    if rmiut.isBuiltinNoRmi(modelH)
        return;
    end

    switch(method)

    case 'postLoad'



        tf=slreq.internal.TempFlags.getInstance();
        if~tf.get('DeferModelPostLoadActions')

            nn=preLoadCallback(modelH);
            if~isempty(nn)
                deferredNotifications(modelH)=nn;
            end

        else

            if~Simulink.BlockDiagramAssociatedData.isRegistered(0,deferPostloadDataName)
                Simulink.BlockDiagramAssociatedData.register(0,deferPostloadDataName,'bool');
            end
            Simulink.BlockDiagramAssociatedData.set(modelH,deferPostloadDataName,true);
        end

    case 'init'
        if rmiInstalledAndLicensed

            set_param(modelH,'reqMAdvTable',[]);
        end

    case 'markForMigration'


        deferredNotifications(modelH)={message('Slvnv:slreq:DataNeedsUpdating'),message('Slvnv:slreq:UpdateNow')};
        lastAutocreated=modelH;

    case 'open'



        if Simulink.BlockDiagramAssociatedData.isRegistered(0,deferPostloadDataName)...
            &&Simulink.BlockDiagramAssociatedData.get(modelH,deferPostloadDataName)

            Simulink.BlockDiagramAssociatedData.set(modelH,deferPostloadDataName,false);
            nn=preLoadCallback(modelH);
            if~isempty(nn)
                deferredNotifications(modelH)=nn;
            end
        end

        hasDataToMigrate=deferredNotifications.isKey(modelH);
        if hasDataToMigrate&&strcmpi(get_param(modelH,'IsHarness'),'off')
            if~isempty(lastAutocreated)&&modelH==lastAutocreated





                if~isempty(get_param(modelH,'Filename'))&&rmi.isInstalled()
                    rmisl.notifycb('UpdateNow',modelH);
                else



                    notifyMsgCell=deferredNotifications(modelH);
                    rmisl.notify(modelH,notifyMsgCell{:});
                end
                lastAutocreated=[];
            elseif rmiInstalledAndLicensed




                notifyMsgCell=deferredNotifications(modelH);
                rmisl.notify(modelH,notifyMsgCell{:});
            end
            deferredNotifications.remove(modelH);
        end
        if rmiInstalledAndLicensed


            appmgr=slreq.app.MainManager.getInstance;
            appmgr.initPerspective();




            if(hasDataToMigrate&&~rmidata.isExternal(modelH))...
                ||(~strcmpi(get_param(modelH,'IsHarness'),'on')...
                &&isempty(get_param(modelH,'FileName')))
                appmgr.perspectiveManager.addInDisabledModelList(modelH);
            end
        elseif slreq.app.MainManager.exists()




            appmgr=slreq.app.MainManager.getInstance;
            if~isempty(appmgr.perspectiveManager)
                appmgr.perspectiveManager.addInDisabledModelList(modelH);
            end
        end

    case 'preSave'

        rmidata.save(modelH);



        prevName=get_param(modelH,'PreviousFileName');





        if isempty(prevName)
            if rmiInstalledAndLicensed&&slreq.app.MainManager.exists()
                appmgr=slreq.app.MainManager.getInstance;
                if~isempty(appmgr.perspectiveManager)
                    appmgr.perspectiveManager.removeFromDisabledModelList(modelH);
                end
            end
        elseif~strcmp(prevName,get_param(modelH,'FileName'))


            rmisl.notify(modelH);

            if slreq.utils.isInPerspective(modelH)&&slreq.app.MainManager.exists()



                appmgr=slreq.app.MainManager.getInstance;
                spmgr=appmgr.spreadsheetManager;
                spmgr.updateSpreadSheetForTarget(modelH);
            end

            if slreq.data.ReqData.exists()


                reqData=slreq.data.ReqData.getInstance();
                reqsetName=reqData.getSfReqSet(modelH);
                if~isempty(reqsetName)
                    dataReqSet=reqData.getReqSet(reqsetName);
                    if~isempty(dataReqSet)&&~isempty(dataReqSet.parent)&&dataReqSet.hasIncomingLinks()


                        modelName=getfullname(modelH);
                        msgBody=message('Slvnv:slreq:SFTableIncomingLinks',modelName);
                        cbMsgBody1=message('Slvnv:slreq:UpdateReqTableIncomingLinks');
                        cbMsgBody2=message('Slvnv:slreq:DisconnectReqTableIncomingLinks');
                        rmisl.notify(modelH,msgBody,cbMsgBody1,cbMsgBody2);
                    end
                end
            end
        end

    case{'close'}
        if deferredNotifications.isKey(modelH)
            deferredNotifications.remove(modelH);
        end
        rmidata.close(modelH);

    case{'forceClose'}




        if rmisl.isComponentHarness(modelH)
            return;
        end

        if deferredNotifications.isKey(modelH)
            deferredNotifications.remove(modelH);
        end
        rmidata.discard(modelH);
        if slreq.app.MainManager.exists()
            slreq.app.MainManager.modelCloseCallback(modelH);
        end

    case 'resolveLink'

        set_param(modelH,'GUIDTable',[]);

    otherwise
        error(message('Slvnv:vnvcallback:UnexpectedNotificationRMI',method));
    end
end



function deferredNotifications=preLoadCallback(modelH)
    s=slreq.app.MainManager.startUserAction();%#ok<NASGU> 

    [notifyMsgCell,isLinkSetLoaded]=rmidata.init(modelH);
    hasDataToMigrate=~isempty(notifyMsgCell);
    if hasDataToMigrate


        deferredNotifications=notifyMsgCell;
    else
        deferredNotifications=[];
    end


    vnv_assert_mgr('mdlPostLoadSigb',modelH);

    if~isLinkSetLoaded&&slreq.app.MainManager.hasEditor()
        slreq.app.MainManager.getInstance().refreshUIOnArtifactLoad(get_param(modelH,'FileName'));
    end
end



