function tgtname=getName(target)










    block=target.block;


    if(strcmp(get_param(bdroot(block),'BlockDiagramType'),'library'))

        targetBlock=block;
    else

        targetBlock=get_param(block,'ReferenceBlock');
    end;


    if~isempty(targetBlock)
        load_system(strtok(targetBlock,'/'));
    else


        targetBlock=block;
    end

    blockname=get_param(targetBlock,'Name');
    tgtname=sscanf(blockname,'%s',1);
