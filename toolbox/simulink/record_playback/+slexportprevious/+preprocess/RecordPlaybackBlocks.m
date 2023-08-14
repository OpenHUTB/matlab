function RecordPlaybackBlocks(obj)





    if obj.ver.isReleaseOrEarlier('R2021a')
        locReplaceXYGraphs(obj);
    end


    if isR2020bOrEarlier(obj.ver)
        obj.removeBlocksOfType('Record');
    end


    if isR2022aOrEarlier(obj.ver)
        obj.removeBlocksOfType('Playback');
    end
end


function locReplaceXYGraphs(obj)


    obj.appendRule('<Block<SourceBlock|"record_playback_blocks/XY Graph (legacy)":repval "simulink/Sinks/XY Graph">>');


    blks=locGetXYRecordBlocks(obj);
    if isempty(blks)
        return
    end


    mdl='record_playback_blocks';
    load_system(mdl);
    tmp=onCleanup(@()close_system(mdl,0));
    newBlockType=[mdl,'/XY Graph (legacy)'];


    for idx=1:numel(blks)
        hOldBlock=get_param(blks{idx},'Handle');
        slInternal('replace_block',hOldBlock,newBlockType);
    end
end


function ret=locGetXYRecordBlocks(obj)
    ret={};
    b=obj.findBlocksOfType('Record');
    for idx=1:numel(b)
        bt=get_param(b{idx},'CompatibilityTag');
        if strcmpi(bt,'XY')&&get_param(b{idx},'NumPorts')==2
            ret{end+1}=b{idx};%#ok<AGROW>
        end
    end
end
