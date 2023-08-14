function createAccessorBlockForOwner(block,accessInfo)
    currentSystem=get_param(block,'parent');
    blkPrefix='';
    blkType='';
    ownerSpec='StateOwnerBlock';
    ownerPropertySpec='StateName';
    switch accessInfo.type
    case 'StateReader'
        blkPrefix='State Reader';
        blkType='StateReader';
    case 'StateWriter'
        blkPrefix='State Writer';
        blkType='StateWriter';
    case 'ParameterWriter'
        blkPrefix='Parameter Writer';
        blkType='ParameterWriter';
        ownerSpec='ParameterOwnerBlock';
        ownerPropertySpec='ParameterName';
    otherwise
        assert(false,'In-valid accessor type. Supported accessor types are State Reader, State Writer, and Parameter Writer.');
    end

    blockToAdd=[currentSystem,'/',blkPrefix];
    actBlkAdded=add_block(['built-in/',blkType],blockToAdd,'MakeNameUnique','on');
    set_param(actBlkAdded,ownerSpec,block);

    SLStudio.toolstrip.internal.configureAccessorBlock(actBlkAdded,block,accessInfo.fontsize);


    if~isempty(accessInfo.name)
        if~strcmp(accessInfo.name,'<default>')
            set_param(actBlkAdded,ownerPropertySpec,accessInfo.name);
        end
    else


        open_system(actBlkAdded);
    end
end