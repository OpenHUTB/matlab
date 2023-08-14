function[hidToOpen,objToOpen]=getHIDAndObjToOpen(cbinfo)





    hidToOpen=cbinfo.targetHID;
    hidToOpen=GLUE2.HierarchyService.getChildren(hidToOpen);
    if isempty(hidToOpen)
        hidToOpen=GLUE2.HierarchyId;
    else
        hidToOpen=hidToOpen(1);
    end
    [target,targethid]=SLStudio.Utils.getTargetInfo(cbinfo);

    if~GLUE2.HierarchyService.isValid(targethid)&&~target.isvalid
        return
    end
    if~target.isvalid
        scopedTarget=GLUE2.HierarchyService.getM3IObject(targethid);
        target=scopedTarget.temporaryObject();
    end
    objToOpen=get_param(target.handle,'Object');


    if target.isConfigurableSubsystemInstance&&SLStudio.Utils.ConfigSSHasValidBlockChoice(objToOpen.handle)
        objToOpen=objToOpen.getChildren;



        if(target.handle==SLM3I.SLDomain.getSLHandleForHID(hidToOpen))||isempty(objToOpen)
            hidToOpen=GLUE2.HierarchyId;
        else
            objToOpen=objToOpen(1);
        end
    end
end
