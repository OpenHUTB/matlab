function setDefaultClassname(classType,className)




    [list,defItemIndx]=Simulink.data.findValidClasses(classType);
    [ispresent,loc]=ismember(className,list);
    if ispresent&&loc>0&&defItemIndx~=loc-1
        Simulink.data.findValidClasses(classType,loc-1);

    end
end