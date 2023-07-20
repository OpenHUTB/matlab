function[lineMap,lineStarts]=createLineMap(text,shrink)








    lineMap=[1,cumsum(text==10)+1];
    lineMap(end+1)=lineMap(end);
    lineStarts=[1,find(diff(lineMap))+1];

    if nargin==1||shrink
        textLen=length(text);
        if textLen<=4294967296
            if textLen>65536
                lmClass='uint32';
            elseif textLen>256
                lmClass='uint16';
            else
                lmClass='uint8';
            end
            lineMap=cast(lineMap,lmClass);
        end
    end
end
