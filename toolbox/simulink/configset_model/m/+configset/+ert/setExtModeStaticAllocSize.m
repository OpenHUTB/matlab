function newvalue=setExtModeStaticAllocSize(~,value)




    if value<0
        DAStudio.error('Simulink:Engine:ExtModeInvalidNonNegativeValue','ExtModeStaticAllocSize');
    end
    newvalue=value;
end
