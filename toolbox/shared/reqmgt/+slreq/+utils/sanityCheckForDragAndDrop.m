function tf=sanityCheckForDragAndDrop(objH)
    sr=sfroot;
    if sr.isValidSlObject(objH)
        rootmodel=bdroot(objH);
    else
        objUDDH=sr.idToHandle(double(objH));
        rootmodel=get_param(objUDDH.Machine.Name,'Handle');
    end

    [isDisabled,reason]=slreq.utils.isDisabledModel(rootmodel);
    if isDisabled
        tf=false;
        if strcmp(reason,'emptyfile')
            slreq.utils.errorDlgForEmptyModel('create links');
        end
    else
        tf=true;
    end
end