function out=getElements(h,tag,attrib,pattern)




    if nargin>1
        tag=convertStringsToChars(tag);
    end

    if nargin>2
        attrib=convertStringsToChars(attrib);
    end

    if nargin>3
        pattern=convertStringsToChars(pattern);
    end

    if nargin<=1
        tag={'*'};
    end
    if~iscell(tag)
        tag={tag};
    end


    if nargin<=2
        attrib=[];
    elseif~iscell(attrib)
        attrib={attrib};
    end

    if nargin<=3
        pattern='';
    end

    out={};
    for k=1:length(tag)
        xObjs=h.XDoc.getElementsByTagName(tag{k});
        for n=1:xObjs.getLength
            if isempty(attrib)
                out{end+1,1}=xObjs.item(n-1);%#ok<AGROW>
            else
                for m=1:length(attrib)
                    attr=char(xObjs.item(n-1).getAttribute(attrib{m}));
                    if isempty(attr)


                        continue
                    end
                    if isempty(pattern)
                        match=true;
                    elseif iscell(pattern)
                        match=~isempty(strmatch(attr,pattern,'exact'));
                    else
                        match=any(strcmp(regexp(attr,pattern,'match'),attr));
                    end
                    if match
                        out{end+1,1}=xObjs.item(n-1);%#ok<AGROW>
                        break;
                    end
                end
            end
        end
    end