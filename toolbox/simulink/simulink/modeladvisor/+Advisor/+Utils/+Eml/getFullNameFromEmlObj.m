function fullName=getFullNameFromEmlObj(eml_obj)

    if isa(eml_obj,'Stateflow.EMFunction')
        fullName=[eml_obj.Path,':',num2str(eml_obj.SSIdNumber)];
    else
        fullName=eml_obj.getFullName();
    end
end