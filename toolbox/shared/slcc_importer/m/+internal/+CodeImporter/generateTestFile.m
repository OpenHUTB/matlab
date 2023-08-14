function generateTestFile(obj,isOverwrite)

    allBlockHandle=Simulink.findBlocksOfType(obj.LibraryFileName,'CCaller');
    if isempty(allBlockHandle)
        return;
    end


    tfPath=fullfile(obj.qualifiedSettings.OutputFolder,obj.LibraryFileName);

    harnessList=sltest.harness.find(obj.LibraryFileName);
    harnessListIsEmpty=isempty(harnessList);

    if exist([tfPath.char,'.mldatx'],'file')~=2||isOverwrite||...
harnessListIsEmpty










        sltest.testmanager.clear;
        tf=sltest.testmanager.TestFile(tfPath);

        existSuites=tf.getTestSuites;
        totSuites=length(existSuites);
        for j=1:totSuites
            existSuites(j).remove;
        end
    end

    tf=sltest.testmanager.TestFile(tfPath);

    if obj.HasSLCov
        tfCovSettings=tf.getCoverageSettings();

        tfCovSettings.RecordCoverage=true;









        tfCovSettings.MetricSettings='dcmtrobr';
    end


    commentedStatus=get_param(allBlockHandle,'commented');


    if~isempty(commentedStatus)&&~iscell(commentedStatus)
        commentedStatus={commentedStatus};
    end
    isCommented=ismember(commentedStatus,'off');
    allUncommentedBlockHandle=allBlockHandle(isCommented);
    allUncommentedBlockPath=getfullname(allUncommentedBlockHandle);

    if(isempty(harnessList))

        newBlockPaths=allUncommentedBlockPath;
    else
        [harnessBlockPath{1:length(harnessList)}]=deal(harnessList.ownerFullPath);
        newBlockPaths=...
        allUncommentedBlockPath(...
        ~ismember(allUncommentedBlockPath,harnessBlockPath));
    end


    if~isempty(newBlockPaths)&&~iscell(newBlockPaths)
        newBlockPaths={newBlockPaths};
    end


    for j=1:length(newBlockPaths)
        tsObj=tf.createTestSuite(newBlockPaths{j});
        sltest.testmanager.createTestForComponent('TestFile',tsObj,...
        'Component',newBlockPaths{j},'UseComponentInputs',false,...
        'HarnessOptions',{'PostCreateCallback','internal.CodeImporter.harnessCustomization'});
    end




    for idx=1:length(newBlockPaths)
        harnessEntry=sltest.harness.find(newBlockPaths{idx});
        sltest.harness.load(harnessEntry.ownerFullPath,harnessEntry.name);
        link_sldd(obj,harnessEntry.name);
        sltest.harness.close(harnessEntry.ownerFullPath,harnessEntry.name);
    end
    tf.saveToFile();

    save_system(obj.LibraryFileName);

end


function link_sldd(obj,harnessName)




    if obj.Options.ImportTypesToFile||isempty(obj.TypesToImport)
        return;
    end



    currentDir=cd(obj.qualifiedSettings.OutputFolder);
    cleanupObj=onCleanup(@()cd(currentDir));

    dataDictName=obj.LibraryFileName+".sldd";
    assert(isfile(dataDictName),'Data dictionary file does not exist.');
    set_param(harnessName,'DataDictionary',dataDictName);

end
