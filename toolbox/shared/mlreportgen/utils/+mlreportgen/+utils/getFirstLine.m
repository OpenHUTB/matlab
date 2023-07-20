function objectName=getFirstLine(objectName)




    crIdx=find(objectName==newline);
    if~isempty(crIdx)
        if(crIdx(1)==length(objectName))
            objectName=objectName(1:crIdx(1)-1);
        else
            objectName=[objectName(1:crIdx(1)-1),'...'];
        end
    end
    objectName=truncateString(objectName,'',32);
end


function s=truncateString(s,emptyMsg,sLen)












    s=makeSingleLineText(s,' ');

    if nargin<3
        sLen=24;
    end

    if length(s)>sLen
        s=[s(1:sLen-3),'...'];
    elseif isempty(s)&&nargin>1
        s=emptyMsg;
    end
end

function out=makeSingleLineText(in,delim)












    if isempty(in)
        out='';
    else
        if nargin<2
            delim=' ';
        end

        if iscellstr(in)
            in=in(:);
            [sp{1:size(in,1),1}]=deal(delim);
            sp{end}='';
            in=[in,sp]';
            out=[in{:}];
        elseif ischar(in)
            if size(in,1)>1
                out=makeSingleLineText(cellstr(in),delim);
            else
                out=in;
            end
        elseif isnumeric(in)
            out=makeSingleLineText(num2str(in),delim);
        else
            out='';
        end

        out=strrep(out,newline,delim);
    end
end