function validateAndUpdateDDSDefinitions(blk,blkType)









    modelName=bdroot(blk);
    if(strcmp(get_param(modelName,'BlockDiagramType'),'library'))
        return;
    end


    if~dig.isProductInstalled('DDS Blockset')
        error(message('slrealtime:dds:needDDSBlockset'));
    end
    fullpathToUtility=which('dds.internal.isInstalledAndLicensed');
    if~isempty(fullpathToUtility)

        [value,~]=dds.internal.isInstalledAndLicensed();
        if~value



            error(message('dds:toolstrip:NotLicensed'));
        end
    else

        return;
    end


    dd=get_param(bdroot(blk),'DataDictionary');
    if isempty(dd)
        error(message('slrealtime:dds:requiredDataDictionary',blk));
    end

    try

        ddConn=Simulink.data.dictionary.open(dd);
        if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
            error(message('slrealtime:dds:noDDSinDD',dd));
        end
    catch ex
        error(message('slrealtime:dds:invalidDD',ex.message));
    end


    switch(blkType)
    case 'send'
        isReader=false;
    case 'recv'
        isReader=true;
    otherwise
        assert(false);
    end


    topicPath=get_param(blk,'topic');
    qosPath=get_param(blk,'qos');
    if strcmp(qosPath,'Default')
        qosPath='';
    end
    if isempty(topicPath)
        error(message('slrealtime:dds:requiredTopicXMLPath',blk));
    else
        topic=dds.internal.simulink.Util.getTopic(modelName,topicPath);
        qos=dds.internal.simulink.Util.getQoS(modelName,qosPath,isReader);
        if isempty(topic)
            if isempty(qos)&&~isempty(qosPath)

                error(message('slrealtime:dds:qoSAndTopicNotExist',topicPath,qosPath));
            else
                error(message('slrealtime:dds:topicNotExist',topicPath));
            end
        elseif isempty(qos)&&~isempty(qosPath)
            error(message('slrealtime:dds:qoSNotExist',qosPath));
        end
    end



    if isReader
        slrealtime.internal.dds.ui.ReceiveBlockMask.dispatch('updateDDSDefinitions',blk);
    else
        slrealtime.internal.dds.ui.SendBlockMask.dispatch('updateDDSDefinitions',blk);
    end

end