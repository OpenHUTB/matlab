function req=selectionLink(objH,make2way)



    req=[];








    blks=get_param(gcs,'blocks');
    topMdlH=rmifa.getTopModelFromModelElement(get_param([gcs,'/',blks{1}],'handle'));

    try

        sel=safety.gui.GUIManager.getInstance.getFaultTableCurrentSelection(topMdlH);
        targetObj=safety.fault.internal.getExtFaultInfoObjFromUUID(topMdlH,sel);


    catch ME
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkNoFaultError')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;
    end


    if~rmifa.isLinkingForFaultObjAllowed(targetObj)
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:InvalidFaultInfoObjectLinkError')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;
    end

    if make2way
        srcType=rmiut.resolveType(objH);
        callerInfoStruct=rmi.makeReq(objH,targetObj,srcType);
        if isempty(callerInfoStruct)

            req=[];
            return;
        else
            rmi.catReqs(targetObj,callerInfoStruct);
        end
    end

    req=rmifa.makeReq(targetObj);
end