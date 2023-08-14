function refreshblockmask(hBlk,paramAttributes)





    mo=Simulink.Mask.get(hBlk);



    ts=mo.getParameter('ComponentPathTimeStamp');
    if isempty(ts)
        try
            simscape.engine.sli.internal.setupblockmask(hBlk,paramAttributes);
            return;
        catch ME
            ME.throwAsCaller();
        end
    end







    linkStatus=get_param(hBlk,'LinkStatus');
    if strcmp(linkStatus,'implicit')
        pm_error(...
        'physmod:simscape:engine:sli:block:InvalidImplicitLink',...
        getfullname(hBlk));
    elseif~strcmp(linkStatus,'none')
        pm_warning(...
        'physmod:simscape:engine:sli:block:LinkedSimscapeComponent',...
        getfullname(hBlk));
        set_param(hBlk,'LinkStatus','none');
    end


    simscape.gl.sli.internal.setMaskParamAttributes(hBlk,paramAttributes);


    lRefreshBlockIcon(hBlk);


    lCheckoutLicense(mo);

    component=simscape.getBlockComponent(hBlk);
    if isempty(component)
        if bdIsLibrary(bdroot(hBlk))
            mo.Display=...
            simscape.engine.sli.internal.componentmaskdisplay('SimscapeComponentName');
        else
            mo.Display=...
            simscape.engine.sli.internal.componentmaskdisplay('UnspecifiedComponentName');
        end
    end


    simscape.engine.sli.internal.setComponentBlockCallbacks(hBlk);

end

function lCheckoutLicense(mo)

    editMode=simscape.engine.sli.internal.getmaskeditingmode(mo);
    sourceFile=simscape.getBlockComponent(mo.getOwner().handle);

    theProduct=...
    simscape.engine.sli.internal.getcomponentproduct(sourceFile);
    if isempty(theProduct)
        tmpProduct=pmsl_defaultproduct;
    else
        tmpProduct=theProduct;
    end

    if strcmp(editMode,'Full')&&~pmsl_checklicense(tmpProduct)



        simscape.engine.sli.internal.setupmaskeditingmode(mo,'Restricted',tmpProduct);
        pm_error('physmod:simscape:engine:sli:block:CannotCheckoutComponentLicense',...
        tmpProduct,sourceFile);
    end

    simscape.engine.sli.internal.setupmaskeditingmode(mo,editMode,theProduct);

end

function lRefreshBlockIcon(hBlock)

    iconKey=SLBlockIcon.getEffectiveBlockIconKey(hBlock);
    DVG.Registry.refreshIcon(iconKey);
end
