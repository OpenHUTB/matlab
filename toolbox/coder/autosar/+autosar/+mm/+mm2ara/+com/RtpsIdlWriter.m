function RtpsIdlWriter(EventList,intfName,filePath,suffix)





    persistent structMap;
    if isempty(structMap)||~isfile(filePath)
        structMap=containers.Map;
    end



    persistent interfaceToEventsMap;
    if isempty(interfaceToEventsMap)||~isfile(filePath)
        interfaceToEventsMap=containers.Map;
    end

    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
    true,'filename',filePath,'append',true);
    prefix=[intfName,'_'];


    unprocessedEventsList=getUnprocessedEvents(EventList,intfName,interfaceToEventsMap);




    if numel(unprocessedEventsList)>0
        codeWriter.wBlockStart('module eprosima_dds');

        for ii=1:length(unprocessedEventsList)
            m3iEvnt=unprocessedEventsList{ii};
            if isempty(m3iEvnt.Type)
                continue;
            end

            eventName=m3iEvnt.Name;
            eventType=m3iEvnt.Type;

            if isKey(interfaceToEventsMap,intfName)
                values=interfaceToEventsMap(intfName);
                values{end+1}=m3iEvnt;
                interfaceToEventsMap(intfName)=values;
            else
                interfaceToEventsMap(intfName)={m3iEvnt};
            end

            structMap=processEvent(codeWriter,structMap,eventName,eventType,prefix,suffix);
        end

        codeWriter.wBlockEnd();
        codeWriter.wLine(';');
    end
end

function structMap=processEvent(codeWriter,structMap,eventName,eventDataType,prefix,suffix)

    if isa(eventDataType,'Simulink.metamodel.types.Structure')

        [idlType,structMap]=handleStruct(codeWriter,structMap,eventDataType,suffix);
        elemName=['m_',idlType];
        matrixExt='';
    elseif isa(eventDataType,'Simulink.metamodel.types.Matrix')

        [structMap,idlType,matrixExt]=handleMatrix(codeWriter,structMap,eventDataType,suffix);
        elemName=['m_',eventDataType.Name];
    else

        [~,~,idlType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataType);
        elemName=['m_',eventDataType.Name];
        matrixExt='';
    end
    writeEvntToIdlFile(codeWriter,eventName,idlType,elemName,matrixExt,prefix,suffix);
end

function[structMap,matrixType,matrixExt]=handleMatrix(codeWriter,structMap,eventDataType,suffix)

    eventDataBaseType=eventDataType.BaseType;
    matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType));

    if isa(eventDataBaseType,'Simulink.metamodel.types.Structure')

        [matrixType,structMap]=handleStruct(codeWriter,structMap,eventDataBaseType,suffix);
        matrixExt=['[',matDim,']'];
    elseif isa(eventDataBaseType,'Simulink.metamodel.types.Matrix')
        [structMap,matrixType,matrixExtTemp]=handleMatrix(codeWriter,structMap,eventDataBaseType,suffix);
        matrixExt=[matrixExtTemp,'[',matDim,']'];
    else

        [~,~,matrixType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataBaseType);
        matrixExt=['[',matDim,']'];
    end
end

function[structType,structMap]=handleStruct(codeWriter,structMap,eventDataType,suffix)
    structType=[autosar.mm.mm2ara.TypeWriter.getUsingTypeName(eventDataType),suffix];

    if~isKey(structMap,structType)
        elemSize=eventDataType.Elements.size();
        elemNameList=cell(1,elemSize);
        elemTypeList=cell(1,elemSize);

        for ii=1:elemSize
            curTypElem=eventDataType.Elements.at(ii);


            if curTypElem.Type.isvalid()
                curTypElemType=curTypElem.Type;
            else
                curTypElemType=curTypElem.ReferencedType;
            end

            idlType='';
            elemName=curTypElem.Name;
            matrixExtension='';

            if isa(curTypElemType,'Simulink.metamodel.types.Structure')
                [idlType,structMap]=handleStruct(codeWriter,structMap,curTypElemType,suffix);
            elseif isa(curTypElemType,'Simulink.metamodel.types.Matrix')
                [structMap,idlType,matrixExtension]=handleMatrix(codeWriter,structMap,curTypElemType,suffix);
            elseif isa(curTypElemType,'Simulink.metamodel.types.Integer')||...
                isa(curTypElemType,'Simulink.metamodel.types.FixedPoint')||...
                isa(curTypElemType,'Simulink.metamodel.types.Enumeration')||...
                isa(curTypElemType,'Simulink.metamodel.types.FloatingPoint')||...
                isa(curTypElemType,'Simulink.metamodel.types.Boolean')
                [~,~,idlType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(curTypElemType);
            else
            end

            elemTypeList{ii}=idlType;
            elemNameList{ii}=[elemName,matrixExtension];
        end

        writeStructToIdlFile(codeWriter,structType,elemTypeList,elemNameList);
        structMap(structType)=1;
    end
end

function writeEvntToIdlFile(codeWriter,eventName,idlType,elemName,matrixExtn,prefix,suffix)
    codeWriter.wBlockStart(['struct ',prefix,eventName,suffix]);
    codeWriter.wLine([idlType,' ',elemName,matrixExtn,';']);
    codeWriter.wBlockEnd();
    codeWriter.wLine(';');
end

function writeStructToIdlFile(codeWriter,structName,elemTypeList,elemNameList)
    codeWriter.wBlockStart(['struct ',structName]);
    for ii=1:numel(elemTypeList)
        codeWriter.wLine([elemTypeList{ii},' ',elemNameList{ii},';']);
    end
    codeWriter.wBlockEnd();
    codeWriter.wLine(';');
end

function unprocessedEventsList=getUnprocessedEvents(EventList,intfName,interfaceToEventsMap)
    unprocessedEventsList={};
    if~isKey(interfaceToEventsMap,intfName)
        unprocessedEventsList=EventList;
        return;
    end
    processedEvents=values(interfaceToEventsMap,{intfName});
    processedEvents=processedEvents{1};
    for ii=1:numel(EventList)
        processed=false;
        for jj=1:numel(processedEvents)
            if isequal(EventList{ii},processedEvents{jj})
                processed=true;
                break;
            end
        end
        if~processed
            unprocessedEventsList{end+1}=EventList{ii};
        end
    end
end


