function node=getBdOrTopMdlRefNode(this)






    if~isempty(this.hMdlRefBlock)
        node=this.hMdlRefBlock.getBdOrTopMdlRefNode();


    elseif isa(this,'SigLogSelector.MdlRefNode')
        node=this;


    else
        me=SigLogSelector.getExplorer;
        node=me.getRoot;
    end

end
