function updateDependencies(dependency,newPath)




    oPath=dependency.DownstreamNode.Location;
    tFile=dependency.UpstreamNode.Location;
    dependencyType=dependency.Type.ID;

    if~isempty(tFile)&&iscell(tFile)&&~isempty(oPath)&&iscell(oPath)
        testFile=tFile{1};
        oldPath=oPath{1};

        try
            isFileAlreadyOpen=stm.internal.isTestFileOpen(testFile);
            tf=sltest.testmanager.TestFile(testFile,false,false);
            oc=onCleanup(@()helperCloseTestFile(tf,isFileAlreadyOpen));
        catch me %#ok
            return;

        end

        stm.internal.updateDependencies(testFile,dependencyType,oldPath,newPath);
    end
end

function helperCloseTestFile(tf,isFileAlreadyOpen)
    tf.saveToFile();
    try

        if~isFileAlreadyOpen
            tf.close()
        end
    catch

    end
end
