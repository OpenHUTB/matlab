function sList=getStylesheetList(this,propName,listAction)
















    sList=cell(0,2);
    if isempty(this.StylesheetLibrary)&&nargin>2&&strcmpi(listAction,'-asynchronous')
        getStylesheetLibrary(this,listAction);
        return;
    end



    if strcmpi(propName,'-all')
        ssLib=getStylesheetLibrary(this);
        libCat=find(ssLib,...
        '-depth',1,...
        '-not','Tag','empty');

    else
        libCat=this.(['Category',propName]);
    end

    libSheets=find(libCat,...
    '-depth',1,...
    '-isa','RptgenML.StylesheetEditor');

    if isempty(libSheets)
        return;
    end

    allID=get(libSheets,'ID');
    allName=get(libSheets,'DisplayName');

    if length(libSheets)==1
        sList={allID,allName};
    else
        sList=[allID,allName];
    end


