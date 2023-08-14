function setupCompareMergeExample()



    exampleDir=slxmlcomp.internal.examples.Utils.createTempDir();
    cd(exampleDir);

    import slxmlcomp.internal.examples.Utils.copyAndMakeWritable
    copyAndMakeWritable(exampleDir,'sl_aircraft1.slx',false)
    copyAndMakeWritable(exampleDir,'sl_aircraft2.slx',false)
end
