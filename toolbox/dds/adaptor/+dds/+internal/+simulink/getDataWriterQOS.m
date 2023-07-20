function dataWriterQOS=getDataWriterQOS(modelName)






    dataWriterQOS={};
    dd=get_param(modelName,'DataDictionary');
    if isempty(dd)
        return;
    end

    ddConn=Simulink.data.dictionary.open(dd);
    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
        return;
    end

    ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);
    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    qosLibraries=systemInModel(1).QosLibraries;
    qosLibKeys=keys(qosLibraries);
    for ii=1:numel(qosLibKeys)
        qosLib=qosLibraries{qosLibKeys{ii}};
        qosProfiles=qosLib.QosProfiles;
        profileKeys=keys(qosProfiles);

        for jj=1:numel(profileKeys)
            qosProfile=qosProfiles{profileKeys{jj}};
            dataWriterQoses=qosProfile.DataWriterQoses;
            dataWriterQosKeys=keys(dataWriterQoses);
            for kk=1:numel(dataWriterQosKeys)
                qos=dataWriterQoses{dataWriterQosKeys{kk}};
                dataWriterQOS{end+1}=[qosLib.Name,'/',qosProfile.Name,'/',qos.Name];
            end
        end


        dataWriterQoses=qosLib.DataWriterQoses;
        dataWriterQosKeys=keys(dataWriterQoses);
        for jj=1:numel(dataWriterQosKeys)
            qos=dataWriterQoses{dataWriterQosKeys{jj}};
            dataWriterQOS{end+1}=[qosLib.Name,'/',qos.Name];
        end
    end
end

