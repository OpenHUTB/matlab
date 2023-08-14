function tags=getParamTags(obj,name,varargin)
    p=obj.getParam(name);
    if isempty(p)
        tags={};
        return;
    end
    if~isempty(p.WidgetList)
        tags={};
        for i=1:length(p.WidgetList)
            if nargin==3
                tags{end+1}=p.WidgetList{i}.getTag(varargin{1});%#ok<AGROW>
            else
                tags{end+1}=p.WidgetList{i}.getTag;%#ok<AGROW>
            end
        end
    else
        if nargin==3
            tags{1}=p.getTag(varargin{1});
        else
            tags{1}=p.getTag;
        end
    end
