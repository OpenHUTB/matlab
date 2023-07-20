function[year,encryptionCategory]=getStaticInformationForRelationship(rel,target)





    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;
    switch rel
    case 'html'
        year=RelationshipReport.getRelationshipYear();
        encryptionCategory=RelationshipReport.getEncryptionCategory();
    case 'htmlsummary'
        year=RelationshipReportSummary.getRelationshipYear();
        encryptionCategory=RelationshipReportSummary.getEncryptionCategory();
    case constructTargetRelationshipName('htmlcodegen',target)
        year=RelationshipReportCodegen.getRelationshipYear();
        encryptionCategory=RelationshipReportCodegen.getEncryptionCategory();
    case constructTargetRelationshipName('htmlcodegensummary',target)
        year=RelationshipReportCodegenSummary.getRelationshipYear();
        encryptionCategory=RelationshipReportCodegenSummary.getEncryptionCategory();
    case 'sim'
        year=RelationshipAccel.getRelationshipYear();
        encryptionCategory=RelationshipAccel.getEncryptionCategory();
    case constructTargetRelationshipName('simCG',target)
        year=RelationshipAccelForCodegen.getRelationshipYear();
        encryptionCategory=RelationshipAccelForCodegen.getEncryptionCategory();
    case 'modelReferenceSimTarget'
        year=RelationshipMex.getRelationshipYear();
        encryptionCategory=RelationshipMex.getEncryptionCategory();
    case constructTargetRelationshipName('modelReferenceSimTargetCG',target)
        year=RelationshipMexForCodegen.getRelationshipYear();
        encryptionCategory=RelationshipMexForCodegen.getEncryptionCategory();
    case constructTargetRelationshipName('infoForCodeGen',target)
        year=RelationshipInfoForCodegen.getRelationshipYear();
        encryptionCategory=RelationshipInfoForCodegen.getEncryptionCategory();
    case 'webview'
        year=RelationshipProtectedModelWebview.getRelationshipYear();
        encryptionCategory=RelationshipProtectedModelWebview.getEncryptionCategory();
    case constructTargetRelationshipName('rtwsharedutils',target)
        year=RelationshipTargetSharedUtils.getRelationshipYear();
        encryptionCategory=RelationshipTargetSharedUtils.getEncryptionCategory();
    case constructTargetRelationshipName('custom',target)
        year=RelationshipCustom.getRelationshipYear();
        encryptionCategory=RelationshipCustom.getEncryptionCategory();
    case constructTargetRelationshipName('rtwsharedutilshtml',target)
        year=RelationshipReportSharedUtils.getRelationshipYear();
        encryptionCategory=RelationshipReportSharedUtils.getEncryptionCategory();
    case 'simsharedutils'
        year=RelationshipAccelSharedUtils.getRelationshipYear();
        encryptionCategory=RelationshipAccelSharedUtils.getEncryptionCategory();
    case constructTargetRelationshipName('simsharedutilsCG',target)
        year=RelationshipAccelSharedUtilsForCodegen.getRelationshipYear();
        encryptionCategory=RelationshipAccelSharedUtilsForCodegen.getEncryptionCategory();
    case 'extraInformation'
        year=RelationshipInformation.getRelationshipYear();
        encryptionCategory=RelationshipInformation.getEncryptionCategory();
    case 'modifyPermission'
        year=RelationshipModifyPermission.getRelationshipYear();
        encryptionCategory=RelationshipModifyPermission.getEncryptionCategory();
    case 'thumbnail'
        year=RelationshipProtectedModelThumbnail.getRelationshipYear();
        encryptionCategory=RelationshipProtectedModelThumbnail.getEncryptionCategory();
    case constructTargetRelationshipName('configset',target)
        year=RelationshipConfigSetCodegen.getRelationshipYear();
        encryptionCategory=RelationshipConfigSetCodegen.getEncryptionCategory();
    case 'configset'
        year=RelationshipConfigSet.getRelationshipYear();
        encryptionCategory=RelationshipConfigSet.getEncryptionCategory();
    case target
        if~strcmp(rel,'sim')
            year=RelationshipTarget.getRelationshipYear();
            encryptionCategory=RelationshipTarget.getEncryptionCategory();
        end
    case 'hdl'
        year=RelationshipHDL.getRelationshipYear();
        encryptionCategory=RelationshipHDL.getEncryptionCategory();
    case 'checksumMismatch'
        year=RelationshipVariableChecksum.getRelationshipYear();
        encryptionCategory=RelationshipVariableChecksum.getEncryptionCategory();
    otherwise
        assert(false,'relationship not recognized');
    end

end



