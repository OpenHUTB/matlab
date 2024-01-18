function[myPath,ext]=getFilePath(shortOrLocalName,refPath)

    if nargin<2
        refPath=pwd;
    end
    [~,name,ext]=fileparts(shortOrLocalName);
    if isempty(ext)
        ext='.mldatx';
        shortOrLocalName=[shortOrLocalName,ext];
    elseif~any(strcmpi(ext,{'.mldatx','.m'}))
        error(message('Slvnv:slreq_import:ImportInvalidFileType',ext,'Simulink Test'));
    end
    myPath=slreq.uri.ResourcePathHandler.getFullPath(shortOrLocalName,refPath);
    if~isempty(myPath)
        return;
    end
    currentTF=stm.internal.util.getCurrentTestCase();
    if~isempty(currentTF)&&contains(currentTF,[filesep,name,'.mldatx'])
        myPath=currentTF;
        return;
    end

    myPath=findLoadedTestFile(name);

end


function pathToTestFile=findLoadedTestFile(testName)
    pathToTestFile='';
    testFiles=sltest.testmanager.getTestFiles();
    for i=1:numel(testFiles)
        if strcmp(testFiles(i).Name,testName)
            pathToTestFile=testFiles(i).FilePath;
            break;

        end
    end
end

