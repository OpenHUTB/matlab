function checksum=computeModelParameterChecksum(this,input)








    if isa(input,'Simulink.BlockDiagram')||...
        ((numel(input)==1||ischar(input))...
        &&strcmp(get_param(input,'Type'),'block_diagram'))




        blocks=this.getBlocksToSnapshot(input);
    else



        blocks=input;
    end

    blockChecksum=zeros(1,numel(blocks));

    for idx=1:numel(blocks)
        blockObject=get_param(blocks(idx),'Object');
        blockChecksum(idx)=this.computeBlockParameterChecksum(blockObject);
    end

    checksum=pm_hash('crc',sort(blockChecksum));





