function unpackDDForChecksum(protectedModelFile,dstDir)






    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    year=RelationshipVariableChecksum.getRelationshipYear();

    [~,fullName]=getOptions(protectedModelFile);



    writeRelationship(fullName,dstDir,'checksumMismatch',year);
end

