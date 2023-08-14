function libC=getChildren(this)




    libC=[];

    libCat=this.down;
    while~isempty(libCat)
        if isa(libCat,'RptgenML.LibraryCategory')
            if libCat.Visible&&~isempty(libCat.down)
                if(libCat.Expanded)
                    catChildren=getChildren(libCat);
                    libC=[libC;libCat;catChildren(:)];
                else
                    libC=[libC;libCat];
                end
            end
        else

            libC=[libC;libCat];
        end
        libCat=libCat.right;
    end



