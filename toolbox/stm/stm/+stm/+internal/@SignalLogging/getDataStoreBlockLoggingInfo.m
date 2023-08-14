function[dStoreName,dsmSrcType,blkPathArray]=getDataStoreBlockLoggingInfo(blkPathArray)







    modelToUse=extractBefore(blkPathArray{end},'/');
    load_system(modelToUse);


    dStoreName=get_param(blkPathArray{end},'DataStoreName');


    dsmSrcType='block';
    if~strcmp(get_param(blkPathArray{end},'BlockType'),'DataStoreMemory')

        dsmHdl=BindMode.utils.getDataStoreHandleFromReadWriteBlock(get_param(blkPathArray{end},'Handle'));
        if~isempty(dsmHdl)


            blkPathArray{end}=getfullname(dsmHdl);
        else

            sigObjVar=Simulink.findVars(modelToUse,'Name',dStoreName,...
            'Users',blkPathArray{end});


            if strcmp(sigObjVar.SourceType,'data dictionary')
                dsmSrcType=sigObjVar.Source;
            else
                dsmSrcType=sigObjVar.SourceType;
            end
        end
    end
end
