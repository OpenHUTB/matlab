function exploreAction(this)






    c=getCurrentComponent(RptgenML.Root);
    if~isempty(c)
        acceptDrop(c,this);
    end




