


function[codeTable,blockTable,functionInterfaceTable]=...
    convertCodeData(datamgr,verification_data,...
    codeTable,blockTable,functionInterfaceTable)


    inputCodeSliceStatus=[];
    inputCodeStatus=[];
    inputCodeTrace=[];
    inspectedFiles=[];
    subsystemFiles=[];
    inputOptimizedCode=[];
    inputCodeAggStatus=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'CODE_SLICE'
            inputCodeSliceStatus=cell_data.data;
        case 'CODE_VERIFICATION_STATUS'
            inputCodeStatus=cell_data.data;
        case 'CODE_TAGS_VERIFICATION_STATUS'
            inputCodeAggStatus=cell_data.data;
        case 'CODE_TRACEABILITY'
            inputCodeTrace=cell_data.data;
        case 'INSPECTED_FILES'
            inspectedFiles=cell_data.data;
        case 'SUBSYSTEM_FILES'
            subsystemFiles=cell_data.data;
        case 'CODE_OPTIMIZED'
            inputOptimizedCode=cell_data.data;
        end
    end


    if~isempty(inspectedFiles)||~isempty(subsystemFiles)
        codeFileList={};
        headerFileList={};
        codeFileChecksumList={};

        [codeFiles,headerFiles,codeFileChecksums]=prepareFileList(inspectedFiles);
        codeFileList=horzcat(codeFileList,codeFiles);
        headerFileList=horzcat(headerFileList,headerFiles);
        codeFileChecksumList=horzcat(codeFileChecksumList,codeFileChecksums);

        [codeFiles,headerFiles,codeFileChecksums]=prepareFileList(subsystemFiles);
        codeFileList=horzcat(codeFileList,codeFiles);
        headerFileList=horzcat(headerFileList,headerFiles);
        codeFileChecksumList=horzcat(codeFileChecksumList,codeFileChecksums);

        codeFiles=datamgr.getMetaData('InspectedCodeFiles');
        codeFiles.sourceFiles=codeFileList;
        codeFiles.headerFiles=headerFileList;
        datamgr.setMetaData('InspectedCodeFiles',codeFiles);
        datamgr.setMetaData('InspectedCodeFilesChecksum',codeFileChecksumList);
    end


    codeSliceTable=containers.Map;

    if~isempty(inputCodeSliceStatus)
        [codeTable,codeSliceTable]=...
        constructCodeSliceObject(inputCodeSliceStatus,...
        codeTable,codeSliceTable,datamgr);
    end

    if~isempty(inputCodeStatus)
        [codeTable,codeSliceTable]=updateCodeAndCodeSliceObject(...
        inputCodeStatus,codeTable,codeSliceTable,datamgr);
    end

    if~isempty(inputCodeAggStatus)
        codeReader=datamgr.getCodeReader();
        codeTable=slci.results.updateCodeAggStatus(inputCodeAggStatus,...
        codeTable,datamgr,...
        codeReader);
    end

    if~isempty(inputCodeTrace)
        codeTable=slci.results.updateCodeTrace(inputCodeTrace,codeTable,datamgr);
    end


    if~isempty(inputOptimizedCode)
        codeTable=slci.results.updateOptimizedCode(inputOptimizedCode,...
        codeTable,datamgr);
    end


    slci.results.cacheData('save',codeSliceTable,datamgr,...
    datamgr.getCodeSliceReader(),'replaceObject');

end


function[codeFiles,headerFiles,codeFileChecksums]=prepareFileList(files)
    codeFiles={};
    headerFiles={};
    codeFileChecksums={};
    numFiles=numel(files);
    for k=1:numFiles

        fileName=files(k).FILENAME;
        [~,~,ext]=fileparts(fileName);
        if strcmp(ext,'.h')||strcmp(ext,'.hpp')

            headerFiles{end+1}=fileName;%#ok
        else

            codeFiles{end+1}=fileName;%#ok
            codeFileChecksums{end+1}=...
            slci.internal.getFileChecksum(fileName);%#ok
        end
    end
end


