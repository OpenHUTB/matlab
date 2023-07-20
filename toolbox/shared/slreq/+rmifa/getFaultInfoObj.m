function[faultInfoObj,mdlH]=getFaultInfoObj(doc,location)


    [~,mdlName]=fileparts(doc);
    mdlH=get_param(mdlName,'handle');
    uuid=rmifa.getUUIDFromID(location);
    faultInfoObj=safety.fault.internal.getExtFaultInfoObjFromUUID(mdlH,uuid);
    if~(rmifa.isLinkingForFaultObjAllowed(faultInfoObj))

        assert(false,'Only Fault and Conditional objects currently allowed to be linked');
    end
end