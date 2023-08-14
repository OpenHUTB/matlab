function is=isblocklibrary(block)








    if ischar(block),
        block=get_param(block,'Object');
    else
        block=get(block,'Object');
    end
    is=strcmp(get_param(strtok(block.Path,'/'),'BlockDiagramType'),'library');