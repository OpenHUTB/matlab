classdef SimulinkTestProvider<matlab.internal.project.unsavedchanges.LoadedFileProvider




    methods(Access=public)
        function loadedFiles=getLoadedFiles(~)
            import matlab.internal.project.unsavedchanges.LoadedFile;

            loadedFiles=LoadedFile.empty(1,0);

            if~isSimulinkStarted
                return;
            end

            testFiles=sltest.testmanager.getTestFiles();

            loadedFiles=arrayfun(@i_makeLoadedFile,testFiles);
            if isempty(loadedFiles)
                loadedFiles=matlab.internal.project.unsavedchanges.LoadedFile.empty(1,0);
            end
        end

        function save(~,filePath)
            testFile=i_findMatch(filePath);
            if~isempty(testFile)
                testFile.saveToFile();
            end
        end

        function open(~,filePath)
            testFile=i_findMatch(filePath);
            if~isempty(testFile)
                matlab.internal.project.unsavedchanges.util.highlightSltest(testFile);
            end
        end

        function discard(~,filePath)
            testFile=i_findMatch(filePath);
            if~isempty(testFile)
                testFile.close();
            end
        end

        function autoClose=isAutoCloseEnabled(~)
            autoClose=true;
        end
    end
end

function matchingTestFile=i_findMatch(filePath)
    testFiles=sltest.testmanager.getTestFiles();
    match=ismember({testFiles.FilePath},filePath);
    matchingTestFile=testFiles(match);
end

function file=i_makeLoadedFile(testFile)
    if(testFile.Dirty)
        props=matlab.internal.project.unsavedchanges.Property.Unsaved;
    else
        props=matlab.internal.project.unsavedchanges.Property.empty;
    end

    file=matlab.internal.project.unsavedchanges.LoadedFile(testFile.FilePath,props);
end
