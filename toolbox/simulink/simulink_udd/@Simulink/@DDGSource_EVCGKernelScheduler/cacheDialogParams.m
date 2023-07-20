function cacheDialogParams(this)


    block=this.getBlock;
    InportBlkNames=get_param(block.Handle,'InportBlockNamesArray');
    if isempty(this.DialogData)||~isfield(this.DialogData,'StencilTable')
        intrinsicParams=block.IntrinsicDialogParameters;
        lstParams={};
        if~isempty(intrinsicParams)
            lstParams=fieldnames(intrinsicParams);
        end
        for i=1:length(lstParams)
            if strcmp(lstParams{i},'EVCGInportNeighborhood')
                continue;
            end
            this.DialogData.(lstParams{i})=block.(lstParams{i});
        end
        this.DialogData.InportBlockNamesArray=InportBlkNames;
        this.DialogData.StencilTable=updateInportBlocks(InportBlkNames,block.EVCGInportNeighborhood);

    else
        if~isequal(InportBlkNames,this.DialogData.InportBlockNamesArray)

            this.DialogData.InportBlockNamesArray=InportBlkNames;
            this.DialogData.StencilTable=updateInportBlocks(InportBlkNames,jsonencode(table2struct(this.DialogData.StencilTable)));




            block.EVCGInportNeighborhood=jsonencode(table2struct(this.DialogData.StencilTable));
        end
    end
end

function cfg=getDefaultStencilTable()
    cfg=struct('PortIdx',-1,...
    'InputPartition',"on");
end

function newTable=updateInportBlocks(blkNames,stencilTableStr)
    numInpBlks=length(blkNames);
    newTable=table();
    defaultCfg=getDefaultStencilTable();
    if isempty(stencilTableStr)
        for i=1:length(blkNames)
            row=defaultCfg;
            row.PortIdx=i-1;
            newTable(i,:)=struct2table(row);
        end
        return;
    end

    stencils=jsondecode(stencilTableStr);
    if isfield(stencils,'SID')
        stencils=rmfield(stencils,'SID');
    end
    if~isfield(stencils,'PortIdx')
        for i=1:length(stencils)
            stencils(i).PortIdx=i-1;
        end
    end

    for i=1:numInpBlks
        row=defaultCfg;
        row.PortIdx=i-1;
        for j=1:length(stencils)
            if stencils(j).PortIdx==(i-1)
                row.InputPartition=string(stencils(j).InputPartition);
                break;
            end
        end
        newTable=[newTable;struct2table(row)];
    end
end
