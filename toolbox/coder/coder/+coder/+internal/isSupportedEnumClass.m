function[result,errorMsg]=isSupportedEnumClass(aClassOrName,aAllowPackages)








    if nargin<2
        aAllowPackages=false;
    end


    if(ischar(aClassOrName)||...
        (isscalar(aClassOrName)&&isstring(aClassOrName)))
        aClass=meta.class.fromName(aClassOrName);
        className=aClassOrName;
    else
        if isscalar(aClassOrName)&&isa(aClassOrName,'meta.class')
            aClass=aClassOrName;
            className=aClass.Name;
        else


            result=false;
            errorMsg=[];
            return;
        end
    end
    errorMsg=[];

    if isscalar(aClass)&&isa(aClass,'meta.class')
        className=aClass.Name;
        if isempty(aClass.EnumerationMemberList)
            result=false;
            errorMsg=message('Coder:common:TypeSpecUnsupportedNotAnEnum',className);
            return;
        end
        if~l_ValidSuperclass(aClass)
            result=false;
            errorMsg=message('Coder:builtins:ClassdefNotAnEnumeration',className);
            return;
        end
        if~l_ValidUnderlyingValues(aClass)
            result=false;

            errorMsg=message('Coder:common:EnumRealValues',className);
            return;
        end

        if~aAllowPackages
            result=isempty(aClass.ContainingPackage);

            errorMsg=message('Coder:common:TypeSpecUnknownClass',className);
            return;
        end
    else
        result=false;
        errorMsg=message('Coder:common:TypeSpecUnknownClass',className);
        return;
    end
    result=true;

end




function result=l_ValidSuperclass(aClass)

    result=(isscalar(aClass.SuperclassList)&&...
    ismember(aClass.SuperclassList.Name,...
    {'Simulink.IntEnumType',...
    'Simulink.Mask.EnumerationBase',...
    'int8',...
    'int16',...
    'int32',...
    'uint8',...
    'uint16'}));
end


function result=l_ValidUnderlyingValues(aClass)
    enumValues=enumeration(aClass.Name);




    result=isreal(enumValues);
end


