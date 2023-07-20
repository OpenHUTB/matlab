function[messageTitle,description]=getBasicComponentInfo(componentName)









    description=getString(message('physmod:ne_sli:dialog:EmptyComponentSpecificationTitle'));
    messageTitle=getString(message('physmod:ne_sli:dialog:EmptyComponentSpecification'));

    if~isempty(componentName)
        [result,msgString,descriptor]=simscape.internal.dialog.isValidSimscapeComponent(componentName);
        if result
            messageTitle=descriptor;
            description=msgString;
        else
            messageTitle=getString(message('physmod:ne_sli:dialog:ErrorWhileLoadingComponent'));
            description=msgString;
        end
    end

end