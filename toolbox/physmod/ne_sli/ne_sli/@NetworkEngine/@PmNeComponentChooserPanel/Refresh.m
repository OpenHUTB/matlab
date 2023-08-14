function retStatus=Refresh(hThis)




    retStatus=true;








    nesl_getfunctioninfo=nesl_private('nesl_getfunctioninfo');
    info=nesl_getfunctioninfo(hThis.ComponentName);

    nesl_resolvefunctioninfo=nesl_private('nesl_resolvefunctioninfo');
    [compName,msg]=nesl_resolvefunctioninfo(info);
    if isempty(hThis.ComponentName)
        titleTxt=getString(message('physmod:ne_sli:dialog:EmptyComponentSpecificationTitle'));
        descriptionTxt=getString(message('physmod:ne_sli:dialog:EmptyComponentSpecification'));
    elseif isempty(compName)
        titleTxt=getString(message('physmod:ne_sli:dialog:ErrorWhileLoadingComponent'));
        descriptionTxt=msg;
    else
        hThis.ComponentName=compName;
        getInfo=nesl_private('nesl_getbasiccomponentinfo');
        [titleTxt,descriptionTxt]=getInfo(hThis.ComponentName);
    end

    hThis.ComponentTitle=titleTxt;
    hThis.ComponentDescription=descriptionTxt;

    hThis.Enabled=~pmsl_ismodelrunning(hThis.BlockHandle.Handle)&&...
    lIsFullMode(hThis.BlockHandle.Handle);

end

function result=lIsFullMode(hBlock)
    editingMode=...
    simscape.engine.sli.internal.getmaskeditingmode(...
    pm.sli.internal.rootMask(hBlock));
    result=strcmp(editingMode,'Full');
end
