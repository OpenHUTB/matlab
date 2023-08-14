function ret=checkTargetUserDataClass(TUD)






    ret=true;


    if~isscalar(TUD)||~isobject(TUD)
        ret=false;
        return;
    end



    hClass=metaclass(TUD);
    if~l_checkSuperclass(hClass)
        ret=false;
        return;
    end


    w=warning('off','MATLAB:structOnObject');
    reset_warnings=onCleanup(@()warning(w));
    TUDStruct=[];
    try
        TUDStruct=struct(TUD);
    catch E %#ok<NASGU>
    end
    delete(reset_warnings);



    propList=hClass.PropertyList;
    for i=1:numel(propList)
        prop=propList(i);
        if~isempty(prop.Validation)
            cls=prop.Validation.Class;
            if isempty(cls)||cls==?cell||cls==?struct
                ret=false;
                return;
            end
        else
            propTypeName=prop.Type.Name;
            tokens=regexp(propTypeName,'\ ','split');
            for j=1:numel(tokens)
                if ismember(tokens{j},{'cell','struct','any'})
                    ret=false;
                    return;
                end
            end
        end

        propName=prop.Name;


        if isfield(TUDStruct,propName)
            propVal=TUDStruct.(propName);
            if isobject(propVal)||...
                isa(propVal,'handle.handle')||...
                isa(propVal,'handle vector')
                ret=false;
                return;
            end
        end
    end

end




function ret=l_checkSuperclass(hClass)



    superclass=hClass.SuperclassList;
    if~isscalar(superclass)
        ret=false;
        return;
    end

    if strcmp(superclass.Name,'Simulink.UserData')
        ret=true;
    else

        ret=l_checkSuperclass(superclass);
    end

end
