function label=textToLabel(text)




    persistent labels
    if nargin==0
        label='';
        labels=containers.Map('KeyType','char','ValueType','int32');
        return;
    elseif isempty(labels)&&~isa(labels,'containers.Map')
        labels=containers.Map('KeyType','char','ValueType','int32');
    end


    label=regexprep(text,'\W','');


    if length(label)>20
        label(20:end)=[];
    end


    if isKey(labels,label)
        count=labels(label)+1;
        labels(label)=count;
        label=sprintf('%s%d',label,count);
    else
        labels(label)=0;
    end
end
