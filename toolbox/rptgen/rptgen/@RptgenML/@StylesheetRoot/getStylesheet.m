function ss=getStylesheet(this,tt,id)














    ss=[];
    if isempty(this.StylesheetLibrary)
        return;
    end

    libCat=this.(['Category',tt]);

    libSheets=find(libCat,...
    '-depth',1,...
    '-isa','RptgenML.StylesheetEditor');

    for i=1:length(libSheets)
        if strcmp(libSheets(i).ID,id)
            ss=libSheets(i);
            break;
        end
    end

    return;

end