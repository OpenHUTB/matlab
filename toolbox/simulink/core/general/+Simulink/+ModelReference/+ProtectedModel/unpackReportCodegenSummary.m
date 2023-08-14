function unpackReportCodegenSummary(fullName,dstDir,target)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;

    year=RelationshipReportCodegenSummary.getRelationshipYear();
    htmlcodegensummary=constructTargetRelationshipName('htmlcodegensummary',target);
    writeRelationship(fullName,dstDir,htmlcodegensummary,year);


