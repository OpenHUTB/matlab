function libC=listLibraryComponents(this)










    if isempty(this.Library)
        showLibrary(this);
        libC=getChildren(this.Library);

    elseif isa(this.Library,'RptgenML.Message')
        libC=this.Library;

    else
        libC=getChildren(this.Library);

    end

