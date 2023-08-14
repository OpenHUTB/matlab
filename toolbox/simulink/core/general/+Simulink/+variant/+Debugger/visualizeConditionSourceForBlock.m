function visualizeConditionSourceForBlock(infoFilePath,blkPath)





    info=load(infoFilePath);
    blkSourcesOfConditions=info.blkSourcesOfConditions;

    for blkIdx=1:size(blkSourcesOfConditions,2)
        if(strcmp(blkPath,blkSourcesOfConditions(blkIdx).Block))

            hilite_system(blkSourcesOfConditions(blkIdx).Block);


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
            end
        end
    end

end