function[codeTable,codeSliceTable]=...
    constructCodeSliceObject(inputCodeSliceStatus,...
    codeTable,codeSliceTable,datamgr)

    codeSliceReader=datamgr.getCodeSliceReader();
    codeReader=datamgr.getCodeReader();


    sliceArray=slci.internal.ReportUtil.categorize('SLICE_OP',...
    inputCodeSliceStatus);

    sliceKeys=keys(sliceArray);
    numSlices=numel(sliceKeys);

    datamgr.beginTransaction();
    try
        for k=1:numSlices


            sliceKey=sliceKeys{k};


            thisSliceInfo=sliceArray(sliceKey);
            sliceName=thisSliceInfo.SLICE_NAME;


            sliceFunc=thisSliceInfo.FUNC;


            if codeSliceReader.hasObject(sliceKey)

                [sObject,codeSliceTable]=...
                slci.results.cacheData('get',codeSliceTable,...
                codeSliceReader,'getObject',sliceKey);
            else

                sObject=slci.results.CodeSliceObject(sliceKey,...
                sliceName,sliceFunc);
                codeSliceReader.insertObject(sObject.getKey(),sObject);
            end


            if~strcmp(sliceName,'NOT_AN_OUTPUT')

                numSliceInfo=numel(thisSliceInfo);
                sourceBlocks=cell(numSliceInfo,1);
                for p=1:numSliceInfo


                    [codeKey,codeFile,lineNum]=...
                    slci.results.readEngineCodeKey(thisSliceInfo(p).ID);

                    if codeReader.hasObject(codeKey)

                        [cObject,codeTable]=...
                        slci.results.cacheData('get',codeTable,codeReader,...
                        'getObject',codeKey);
                    else

                        cObject=slci.results.CodeObject(codeFile,lineNum);
                        codeReader.insertObject(codeKey,cObject);
                    end
                    sourceBlocks{p}=cObject;
                end
                sObject.addSourceObject(sourceBlocks);
            end
            codeSliceTable=slci.results.cacheData('update',...
            codeSliceTable,sliceKey,sObject);

        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

end


function[codeTable,codeSliceTable]=updateCodeAndCodeSliceObject(...
    inputCodeStatus,codeTable,codeSliceTable,datamgr)

    codeSliceReader=datamgr.getCodeSliceReader();
    codeReader=datamgr.getCodeReader();

    codeMap=slci.internal.ReportUtil.categorize('ID',inputCodeStatus);
    codeKeys=keys(codeMap);
    datamgr.beginTransaction();
    try
        for k=1:numel(codeKeys)

            [keyVal,codeFile,lineNum]=...
            slci.results.readEngineCodeKey(codeKeys{k});

            if codeReader.hasObject(keyVal)

                [cObject,codeTable]=...
                slci.results.cacheData('get',codeTable,codeReader,...
                'getObject',keyVal);
            else

                cObject=slci.results.CodeObject(codeFile,lineNum);
                codeReader.insertObject(cObject.getKey(),cObject);
            end

            codeInfos=codeMap(codeKeys{k});
            numCodeInfos=numel(codeInfos);
            codeFuncScopes=cell(numCodeInfos,1);
            for m=1:numCodeInfos
                thisCodeInfo=codeInfos(m);
                sliceKey=thisCodeInfo.SLICE_OP;
                status=thisCodeInfo.STATUS;
                substatus=thisCodeInfo.SUBSTATUS;


                [sObject,codeSliceTable]=...
                slci.results.cacheData('get',codeSliceTable,codeSliceReader,...
                'getObject',sliceKey);
                if~strcmpi(thisCodeInfo.FUNC,sObject.getFunctionScope())
                    DAStudio.error('Slci:results:FunctionScopeMismatch',thisCodeInfo.FUNC,...
                    keyVal,sObject.getFunctionScope(),sliceKey);
                end
                sObject.appendContributingSourceKey(keyVal);

                codeSliceTable=slci.results.cacheData('update',...
                codeSliceTable,sliceKey,sObject);


                cObject.addSubstatusForSlice(sObject,substatus);
                cObject.addStatusForSlice(sObject,status);
                codeFuncScopes{m}=thisCodeInfo.FUNC;
            end
            codeFuncScopes=unique(codeFuncScopes);
            if~isempty(cObject.getFunctionScope())
                for idx=1:numel(codeFuncScopes)
                    cObject.addFunctionScope(codeFuncScopes{idx});
                end
            else
                cObject.setFunctionScope(codeFuncScopes);
            end
            codeTable=...
            slci.results.cacheData('update',codeTable,keyVal,cObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end

