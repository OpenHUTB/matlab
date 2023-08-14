

function res=extractCode(blockInfo)


    lines=split(string(fileread(blockInfo.File.Path)),newline);
    body=lines(blockInfo.StartLine:blockInfo.EndLine);
    if(blockInfo.StartCol>0)&&(blockInfo.StartCol<strlength(body(1))-1)
        body(1)=body(1).extractAfter(blockInfo.StartCol+1);
    end
    if(blockInfo.EndCol>0)&&(blockInfo.EndCol<strlength(body(end))-1)
        body(end)=body(end).extractBefore(blockInfo.EndCol+2);
    end
    res=body.join(newline);
end

