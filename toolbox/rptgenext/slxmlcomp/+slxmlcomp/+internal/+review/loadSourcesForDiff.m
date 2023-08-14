function loadSourcesForDiff(sources)


    cell_sources=sources.toArray.cell;

    for loadIndex=1:numel(cell_sources)
        jSrc=cell_sources{loadIndex};
        jFile=jSrc.getModelData().getFileToUseInMemory();

        load_system(char(jFile.getPath()));

        [~,name,~]=fileparts(char(jFile.getPath()));
    end

end

