function newId=getUpdatedHarnessId(rootName,id)






    if id(1)==':'
        id(1)=[];
    end

    stmUpdate=Simulink.harness.internal.getUUIDChanged(rootName,id);
    if stmUpdate.uuidChanged
        newId=[':',stmUpdate.newUUID];
    else
        newId='';
    end
end
