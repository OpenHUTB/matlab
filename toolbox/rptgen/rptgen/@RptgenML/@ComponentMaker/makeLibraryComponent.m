function libComp=makeLibraryComponent(this)




    r=RptgenML.Root;
    if isempty(r.Library)


        libComp=[];
        return;
    end

    clsName=[this.PkgName,'.',this.ClassName];

    libComp=find(r.Library,...
    '-isa','RptgenML.LibraryComponent',...
    'ClassName',clsName);
    if~isempty(libComp)
        delete(libComp);
    end



    libComp=RptgenML.LibraryComponent(clsName,this.DisplayName);




    libCat=find(r.Library,...
    '-depth',1,...
    '-isa','RptgenML.LibraryCategory',...
    'CategoryName',this.Type);

    if isempty(libCat)
        libCat=RptgenML.LibraryCategory(this.Type);
        firstCat=down(r.Library);
        if isempty(firstCat)
            connect(libCat,r.Library,'up');
        else

            connect(libCat,firstCat,'right');
        end
    end

    connect(libComp,libCat,'up');




    function locClearClasses


        clear classes;
