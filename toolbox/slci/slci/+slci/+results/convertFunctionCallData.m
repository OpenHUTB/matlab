



function codeTable=convertFunctionCallData(...
    datamgr,...
    verification_data,...
    codeTable)



    inputData=[];
    inputData_m=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'FUNCTION_CALL'
            inputData=cell_data.data;
        case 'MATLAB_FUNCTION_CALL'
            inputData_m=cell_data.data;
        end
    end

    codeTable=populateData(datamgr,codeTable,inputData,'FUNCTION_CALL');
    codeTable=populateData(datamgr,codeTable,inputData_m,'MATLAB_FUNCTION_CALL');
end


function codeTable=populateData(datamgr,codeTable,inputData,aKind)
    if~isempty(inputData)
        functionCallReader=datamgr.getFunctionCallReader();
        functionCallTable=containers.Map;
        codeReader=datamgr.getCodeReader();

        KEY1='C_NAME';
        KEY2='ATTRIBUTES';

        cNameMap=getFieldMap(KEY1,KEY2,inputData,'C_NAME');
        attributeMap=getFieldMap(KEY1,KEY2,inputData,'ATTRIBUTES');
        cPosMap=getFieldMap(KEY1,KEY2,inputData,'C_POSITION');
        mPosMap=getFieldMap(KEY1,KEY2,inputData,'M_POSITION');
        statusMap=getFieldMap(KEY1,KEY2,inputData,'VSTATUS');

        datakeys=keys(cNameMap);
        for k=1:numel(datakeys)
            keyVal=datakeys{k};

            blockKeys=mPosMap(keyVal);
            cPos=cPosMap(keyVal);
            cName=cNameMap(keyVal);
            attribute=attributeMap(keyVal);
            status=statusMap(keyVal);

            try

                numCPos=numel(cPos);
                codeKeys=cell(1,numCPos);
                for p=1:numel(cPos)
                    codeID=cPos{p};
                    assert(~isempty(codeID));

                    [codeKey,codeFile,lineNum]=...
                    slci.results.readEngineCodeKey(codeID);


                    codeExists=slci.results.cacheData(...
                    'check',codeTable,codeReader,...
                    'hasObject',codeKey);
                    if~codeExists

                        [codeReader,codeTable]=...
                        constructCodeObject(codeFile,...
                        lineNum,...
                        codeTable,...
                        codeReader);
                    end
                    codeKeys{p}=codeKey;
                end


                hasObj=slci.results.cacheData(...
                'check',functionCallTable,functionCallReader,...
                'hasObject',keyVal);
                assert(~hasObj,'No object should exist in functionCallTable');


                assert((numel(cName)==1)&&(numel(attribute)==1)...
                &&(numel(status)==1));
                functionCallObject=slci.results.FunctionCallObject(...
                keyVal,cName{1},attribute{1},status{1},aKind);


                functionCallReader.insertObject(...
                functionCallObject.getKey(),functionCallObject);


                codeKeys=codeKeys(~cellfun('isempty',codeKeys));
                blockKeys=blockKeys(~cellfun('isempty',blockKeys));


                if~isempty(codeKeys)
                    functionCallObject.addCodeKey(codeKeys);
                end

                if~isempty(blockKeys)
                    functionCallObject.addBlockKey(blockKeys);
                end


                functionCallTable=slci.results.cacheData('update',...
                functionCallTable,keyVal,functionCallObject);

            catch ex
                throw(ex);
            end
        end

        slci.results.cacheData('save',functionCallTable,datamgr,...
        functionCallReader,'replaceObject');

    end
end


function[reader,codeTable]=constructCodeObject(fileName,lineNum,...
    codeTable,reader)

    object=slci.results.CodeObject(fileName,lineNum);

    reader.insertObject(object.getKey(),object);
    codeTable(object.getKey())=object;
end


function map_table=getFieldMap(KEY1,KEY2,struct_array,FIELD)
    map_table=containers.Map;
    assert(isempty(struct_array)...
    ||(~isempty(struct_array)&&isfield(struct_array,KEY1)...
    &&isfield(struct_array,KEY2)));

    for i=1:numel(struct_array)
        name=struct_array(i).(KEY1);
        attr=struct_array(i).(KEY2);
        item=slci.results.FunctionCallObject.constructKey(name,attr);
        value=struct_array(i).(FIELD);

        if(isKey(map_table,item))

            map_table(item)=slci.results.union(map_table(item),value);
        else
            map_table(item)={value};
        end
    end
end
