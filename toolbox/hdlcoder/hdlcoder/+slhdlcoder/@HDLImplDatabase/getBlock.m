function value=getBlock(this,slBlockPath)



    tag=hdllegalizefieldname(slBlockPath);
    try
        value=this.BlockDB(tag);
    catch
        value=[];
    end
end
