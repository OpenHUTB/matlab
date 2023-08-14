function visualizeConditionSources(infoFilePath)





    info=load(infoFilePath);
    blkSourcesOfConditions=info.blkSourcesOfConditions;

    pauseTime=3;

    for blkIdx=1:size(blkSourcesOfConditions,2)
        blkPaths={};
        hilite_system(blkSourcesOfConditions(blkIdx).Block);
        blkPaths{end+1}=blkSourcesOfConditions(blkIdx).Block;

        sources=blkSourcesOfConditions(blkIdx).Sources;
        for srcIdx=1:size(sources,2)
            srcPh=get_param(sources(srcIdx).SourceBlock,'PortHandles');
            if sources(srcIdx).IsInportSide
                ph=srcPh.Inport(sources(srcIdx).PortNumber+1);
            else
                ph=srcPh.Outport(sources(srcIdx).PortNumber+1);
            end
            hilite_system(ph,'find');
            hilite_system(sources(srcIdx).SourceBlock,'find');
            blkPaths{end+1}=ph;
            blkPaths{end+1}=sources(srcIdx).SourceBlock;
        end

        pause(pauseTime);





        delim='/';
        blkPath=strsplit(blkSourcesOfConditions(blkIdx).Block,delim);

        set_param(blkPath{1},'HiliteAncestors','none');

        pause(pauseTime/2);
    end
end