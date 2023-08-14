function out=deduplicate(in)




    persistent tempMap

    if nargin<1
        tempMap=containers.Map('KeyType','char','ValueType','int32');
    else
        if isempty(in)
            in='<?>';
        end
        if isKey(tempMap,in)
            tempMap(in)=tempMap(in)+1;
            out=sprintf('%s_%d',in,tempMap(in));
        else
            tempMap(in)=0;
            out=in;
        end
    end
end

