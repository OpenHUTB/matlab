function accept=isAllocationSet(filepath)




    accept=endsWith(filepath,".mldatx")&&...
    strcmp(matlabshared.mldatx.internal.getApplication(filepath),'System_Composer_Allocation_Set');

end

