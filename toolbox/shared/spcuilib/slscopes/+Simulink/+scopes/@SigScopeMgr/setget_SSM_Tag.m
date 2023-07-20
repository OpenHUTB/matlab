function out=setget_SSM_Tag(tagKey,varargin)
    persistent Tag

    if nargin&&~isempty(tagKey)
        if nargin>1
            if~isa(Tag,'containers.Map')
                Tag=containers.Map('KeyType','char','ValueType','any');
            end
            newTag.DDGTag=varargin{1};
            if nargin>2
                newTag.ComponentTag=varargin{2};
            elseif~isempty(Tag(tagKey).ComponentTag)
                newTag.ComponentTag=Tag(tagKey).ComponentTag;
            else
                newTag.ComponentTag=[];
            end
            Tag(tagKey)=newTag;
        end
        out=Tag(tagKey);
    else
        out=Tag;
    end
end