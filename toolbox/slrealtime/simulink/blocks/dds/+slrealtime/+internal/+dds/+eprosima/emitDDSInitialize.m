function generatedFile=emitDDSInitialize(data)










    generatedFile=fullfile(data.buildDir,data.initializeFileName);
    writer=rtw.connectivity.CodeWriter.create(...
    'callCBeautifier',true,...
    'filename',generatedFile,...
    'append',false);


    writer.wComment('register dds types');








    declaredTypes=[];

    for ii=1:length(data.registerTypes)
        type=data.registerTypes(ii).origName;
        typeName=data.registerTypes(ii).typeName;
        if~any(strcmp(declaredTypes,type))
            writer.wLine('%sPubSubType g_%sPubSubType;',type,typeName);
            declaredTypes{end+1}=type;
        end
    end


    writer.wLine('bool registerTypes() {');
    writer.wLine('bool status = true;');
    writer.wLine('Participant* participant;');

    for ii=1:length(data.registerTypes)
        pair=data.registerTypes(ii);
        writer.wLine('participant = getOrCreateParticipant("%s");',pair.participantName);
        writer.wLine('status = Domain::registerType(participant, &g_%sPubSubType);',pair.typeName);
        writer.wBlockStart('if(!status)');
        writer.wLine('exit (-1);');
        writer.wBlockEnd();
    end
    writer.newLine();

    writer.wLine('return status;}');

    writer.wLine('bool slrealtime_dds_initialize() {');
    writer.wLine('static bool isInitDone = false;');

    writer.wBlockStart('if(!isInitDone)');

    writer.wComment('load DDS Profiles;');
    writer.wLine('Domain::loadXMLProfilesFile("dds/%s");',data.xmlFileName);

    writer.wLine('registerTypes();');



    writer.wComment('create Publishers');


    for k=1:length(data.dataWriters)
        dataWriterPath=data.dataWriters{k};
        [participantLib,participant,publisher,dataWriter]=slrealtime.internal.dds.utils.getDDSMapping(...
        dataWriterPath);
        writer.wLine('isInitDone = createPublisher("%s", "%s");',...
        [participantLib,'_',participant],[publisher,'_',dataWriter]);
    end


    writer.wComment('create Subscribers');

    for k=1:length(data.dataReaders)
        dataReaderPath=data.dataReaders{k};
        [participantLib,participant,subscriber,dataReader]=slrealtime.internal.dds.utils.getDDSMapping(...
        dataReaderPath);
        writer.wLine('isInitDone = createSubscriber("%s", "%s");',...
        [participantLib,'_',participant],[subscriber,'_',dataReader]);
    end

    writer.wBlockEnd();
    writer.wLine('return isInitDone;}');

    writer.close();

end
