function[navcmd,dispstr,bitmap]=getBacklinkAttributes(mwSourceArtifact,mwItemId,mwDomain,isTextRange)







    switch mwDomain
    case 'linktype_rmi_simulink'
        [~,mdlName]=fileparts(mwSourceArtifact);

        if nargin<4||isempty(isTextRange)
            isTextRange=~isempty(mwItemId)&&~rmisl.isSidString([mdlName,mwItemId]);
        end
        if isTextRange

            [navcmd,dispstr,bitmap]=rmiml.bookmarkInfo(mwSourceArtifact,mwItemId);
        else


            objH=Simulink.ID.getHandle([mdlName,mwItemId]);
            [navcmd,dispstr,bitmap]=rmi.objinfo(objH);
        end
    case 'linktype_rmi_matlab'

        [navcmd,dispstr,bitmap]=rmiml.bookmarkInfo(mwSourceArtifact,mwItemId);
    case 'linktype_rmi_data'
        [navcmd,dispstr,bitmap]=rmide.getDataObjInfo(mwSourceArtifact,mwItemId);
    case{'linktype_rmi_slreq','linktype_rmi_testmgr'}
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(mwDomain);
        dispstr=adapter.getLinkLabel(mwSourceArtifact,mwItemId);
        if strcmp(rmipref('ModelPathReference'),'none')
            mwSourceArtifact=slreq.uri.getShortNameExt(mwSourceArtifact);
        end
        if~adapter.isResolved(mwSourceArtifact,mwItemId)
            error(message('Slvnv:slreq:UnableToResolveObject',[artifact,id]));
        end
        navcmd=adapter.getExternalNavCmd(mwSourceArtifact,mwItemId);
        if nargout>2


            bitmap=rmiut.getMwIcon();
        end
    otherwise
        error('Backlinks management not supported for %s',mwDomain);
    end

end

