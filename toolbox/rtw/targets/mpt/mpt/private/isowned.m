function[status,effectiveDataOwner,isDataOwnerIgnored]=isowned(name,obj,cscdef,moduleName)




























    name=convertStringsToChars(name);

    moduleName=convertStringsToChars(moduleName);

    status=1;
    effectiveDataOwner='';
    isDataOwnerIgnored=false;

    if isempty(obj)
        obj=evalin('base','name');
        assert(~isempty(obj)&&(isa(obj,'Simulink.Signal')||isa(obj,'Simulink.Parameter')));
    end

    if isempty(cscdef)
        dataOwner='';
    elseif cscdef.IsOwnerInstanceSpecific

        assert(isprop(obj.CoderInfo.CustomAttributes,'Owner'),...
        'Owner property missing on CustomAttributes');
        dataOwner=obj.CoderInfo.CustomAttributes.Owner;
    else
        dataOwner=cscdef.Owner;
    end

    if isempty(deblank(moduleName))


        if~isempty(deblank(dataOwner))
            isDataOwnerIgnored=true;
        end
        return;
    end

    if isempty(deblank(dataOwner))

        status=1;
    elseif strcmp(moduleName,dataOwner)==1

        status=1;
        effectiveDataOwner=dataOwner;
    else
        if strcmpi(moduleName,dataOwner)==1

            MSLDiagnostic('RTW:mpt:DataOwnerNameCaseInsensitiveMatch',name,dataOwner,moduleName).reportAsWarning;
        end

        status=0;
        effectiveDataOwner=dataOwner;
    end
