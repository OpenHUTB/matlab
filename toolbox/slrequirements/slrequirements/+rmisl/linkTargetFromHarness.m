function[rootId,objId]=linkTargetFromHarness(rootId,objId)







    if any(objId=='.')
        [objId,grpSuffix]=detachGroupSuffix(objId);
    else
        grpSuffix='';
    end
    objSid=[rootId,strtok(objId)];
    obj=Simulink.ID.getHandle(objSid);
    if isa(obj,'double')
        obj=get_param(obj,'Object');
    end
    if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(obj)
        srcSid=Simulink.harness.internal.sidmap.getHarnessObjectSID(obj);
        [rootId,objId]=strtok(srcSid,':');
    else
        [~,rootId]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(rootId);
    end
    if~isempty(grpSuffix)
        objId=[objId,grpSuffix];
    end
end

function[objSid,grpSuffix]=detachGroupSuffix(objSid)
    isDot=find(objSid=='.');
    grpSuffix=objSid(isDot:end);
    objSid=objSid(1:isDot-1);
end
