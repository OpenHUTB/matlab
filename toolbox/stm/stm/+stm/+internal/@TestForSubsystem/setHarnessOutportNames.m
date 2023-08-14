function setHarnessOutportNames(obj,harnessName)



















    dsrBlks=find_system(harnessName,'SearchDepth','1','BlockType','DataStoreRead');
    for blk=dsrBlks'
        pHdl=get_param(blk{1},'PortHandles');
        set_param(pHdl.Outport,'DataLogging','on');
        set_param(pHdl.Outport,'DataLoggingName',get_param(blk{1},'DataStoreName'));
        set_param(pHdl.Outport,'DataLoggingNameMode','Custom');
    end
end