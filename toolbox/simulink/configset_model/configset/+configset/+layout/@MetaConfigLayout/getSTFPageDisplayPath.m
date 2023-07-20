function out=getSTFPageDisplayPath(adp,pageName)
    info=adp.tlcCategory;
    page='';
    out='';
    for i=1:length(info)
        if isstruct(info{i})&&strcmp(info{i}.prompt,pageName)
            page=info{i}.prompt;
            break;
        end
    end
    if~isempty(page)
        out=[message('RTW:configSet:configSetCodeGen').getString,'/',page];
    end
