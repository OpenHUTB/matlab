function updateRequirements(ownerHandle,harnessHandle,eventName)











    if slreq.utils.isInPerspective(ownerHandle)
        mgr=slreq.app.MainManager.getInstance;
        mgr.updateRequirementsForHarness(ownerHandle,harnessHandle,eventName);
    else

    end
end

