function setupStateflowExample()



    exampleDir=slxmlcomp.internal.examples.Utils.createTempDir();
    cd(exampleDir);

    import slxmlcomp.internal.examples.Utils.copyAndMakeWritable
    copyAndMakeWritable(exampleDir,'sl_sfcar_1.slx',true)
    copyAndMakeWritable(exampleDir,'sl_sfcar_2.slx',true)
end

