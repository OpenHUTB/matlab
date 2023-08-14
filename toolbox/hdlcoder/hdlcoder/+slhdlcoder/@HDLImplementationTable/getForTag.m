function value=getForTag(this,slBlockPath)



    tag=hdllegalizefieldname(slBlockPath);
    try
        value=this.Sets(tag);
    catch
        value=[];
    end
end
