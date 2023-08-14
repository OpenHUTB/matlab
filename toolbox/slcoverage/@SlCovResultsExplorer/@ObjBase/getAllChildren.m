function srcC=getAllChildren(this)





    srcC(1:0)=handle([]);
    srcC=srcC';

    srcCat=this.down;
    while~isempty(srcCat)

        if~isempty(srcCat)
            catChildren=getChildren(srcCat);
            srcC=[srcC;srcCat;catChildren(:)];
        else
            srcC(end+1,1)=srcCat;
        end
        srcCat=srcCat.right;
    end


