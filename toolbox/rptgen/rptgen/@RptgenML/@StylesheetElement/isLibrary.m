function tf=isLibrary(this)







    while~isempty(this)
        if isa(this,'RptgenML.StylesheetEditor')
            tf=false;
            return;
        elseif isa(this,'RptgenML.LibraryCategory')
            tf=true;
        end
        this=up(this);
    end

    tf=true;


