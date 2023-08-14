function retVal=getDefaultClassname(class)




    [list,defItemIndx]=Simulink.data.findValidClasses(class);

    retVal=list{defItemIndx+1};
end