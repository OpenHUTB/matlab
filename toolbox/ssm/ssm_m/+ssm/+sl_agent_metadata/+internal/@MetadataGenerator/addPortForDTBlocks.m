function addPortForDTBlocks(zcModel,dtBlks)







    rootArch=zcModel.Architecture;


    systemcomposer.profile.Profile.closeAll;
    dtProfile='DataTableProfile';
    profile=systemcomposer.profile.Profile.find(dtProfile);


    dtMap=ssm.sl_agent_metadata.internal.MetadataGenerator.getDatatableAttributes();

    if isempty(profile)
        profile=systemcomposer.profile.Profile.createProfile(dtProfile);
        ssm.sl_agent_metadata.internal.MetadataGenerator.addDTStereotypeToProfile(profile,dtMap);
    end
    zcModel.applyProfile(dtProfile);


    for idx=1:length(dtBlks)
        blk=dtBlks{idx};
        if strcmp(blk.BlockType,'DataTableReader')
            port=rootArch.addPort(blk.BlockPath,'out');
        else
            continue
        end


        itrf=zcModel.InterfaceDictionary.getInterface(blk.BlockTopicName);
        port.setInterface(itrf);


        applyStereotype(port,[dtProfile,'.',blk.BlockType]);


        fids=fields(blk);
        for idf=1:length(fids)
            dtBlockMap=dtMap.(blk.BlockType);
            dtProp=fids{idf};
            if~isfield(dtBlockMap,dtProp)
                continue
            end
            portProp=dtBlockMap.(dtProp);


            setProperty(port,[dtProfile,'.',blk.BlockType,'.',portProp],...
            ['''',blk.(dtProp),'''']);
        end
    end
end
