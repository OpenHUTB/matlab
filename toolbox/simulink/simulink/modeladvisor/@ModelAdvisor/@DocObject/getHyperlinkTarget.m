function out=getHyperlinkTarget(h,xLink)




    if~iscell(xLink)
        xLink={xLink};
    end

    out=cell(length(xLink),1);

    for k=1:length(xLink)
        tagname=char(xLink{k}.getTagName);
        if~strcmp(tagname,'A')&&~strcmp(tagname,'a')
            out{k}=[];
        end
        name=char(xLink{k}.getAttribute('href'));
        if isempty(name)
            name=char(xLink{k}.getAttribute('HREF'));
        end
        if isempty(name)
            out{k}=[];
        elseif strcmp(name,'#')
            out{k}=h.XDoc;
        elseif name(1)=='#'


            out{k}=[h.getElements({'A','a'},{'NAME','name'},name(2:end));...
            h.getElements('*',{'ID','id'},name(2:end))];
        else

            out{k}=name;
        end
    end
