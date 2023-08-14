classdef MemoryNames<handle



    properties(Access=public,Constant)
        TempNameModifier='TEMP_HARNESS'
    end

    properties(Access=private,Constant)
        MemoryNameMap=containers.Map();
    end


    methods(Access=private)

        function obj=MemoryNames()
        end

    end


    methods(Access=public,Static)

        function put(modelFilePath,harnessName,harnessNameInMemory)
            import slxmlcomp.internal.testharness.MemoryNames;
            if~MemoryNames.MemoryNameMap.isKey(modelFilePath)
                MemoryNames.addNewFileEntry(modelFilePath);
            end

            modelMap=MemoryNames.MemoryNameMap(modelFilePath);
            if~modelMap.isKey(harnessName)
                MemoryNames.addNewHarnessEntry(modelFilePath,harnessName);
            end

            modelMap(harnessName)=harnessNameInMemory;%#ok<NASGU>
        end

        function harnessNameInMemory=get(modelFilePath,harnessName)
            import slxmlcomp.internal.testharness.MemoryNames;
            harnessNameInMemory=[];
            if~MemoryNames.MemoryNameMap.isKey(modelFilePath)
                return
            end

            modelMap=MemoryNames.MemoryNameMap(modelFilePath);
            if~modelMap.isKey(harnessName)
                return
            end

            harnessNameInMemory=modelMap(harnessName);
        end

        function harnesses=getAll(modelFilePath)
            import slxmlcomp.internal.testharness.MemoryNames;
            harnesses=[];
            if~MemoryNames.MemoryNameMap.isKey(modelFilePath)
                return
            end
            harnessMap=MemoryNames.MemoryNameMap(modelFilePath);
            harnesses=harnessMap.values();
        end

        function remove(modelFilePath)
            import slxmlcomp.internal.testharness.MemoryNames;
            if~MemoryNames.MemoryNameMap.isKey(modelFilePath)
                return
            end
            MemoryNames.MemoryNameMap.remove(modelFilePath);
        end

        function fileName=getFileFromHarness(harnessNameInMemory)
            import slxmlcomp.internal.testharness.MemoryNames;

            fileMaps=MemoryNames.MemoryNameMap.values();
            fileNames=MemoryNames.MemoryNameMap.keys();

            tempHarnessNames=cellfun(@(x)x.values(),fileMaps,'UniformOutput',false);
            isPresent=cellfun(@(x)strcmp(x,harnessNameInMemory),tempHarnessNames,'UniformOutput',false);
            inFile=cellfun(@sum,isPresent);
            if any(inFile>1)||sum(inFile)>1
                slxmlcomp.internal.error('engine:InvalidMemoryNames');
            elseif isequal(sum(inFile),0)
                fileName='';
            else
                fileName=fileNames{logical(inFile)};
            end
        end

    end


    methods(Access=private,Static)

        function addNewFileEntry(modelFilePath)
            map=slxmlcomp.internal.testharness.MemoryNames.MemoryNameMap;
            map(modelFilePath)=containers.Map();%#ok<NASGU>
        end

        function addNewHarnessEntry(modelFilePath,harnessName)
            map=slxmlcomp.internal.testharness.MemoryNames.MemoryNameMap;
            fileMap=map(modelFilePath);
            fileMap(harnessName)=containers.Map();%#ok<NASGU>
        end

    end

end

