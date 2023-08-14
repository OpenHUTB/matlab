

function codeTable=convertTypeReplacementData(...
    datamgr,...
    verification_data,...
    codeTable)



    inputTypeReplStatus=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'TYPE_REPLACEMENT'
            inputTypeReplStatus=cell_data.data;
        end
    end


    if~isempty(inputTypeReplStatus)

        engineData=slci.internal.ReportUtil.categorize('CODEGEN_ALIAS',...
        inputTypeReplStatus);


        typeReplReader=datamgr.getTypeReplacementReader();
        typeReplTable=containers.Map(...
        typeReplReader.getKeys(),...
        typeReplReader.getObjects(typeReplReader.getKeys()));
        codeReader=datamgr.getCodeReader();

        types=keys(engineData);
        for k=1:numel(types)

            type=types{k};

            if isKey(typeReplTable,type)
                typeObject=typeReplTable(type);
            else
                DAStudio.error('Slci:results:UnknownKey',type);
            end


            typeCheckResults=engineData(type);


            substatusArray=cell(1,numel(typeCheckResults));
            codeKeys=cell(1,numel(typeCheckResults));
            for p=1:numel(typeCheckResults)
                substatusArray{p}=typeCheckResults(p).STATUS;
                codeID=typeCheckResults(p).POSITION;
                if~isempty(codeID)

                    [codeKey,codeFile,lineNum]=slci.results.readEngineCodeKey(codeID);


                    codeExists=slci.results.cacheData('check',codeTable,codeReader,...
                    'hasObject',codeKey);
                    if~codeExists

                        [codeReader,codeTable]=constructCodeObject(...
                        codeFile,...
                        lineNum,...
                        codeTable,...
                        codeReader);
                    end
                    codeKeys{p}=codeKey;
                end
            end

            codeKeys=codeKeys(~cellfun('isempty',codeKeys));
            if~isempty(codeKeys)
                typeObject.addCodeKey(codeKeys);
            end


            status=slci.internal.ReportUtil.aggregateSubstatus(substatusArray);
            typeObject.setStatus(status);


            typeReplTable(type)=typeObject;
        end


        slci.results.cacheData('save',typeReplTable,datamgr,...
        typeReplReader,'replaceObject');

    end
end

function[reader,codeTable]=constructCodeObject(fileName,lineNum,...
    codeTable,reader)

    object=slci.results.CodeObject(fileName,lineNum);

    reader.insertObject(object.getKey(),object);
    codeTable(object.getKey())=object;
end
