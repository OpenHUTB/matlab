function data=getDataForServicegen(modelName,bdir,buildInfo,xmlFiles)






    data=struct;



    data.buildDir=bdir;
    data.xmlFiles=xmlFiles;


    data.initializeFileName='slrealtime_fastdds_globals.h';
    data.typesFileName=dds.internal.simulink.Util.getDDSTypesHeaderFileName();
    data.modelName=modelName;
    data.typedefPairs=dds.internal.simulink.Util.getDDSTypedefPairs(data.modelName);
    data.namespaces=dds.internal.simulink.Util.getNamespaces(data.modelName);


    data.xmlFileName=dds.internal.coder.getXmlFileName(data.modelName,buildInfo);



    participantTypePairs=getParticipantTypePairs(modelName);

    data.registerTypes=[];
    for ii=1:length(participantTypePairs)
        typeName=participantTypePairs{ii}.type;
        participantName=participantTypePairs{ii}.participant;
        ddsType=dds.internal.simulink.Util.getDDSType(data.modelName,typeName);
        registerTypeRefs=ddsType.RegisterTypeRefs;
        for j=1:numel(registerTypeRefs)
            registerTypeName=registerTypeRefs(j).Name;
            if~isempty(registerTypeRefs(j).OriginalName)
                registerTypeName=registerTypeRefs(j).OriginalName;
            end
            origName=typeName;
            if~isempty(data.typedefPairs)

                origIdx=find(strcmp(typeName,{data.typedefPairs(:).destType}));
                if~isempty(origIdx)
                    origName=data.typedefPairs(origIdx).origType;
                end
            end
            typeInfo=struct('typeName',typeName,...
            'registerType',registerTypeName,...
            'origName',origName,...
            'participantName',participantName);
            if isempty(data.registerTypes)
                data.registerTypes=typeInfo;
            else
                data.registerTypes(end+1)=typeInfo;
            end
        end
    end


    data.dataReaders=unique(slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'recv',...
    'DataReaderPath'));

    data.dataWriters=unique(slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'send',...
    'DataWriterPath'));

end






function result=getReceiveParticipantTypePairs(modelName)
    types=[];
    recvParticipants=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'recv',...
    'ParticipantName');

    ddsTypes=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'recv',...
    'DDSType');

    for k=1:length(recvParticipants)
        types{end+1}.participant=recvParticipants{k};
        types{end}.type=ddsTypes{k};
    end
    result=uniqueArrElement(types);
end


function result=getSendParticipantTypePairs(modelName)
    types=[];
    sendParticipants=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'send',...
    'ParticipantName');

    ddsTypes=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'send',...
    'DDSType');

    for k=1:length(sendParticipants)
        types{end+1}.participant=sendParticipants{k};
        types{end}.type=ddsTypes{k};
    end
    result=uniqueArrElement(types);
end


function result=getParticipantTypePairs(modelName)
    result=uniqueArrElement([getSendParticipantTypePairs(modelName),...
    getReceiveParticipantTypePairs(modelName)]);
end






function result=uniqueArrElement(inputArr)
    if isempty(inputArr)
        result={};
        return;
    end
    for ii=1:length(inputArr)
        for jj=1:ii-1
            if~isempty(inputArr{jj})&&strcmp(inputArr{ii}.type,inputArr{jj}.type)&&...
                strcmp(inputArr{ii}.participant,inputArr{jj}.participant)
                inputArr{ii}={};
                break;
            end
        end
    end
    result=inputArr(~cellfun('isempty',inputArr));
end