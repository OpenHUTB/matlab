function ret=deserializeSLProtoData(protoPath)


    [~,~,pext]=fileparts(protoPath);
    if~strcmp(pext,'.slprotodata')
        errMsg=message('ssm:actorMetadata:InvalidBehaviorInputFile',protoPath);
        error(errMsg);
    end

    fileExist=exist(protoPath,'file');
    if fileExist~=2
        errMsg=message('ssm:actorMetadata:BehaviorInputFileNotExist',protoPath);
        error(errMsg);
    end


    scenData=mathworks.scenario.common.Data;
    scenData.parseFromFile(char(protoPath));
    ret=ssm.sl_agent_metadata.ProtoToMxArray(scenData);
end
