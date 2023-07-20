function out=getCode(h,sid)



    out=[];
    locations=h.getCodeLocations(sid);
    if isempty(locations)
        return;
    end
    for i=1:length(locations)
        file=locations(i).file;
        line=locations(i).line;
        code=h.getCodeFromFile(file,line);
        out=[out,code];%#ok<*AGROW>
    end
