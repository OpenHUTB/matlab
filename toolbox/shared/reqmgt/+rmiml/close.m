function close(mFile,isForce)




    mFile=convertStringsToChars(mFile);

    if nargin<2
        isForce=false;
    end

    if~ischar(mFile)
        mFile=char(mFile);
    end

    if rmisl.isSidString(mFile)



        if rmi.isInstalled()
            slreq.mleditor.moveBookmark(mFile);
        end
        return;
    end

    if slreq.data.ReqData.exists()
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(mFile);
        if~isempty(linkSet)
            if linkSet.dirty
                if~isForce
                    if rmiml.promptToSave(mFile,'')
                        linkSet.save();
                    end
                elseif slreq.internal.isSharedSlreqInstalled()&&slreq.linkmgr.LinkSetManager.exists()


                    reqSets=linkSet.getRegisteredRequirementSets();
                    if~isempty(reqSets)
                        lsm=slreq.linkmgr.LinkSetManager.getInstance();
                        for i=1:numel(reqSets)
                            lsm.removeReference(linkSet,reqSets{i});
                        end
                    end
                end
            end
            if rmi.isInstalled()
                slreq.mleditor.moveBookmark(mFile);
            end
            linkSet.discard();




            if slreq.app.MainManager.exists()&&slreq.internal.isSharedSlreqInstalled()
                slreq.linkmgr.LinkSetManager.getInstance.onArtifactClose(mFile);
            end







        end

        slreq.mleditor.ReqPluginHelper.getInstance.reset(mFile);
    end
end
