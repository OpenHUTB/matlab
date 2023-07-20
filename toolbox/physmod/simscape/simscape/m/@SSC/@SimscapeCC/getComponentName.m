function componentName=getComponentName




    persistent fComponentName

    if isempty(fComponentName)
        hName=ssc_private('ssc_productname');
        fComponentName=hName();
    end

    componentName=fComponentName;

