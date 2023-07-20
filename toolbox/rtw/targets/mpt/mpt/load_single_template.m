function parsed=load_single_template(templateName)














    parsed.line=[];
    parsed.symbol.name=[];
    parsed.symbol.resolve=[];

    fid=fopen(templateName);








    if fid>0
        while 1
            lineStr=fgetl(fid);
            if~ischar(lineStr),break,end
            if isempty(regexp(lineStr,'^\s*%%'))==0
                info.symbol={''};
                info.freeFormText{1}=lineStr;
                parsed.line{end+1}=info;
            else
                parsed.line{end+1}=symbol_parse(lineStr);
            end
            for i=1:length(parsed.line{end}.symbol)
                parsed.symbol.name{end+1}=parsed.line{end}.symbol{i};
            end
        end
        fclose(fid);
    end


    parsed.symbol.name=union(parsed.symbol.name,[]);
    index=strmatch('',parsed.symbol.name,'exact');
    parsed.symbol.name=[parsed.symbol.name(1:index-1),parsed.symbol.name(index+1:end)];
