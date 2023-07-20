
function prepareCodeObjects(verification_data,datamgr,mfModel)
    assert(nargin==2||nargin==3);




    isResultsMF=(nargin==3);

    if isResultsMF
        filesToTrace=verification_data.data;

        codeReader=datamgr;
    else

        codeReader=datamgr.getCodeReader();


        inspectedCodeFiles=datamgr.getMetaData('InspectedCodeFiles');
        filesToTrace=inspectedCodeFiles.filesToTrace;

        subsystemFiles=[];
        for k=1:numel(verification_data)
            cell_data=verification_data{k};
            switch(cell_data.name)
            case 'SUBSYSTEM_FILES'
                subsystemFiles=cell_data.data;
            end
        end

        for k=1:numel(subsystemFiles)
            fileName=subsystemFiles(k).FILENAME;
            filesToTrace{end+1}=...
            slci.results.normalizeFilePath(fileName);%#ok
        end

        inspectedCodeFiles.filesToTrace=filesToTrace;

        datamgr.beginTransaction();
    end
    try
        if~isResultsMF
            datamgr.setMetaData('InspectedCodeFiles',inspectedCodeFiles);
        end
        numFilesToTrace=numel(filesToTrace);
        for numFiles=1:numFilesToTrace
            if isResultsMF
                fullFileName=filesToTrace.at(numFiles);
            else
                fullFileName=filesToTrace{numFiles};
            end
            fullFileName=slci.internal.ReportUtil.convertRelativeToAbsolute(fullFileName);
            codeLocations=slci.internal.ReportUtil.parseCode(fullFileName);



            num_of_rows=size(codeLocations,1);
            for k=1:num_of_rows
                lineNum=codeLocations{k,1};
                codeStr=codeLocations{k,2};
                if isResultsMF
                    cObject=slci_results_mf.CodeObject(mfModel);
                    cObject.initializeCodeObject(fullFileName,...
                    lineNum);
                else
                    cObject=slci.results.CodeObject(fullFileName,...
                    lineNum);
                end
                populateSubstatus(cObject,codeStr);
                if isResultsMF
                    cObject.codeStr=codeStr;

                    codeReader.insertObject(cObject);
                else
                    cObject.setCodeString(codeStr);

                    codeReader.insertObject(cObject.getKey(),cObject);
                end
            end
        end
        if~isResultsMF
            datamgr.commitTransaction();
        end
    catch ex
        if~isResultsMF
            datamgr.rollbackTransaction();
        end
        throw(ex);
    end


end

function populateSubstatus(cObject,codeStr)


    if(codeStr==-1)|slci.internal.ReportUtil.isEmpty(codeStr)%#ok<OR2>
        cObject.addPrimTraceSubstatus('EMPTY_LINE');
        cObject.addPrimVerSubstatus('EMPTY_LINE');
    elseif slci.internal.ReportUtil.isComment(codeStr)
        cObject.addPrimTraceSubstatus('COMMENT');
        cObject.addPrimVerSubstatus('COMMENT');
    elseif slci.internal.ReportUtil.isIncludes(codeStr)
        cObject.addPrimTraceSubstatus('INCLUDE');
        cObject.addPrimVerSubstatus('INCLUDE');
    elseif slci.internal.ReportUtil.isPreprocessor(codeStr)
        cObject.addPrimTraceSubstatus('PREPROCESSOR');
        cObject.addPrimVerSubstatus('PREPROCESSOR');
    elseif slci.internal.ReportUtil.isKeyword(codeStr)
        cObject.addPrimTraceSubstatus('KEYWORD');
        cObject.addPrimVerSubstatus('KEYWORD');
    elseif slci.internal.ReportUtil.isOpenBraces(codeStr)
        cObject.addPrimTraceSubstatus('OPEN_BRACKET');
        cObject.addPrimVerSubstatus('OPEN_BRACKET');
    elseif slci.internal.ReportUtil.isCloseBraces(codeStr)
        cObject.addPrimTraceSubstatus('CLOSE_BRACKET');
        cObject.addPrimVerSubstatus('CLOSE_BRACKET');
    elseif slci.internal.ReportUtil.isSemiColon(codeStr)
        cObject.addPrimTraceSubstatus('SEMICOLON');
        cObject.addPrimVerSubstatus('SEMICOLON');
    end
end
