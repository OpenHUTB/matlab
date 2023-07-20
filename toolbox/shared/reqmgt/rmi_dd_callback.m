function rmi_dd_callback(ddFilePath,eventLabel)







    if rmiut.isBuiltinNoRmi(ddFilePath)
        return;
    end

    switch eventLabel

    case 'postSave'
        slreq.saveLinks(ddFilePath);

    case 'postRevert'
        slreq.discardLinkSet(ddFilePath);

    case 'preClose'
        if rmi.isInstalled()


            slreq.internal.delayedLinksetLoader('remove',ddFilePath);






        end

        rmide.connection([]);

    case 'postOpen'
        if rmi.isInstalled()
            uiUpdated=false;
            hasEditor=slreq.app.MainManager.hasEditor();
            ddAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_data');
            ddAdapter.temporaryDisabledDD='';
            if slreq.hasData(ddFilePath)



                linkSet=slreq.data.ReqData.getInstance.getLinkSet(ddFilePath);
                if slreq.internal.isSharedSlreqInstalled()
                    slreq.linkmgr.LinkSetManager.getInstance.addReference(linkSet,linkSet.artifact);
                end
            else









                if hasEditor
                    uiUpdated=slreq.utils.loadLinkSet(ddFilePath);
                else

                    slreq.internal.delayedLinksetLoader('delay',ddFilePath);
                end
            end
            if~uiUpdated
                if hasEditor
                    slreq.app.MainManager.getInstance().refreshUIOnArtifactLoad(ddFilePath);
                end
            end
        end

    case 'uiClose'
        if slreq.hasData(ddFilePath)
            if slreq.hasChanges(ddFilePath)
                if rmide.promptToSave(ddFilePath)
                    slreq.saveLinks(ddFilePath);
                end
            end
        end





        slreq.discardLinkSet(ddFilePath);


        ReqMgr.rmidlg_mgr('close',ddFilePath);





        ddAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_data');
        ddAdapter.temporaryDisabledDD=ddFilePath;
        rmide.connection([]);

    otherwise

        warning(['rmi:dd_callback(): nothing to do for method "',eventLabel,'"']);
    end

end

