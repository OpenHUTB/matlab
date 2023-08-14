function[isValid,msgString,newComponentName]=...
    nesl_validatecomponentsource(componentName)





    isValid=false;
    newComponentName=componentName;


    nesl_getfunctioninfo=nesl_private('nesl_getfunctioninfo');
    info=nesl_getfunctioninfo(componentName);


    nesl_promptifaddpathneeded=nesl_private('nesl_promptifaddpathneeded');
    info=nesl_promptifaddpathneeded(info);






    nesl_resolvefunctioninfo=nesl_private('nesl_resolvefunctioninfo');
    [compFunctionalName,resolveMsg]=nesl_resolvefunctioninfo(info);

    if isempty(componentName)
        msgString=getString(message(...
        'physmod:ne_sli:dialog:SimscapeComponentUnspecified'));
    elseif isempty(compFunctionalName)
        msgString=resolveMsg;
    else

        product=simscape.engine.sli.internal.getcomponentproduct(compFunctionalName);
        if isempty(product)
            product=pmsl_defaultproduct;
        end
        isValid=pmsl_checklicense(product);
        if~isValid
            msgString=getString(message(...
            'physmod:simscape:engine:sli:block:NoLicenseToSetComponent',...
            compFunctionalName,product));
            newComponentName=componentName;
            return
        end


        nesl_isvalidsimscapecomponent=...
        nesl_private('nesl_isvalidsimscapecomponent');
        [isValid,msgString]=nesl_isvalidsimscapecomponent(compFunctionalName);
        newComponentName=compFunctionalName;
    end

end
