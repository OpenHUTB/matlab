function unpackHDL(fullName,dstDir)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    year=RelationshipHDL.getRelationshipYear();







    writeRelationship(fullName,dstDir,'hdl',year);
end

