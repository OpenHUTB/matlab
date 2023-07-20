function configureMessageData(bdName,blkPath,busObjName)

    try
        rt=sfroot;
        machine=rt.find('-isa','Stateflow.Machine','Name',bdName);
        blk=machine.find('-isa','Stateflow.Chart','Path',blkPath);

        data=blk.find('-isa','Stateflow.Data');

        for i=1:length(data)
            data(i).DataType=['Bus: ',busObjName];
        end

        msg=blk.find('-isa','Stateflow.Message');
        for i=1:length(msg)
            msg(i).DataType=['Bus: ',busObjName];
        end

    catch ME
        Simulink.harness.internal.warn(ME);
    end

end
