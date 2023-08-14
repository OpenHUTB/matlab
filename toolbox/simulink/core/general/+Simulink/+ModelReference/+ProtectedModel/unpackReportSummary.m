function unpackReportSummary(fullName,dstDir)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    year=RelationshipReportSummary.getRelationshipYear();


    writeRelationship(fullName,dstDir,'htmlsummary',year);
end

