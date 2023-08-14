


function slMerge(baseFile,mineFile,theirsFile,targetFile,externallyLaunched)

    if(externallyLaunched)
        removalWarning=message('SimulinkXMLComparison:engine:FileComparisonDriverRemoval');
        warning('SimulinkXMLComparison:FileComparisonDriverRemoval',removalWarning.getString());
    end

    scmDataBuilder=slxmlcomp.internal.link.SCMDataBuilder();

    scmDataBuilder.addBaseFile(baseFile)...
    .addMineFile(mineFile)...
    .addTheirsFile(theirsFile)...
    .addTargetFile(targetFile);

    scmDataBuilder.setExternallyLaunched(externallyLaunched);

    comparisonParameters=com.mathworks.comparisons.param.impl.ComparisonParameterSetImpl();
    comparisonParameters.setValue(com.mathworks.comparisons.scm.CParameterDisableSaveAndClose.getInstance(),java.lang.Boolean.TRUE);

    if(externallyLaunched)
        comparisonParameters.setValue(com.mathworks.comparisons.scm.CParameterExternalSCMTool.getInstance(),java.lang.Boolean.TRUE);
    end

    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(...
    scmDataBuilder.build(),...
comparisonParameters...
    );

end