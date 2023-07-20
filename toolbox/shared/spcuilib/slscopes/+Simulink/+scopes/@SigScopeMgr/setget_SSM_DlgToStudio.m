function out=setget_SSM_DlgToStudio(tagKey,varargin)
    persistent Tag

    if nargin&&~isempty(tagKey)
        if nargin>1&&ischar(varargin{1})
            if~isa(Tag,'containers.Map')
                Tag=containers.Map('KeyType','char','ValueType','char');
            end
            Tag(tagKey)=varargin{1};
        end
        out=Tag(tagKey);
    else
        out=Tag;
    end
end