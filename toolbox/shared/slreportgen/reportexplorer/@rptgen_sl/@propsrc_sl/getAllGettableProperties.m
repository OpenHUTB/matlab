function propNames=getAllGettableProperties(h,obj)









    if nargin<2
        obj=h.getTestObject;
    end

    allProps=get_param(obj,'objectparameters');
    propNames=fieldnames(allProps);
    i=1;
    while i<=length(propNames)
        if any(strcmp(subsref(allProps,substruct('.',propNames{i},'.','Attributes')),'write-only'));

            propNames=[propNames(1:i-1);propNames(i+1:end)];
        else
            i=i+1;
        end
    end
