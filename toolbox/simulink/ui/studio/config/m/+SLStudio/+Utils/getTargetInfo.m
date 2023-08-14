function[target,targetHID]=getTargetInfo(cbinfo)




    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    parentHID=cbinfo.studio.App.getActiveEditor.getHierarchyId();

    if isa(target,'GLUE2.Diagram')
        targetHID=parentHID;
    else
        targetHID=GLUE2.HierarchyServiceUtils.getElementHIDWithParent(target,parentHID);
    end