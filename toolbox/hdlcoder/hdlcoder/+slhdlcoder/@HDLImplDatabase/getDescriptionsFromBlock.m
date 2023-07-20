function desc=getDescriptionsFromBlock(this,slBlockPath)












    desc={};
    blk=this.getBlock(slBlockPath);
    if~isempty(blk)
        impls=blk.Implementations;
        desc=cell(length(impls),1);
        for ii=1:length(impls)
            implName=impls{ii};
            desc{ii}=this.getDescription(implName);
        end
    end

